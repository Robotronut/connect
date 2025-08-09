import 'dart:convert';
import 'package:connect/main.dart';
import 'package:connect/services/api_service.dart';
import 'package:connect/services/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get_utils/src/extensions/widget_extensions.dart';
import 'package:signalr_netcore/signalr_client.dart';

// Enum to represent the state of the video call for clearer UI management.
enum CallState {
  connecting,
  active,
  disconnected,
  error,
}

// WebRTC STUN/TURN server configuration. STUN servers are used to
// discover the public IP address of the client.
const Map<String, dynamic> configuration = {
  'iceServers': [
    {
      'urls': [
        'stun:global.stun.twilio.com:3478',
        'stun:stun1.l.google.com:19302',
        'stun:stun2.l.google.com:19302',
      ],
    }
  ]
};

// SDP constraints for the offer. These determine what media types (audio/video)
// the peer connection is willing to receive.
const Map<String, dynamic> offerSdpConstraints = {
  'mandatory': {
    'OfferToReceiveAudio': true,
    'OfferToReceiveVideo': true,
  },
  'optional': [],
};

class VideoChatScreen extends StatefulWidget {
  final HubConnection hubConnection;
  final String currentUserId;
  final String otherUserId;
  final bool isCallInitiated;
  // ignore: non_constant_identifier_names
  final String conversationId;
  const VideoChatScreen(
      {Key? key,
        required this.hubConnection,
        required this.currentUserId,
        required this.otherUserId,
        required this.isCallInitiated,
        required this.conversationId})
      : super(key: key);

  @override
  _VideoChatScreenState createState() => _VideoChatScreenState();
}

class _VideoChatScreenState extends State<VideoChatScreen> {
  // Renderers for displaying local and remote video streams.
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  String? sendingPayload;
  // WebRTC peer connection instance.
  RTCPeerConnection? _peerConnection;

  // Media streams for local and remote video.
  MediaStream? _localStream;
  MediaStream? _remoteStream;

  // State variable to manage the UI based on the call status.
  CallState _callState = CallState.connecting;

  @override
  void initState() {
    super.initState();
    _localRenderer.initialize();
    _remoteRenderer.initialize();
    // Initialize WebRTC and SignalR handlers.
    _initWebRTC();
  }

  @override
  void dispose() {
    // Clean up all resources when the widget is removed from the tree.
    print('Tylar:WebRTC: Disposing of VideoChatScreen resources...');
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _peerConnection?.close();
    _localStream?.dispose();
    _remoteStream?.dispose();
    // Stop listening to SignalR events to prevent memory leaks.
    widget.hubConnection
        .on('EndConversation', widget.conversationId as MethodInvocationFunc);
    widget.hubConnection.off('ReceiveSignalMessage');
    super.dispose();
  }

  // --- WebRTC Setup & Lifecycle ---

  /// Initializes the WebRTC peer connection and gets the local media stream.
  void _initWebRTC() async {
    // Check for a valid SignalR connection before proceeding.
    if (widget.hubConnection.state != HubConnectionState.Connected) {
      print(
          'Tylar:SignalR: Hub connection is not connected. State: ${widget.hubConnection.state}. Aborting WebRTC init.');
      setState(() {
        _callState = CallState.error;
      });
      return;
    }
    print(
        'Tylar:SignalR: Hub connection is active. Proceeding with WebRTC setup.');

    try {
      // Create the peer connection.
      print('Tylar connects: $configuration : $offerSdpConstraints');
      _peerConnection =
      await createPeerConnection(configuration, offerSdpConstraints);
      print('Tylar:WebRTC: PeerConnection created successfully.');
    } catch (e) {
      print('Tylar:WebRTC: Failed to create PeerConnection: $e');
      setState(() {
        _callState = CallState.error;
      });
      return;
    }

    // Get the local media stream (audio and video).
    try {
      final Map<String, dynamic> mediaConstraints = {
        'video': true,
        'audio': true
      };
      _localStream =
      await navigator.mediaDevices.getUserMedia(mediaConstraints);

      // Add local tracks to the peer connection.
      _localStream?.getTracks().forEach((track) {
        print(
            'Tylar:WebRTC: Adding local track with kind: ${track.kind} to peer connection.');
        _peerConnection?.addTrack(track, _localStream!);
      });

      // Attach the local stream to the local renderer.
      _localRenderer.srcObject = _localStream;
      print(
          'Tylar:WebRTC: Local stream attached and tracks added to peer connection.');
      setState(() {});
    } catch (e) {
      print(
          'Tylar:WebRTC: Failed to get local media stream: $e. Check permissions!');
      setState(() {
        _callState = CallState.error;
      });
      return;
    }

    // Set up handlers for WebRTC events.
    _setupWebRTCHandlers();

    // Start the call if this user is the initiator.
    if (widget.isCallInitiated) {
      print('Tylar:WebRTC: Initiating call as OFFERER.');
      _createOffer();
    }
  }

  /// Configures all the WebRTC event handlers.
  void _setupWebRTCHandlers() {
    _peerConnection?.onIceConnectionState = (RTCIceConnectionState state) {
      print('Tylar:WebRTC: ICE Connection State: $state');
      // Update the call state based on the ICE connection state.
      if (state == RTCIceConnectionState.RTCIceConnectionStateConnected) {
        setState(() {
          _callState = CallState.active;
        });
        print(
            'Tylar:WebRTC: ICE Connection State: Connected. The call is now active.');
      } else if (state ==
          RTCIceConnectionState.RTCIceConnectionStateDisconnected) {
        setState(() {
          _callState = CallState.disconnected;
        });
        print('Tylar:WebRTC: ICE Connection State: Disconnected.');
      } else if (state == RTCIceConnectionState.RTCIceConnectionStateFailed) {
        setState(() {
          _callState = CallState.error;
        });
        print(
            'Tylar:WebRTC: ICE Connection State: Failed. There was an error establishing the connection.');
      }
    };

    _peerConnection?.onIceCandidate = (candidate) async {
      // Add a check to ensure the SignalR hub connection is in a
      // connected state before sending the candidate.
      if (widget.hubConnection.state != HubConnectionState.Connected) {
        print(
            'Tylar:WebRTC: Hub connection is not active. Cannot send ICE candidate.');
        return;
      }

      if (candidate != null) {
        print('Tylar:WebRTC: Generated an ICE candidate. Sending to peer...');

        // Construct the WebRTC payload for the ICE candidate
        final webrtcPayload = jsonEncode(
          {
            'type': 'iceCandidate', // Explicitly add type for clarity
            'candidate': candidate.candidate,
            'sdpMid': candidate.sdpMid,
            'sdpMLineIndex': candidate.sdpMLineIndex,
          },
        );
        final String currentUserId = widget.currentUserId;
        final String otherUserId = widget.otherUserId;
        final String conversationId = widget.conversationId;

        //use apiService to save all information

        // Invoke SendSignalMessage with only TWO arguments: conversationId and the WebRTC payload
        await widget.hubConnection.invoke('SendSignalMessage', args: [
          widget.conversationId, // Argument 1: conversationId
          webrtcPayload, // Argument 2: The entire WebRTC payload as a JSON string
        ]).then((_) async {
          await ApiService.savePayload(context,
              sender: (currentUserId),
              receiver: otherUserId,
              conversationId: conversationId,
              payLoad: webrtcPayload);
          print('Tylar:WebRTC: Successfully sent ICE candidate.');
        }).catchError((e) {
          print('Tylar:WebRTC: Failed to send ICE candidate: $e');
        });
      } else {
        print('Tylar:WebRTC: Generated null ICE candidate.');
      }
    };

    _peerConnection?.onAddTrack = (stream, track) {
      print(
          'Tylar:WebRTC: onAddTrack fired! Stream ID: ${stream.id}, Track Kind: ${track.kind}');
      // Your fix: explicitly update the remote stream and call setState.
      if (_remoteStream != stream) {
        setState(() {
          _remoteStream = stream;
          _remoteRenderer.srcObject = _remoteStream;
        });
        print('Tylar:WebRTC: Remote stream attached to renderer.');
      }
    };

    // Listen for incoming signaling messages from the hub.
    widget.hubConnection.on('ReceiveSignalMessage', _handleSignalMessage);
    widget.hubConnection.onclose(({error}) {
      print('Tylar:SignalR: Connection closed! Error: $error');
    });
    widget.hubConnection.onreconnecting(({error}) {
      print('Tylar:SignalR: Reconnecting! Error: $error');
    });
  }

  /// A new method to clean up and hang up the call.
  void _hangUp() async {
    print('Tylar:WebRTC: Hang up initiated.');
    // Notify the other peer (optional, but good practice).
    await _peerConnection?.close();
    _peerConnection = null;
    _localStream?.dispose();
    _localStream = null;
    _remoteStream?.dispose();
    _remoteStream = null;
    _localRenderer.srcObject = null;
    _remoteRenderer.srcObject = null;
    await widget.hubConnection
        .invoke('EndConversation', args: [widget.conversationId]);
    Navigator.of(context).pop();
  }

  // --- Signaling Methods ---

  /// Handles incoming signaling messages (offer, answer, candidates).
  void _handleSignalMessage(List<dynamic>? args) async {
    if (args == null || args.isEmpty) {
      print("Tylar: WebRTC: Ignoring invalid signal message.");
      return;
    }

    final String jsonPayload = args[0] as String;

    print('Tylar: WebRTC: Received message with payload: $jsonPayload');

    if (_peerConnection == null) {
      print(
          'Tylar:WebRTC: PeerConnection is null, cannot process signaling message.');
      return;
    }

    try {
      final Map<String, dynamic> data = jsonDecode(jsonPayload);
      final String senderUserId = data['senderUserId'];
      final String payload = data['payload'];

      // IMPORTANT: Check if the message is from the current user. If so, ignore it.
      if (senderUserId == widget.currentUserId) {
        print('Tylar: WebRTC: Ignoring message from self.');
        return;
      }

      final Map<String, dynamic> webrtcData = jsonDecode(payload);
      final type = webrtcData['type'];

      if (type == 'offer') {
        print('Tylar:WebRTC: Received SDP offer.');
        final sdpOffer = RTCSessionDescription(webrtcData['sdp'], 'offer');
        await _peerConnection!.setRemoteDescription(sdpOffer);
        print('Tylar:WebRTC: Remote description set. Creating answer...');
        _createAnswer();
      } else if (type == 'answer') {
        print('Tylar:WebRTC: Received SDP answer.');
        final sdpAnswer = RTCSessionDescription(webrtcData['sdp'], 'answer');
        await _peerConnection?.setRemoteDescription(sdpAnswer);
        print('Tylar:WebRTC: Remote description set to answer.');
      } else if (webrtcData.containsKey('candidate')) {
        print('Tylar:WebRTC: Received ICE candidate.');
        final candidate = RTCIceCandidate(
          webrtcData['candidate'],
          webrtcData['sdpMid'],
          webrtcData['sdpMLineIndex'],
        );
        await _peerConnection?.addCandidate(candidate);
        print('Tylar:WebRTC: Added an ICE candidate.');
      }
    } catch (e) {
      print('Tylar:WebRTC: Error processing signaling message: $e');
    }
  }

  /// Creates and sends an SDP offer to the other peer.
  /// Creates and sends an SDP offer to the other peer.
  void _createOffer() async {
    // Check if the SignalR hub connection is active before creating and sending the offer.
    // This prevents the "Failed to invoke" error.
    if (widget.hubConnection.state != HubConnectionState.Connected) {
      print(
          'Tylar:WebRTC: Hub connection is not active. Cannot create and send offer.');
      return;
    }

    try {
      final offer = await _peerConnection?.createOffer();
      if (offer != null) {
        await _peerConnection?.setLocalDescription(offer);

        // Construct the WebRTC payload for the SDP offer
        final webrtcPayload = jsonEncode({'type': 'offer', 'sdp': offer.sdp});

        // Invoke SendSignalMessage with only TWO arguments: conversationId and the WebRTC payload
        await widget.hubConnection.invoke('SendSignalMessage', args: [
          widget.conversationId, // Argument 1: conversationId
          webrtcPayload, // Argument 2: The entire WebRTC payload as a JSON string
        ]).then((_) {
          print('Tylar:WebRTC: Successfully sent SDP offer.');
        }).catchError((e) {
          print('Tylar:WebRTC: Failed to send SDP offer: $e');
        });
      } else {
        print(
            'Tylar:WebRTC: createOffer() returned null, unable to send offer.');
      }
    } catch (e) {
      print('Tylar:WebRTC: Error creating offer: $e');
    }
  }

  /// Creates and sends an SDP answer to the other peer.
  void _createAnswer() async {
    // Check if the SignalR hub connection is active before creating and sending the answer.
    // This prevents the "Failed to invoke" error.
    if (widget.hubConnection.state != HubConnectionState.Connected) {
      print(
          'Tylar:WebRTC: Hub connection is not active. Cannot create and send answer.');
      return;
    }

    try {
      final answer = await _peerConnection?.createAnswer();
      if (answer != null) {
        await _peerConnection?.setLocalDescription(answer);

        // Construct the WebRTC payload for the SDP answer
        final webrtcPayload = jsonEncode({'type': 'answer', 'sdp': answer.sdp});

        // Invoke SendSignalMessage with only TWO arguments: conversationId and the WebRTC payload
        await widget.hubConnection.invoke('SendSignalMessage', args: [
          widget.conversationId, // Argument 1: conversationId
          webrtcPayload, // Argument 2: The entire WebRTC payload as a JSON string
        ]).then((_) {
          print('Tylar:WebRTC: Successfully sent SDP answer.');
        }).catchError((e) {
          print('Tylar:WebRTC: Failed to send SDP answer: $e');
        });
      }
    } catch (e) {
      print('Tylar:WebRTC: Error creating answer: $e');
    }
  }

  // --- UI Build Method ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Call'),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_end, color: Colors.red),
            onPressed: _hangUp,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Remote video feed (full screen)
          SizedBox.expand(
            child: _remoteStream != null
                ? RTCVideoView(_remoteRenderer)
                : Container(
              color: Colors.black,
              child: Center(
                child: _buildRemoteVideoStatus(),
              ),
            ),
          ),
          // Local video feed (small overlay)
          Positioned(
            right: 20,
            bottom: 20,
            child: SizedBox(
              width: 120,
              height: 180,
              child: _localRenderer.srcObject != null
                  ? RTCVideoView(_localRenderer, mirror: true)
                  : Container(color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemoteVideoStatus() {
    switch (_callState) {
      case CallState.connecting:
        return const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              'Connecting...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        );
      case CallState.active:
        return const Text(
          'Call Active',
          style: TextStyle(color: Colors.white, fontSize: 24),
        );
      case CallState.disconnected:
        return const Text(
          'Disconnected',
          style: TextStyle(color: Colors.red, fontSize: 24),
        );
      case CallState.error:
        return const Text(
          'Connection Failed',
          style: TextStyle(color: Colors.red, fontSize: 24),
        );
      default:
        return const Text(
          'Waiting for remote video...',
          style: TextStyle(color: Colors.white),
        );
    }
  }
}