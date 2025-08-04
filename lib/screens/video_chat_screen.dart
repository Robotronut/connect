import 'dart:convert';

import 'package:connect/main.dart';
import 'package:connect/services/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:signalr_netcore/signalr_client.dart';

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

// Also define the offerSdpConstraints
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
  final bool isCallInitiated; // Added this to determine offerer/answerer
  const VideoChatScreen(
      {Key? key,
      required this.hubConnection,
      required this.currentUserId,
      required this.otherUserId,
      required this.isCallInitiated
      // Default to false if not provided
      })
      : super(key: key);

  @override
  _VideoChatScreenState createState() => _VideoChatScreenState();
}

class _VideoChatScreenState extends State<VideoChatScreen> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream; // <-- NEW: State variable for the remote stream

  @override
  void initState() {
    super.initState();
    _localRenderer.initialize();
    _remoteRenderer.initialize();
    // _setupSignalR(widget.hubConnection);
    _initWebRTC();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _peerConnection?.close();
    _localStream?.dispose();
    _remoteStream?.dispose(); // <-- UPDATED: Dispose the remote stream as well
    // It's a good practice to stop listening to the hub on dispose.
    widget.hubConnection.off('ReceiveSignalMessage');
    super.dispose();
  }

  // A new method to clean up and hang up the call
  void _hangUp() async {
    await _peerConnection?.close();
    _localStream?.dispose();
    _remoteStream?.dispose(); // <-- UPDATED: Dispose and set to null
    _localRenderer.srcObject = null;
    _remoteRenderer.srcObject = null;
    Navigator.of(context).pop();
  }

  void _initWebRTC() async {
    print('Tylar:WebRTC: isCallInitiated: ${widget.isCallInitiated}');
    widget.hubConnection.on('ReceiveSignalMessage', _handleSignalMessage);
    print(
        'Tylar:WebRTC: ReceiveSignalMessage handler registered.'); // <-- ADD THIS
    // 1. Create the peer connection FIRST to ensure it's not null when needed.
    print(
        'Tylar: configuration $configuration offerSdpContraints $offerSdpConstraints');
    _peerConnection =
        await createPeerConnection(configuration, offerSdpConstraints);

    if (_peerConnection == null) {
      print('Tylar:WebRTC: Failed to create PeerConnection.');
      return;
    }
    print('Tylar:WebRTC: PeerConnection created successfully.');

    // 2. Now get the local media stream.
    try {
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': {'facingMode': 'user'}
      });
      final Map<String, dynamic> mediaConstraints = {
        'video': true,
        'audio': true
      };
      _localStream =
          await navigator.mediaDevices.getUserMedia(mediaConstraints);
      // Add the local track to the peer connection.
      _localStream?.getTracks().forEach((track) {
        _peerConnection?.addTrack(track, _localStream!);
      });

      _localRenderer.srcObject = _localStream;
      print(
          'Tylar:WebRTC: Local stream attached and tracks added to peer connection.');
      setState(() {});
    } catch (e) {
      print(
          'Tylar:WebRTC: Failed to get local media stream: $e. Check permissions!');
      return;
    }

    // 3. Set up the signaling handlers
    _peerConnection?.onIceConnectionState = (RTCIceConnectionState state) {
      print('Tylar:WebRTC: ICE Connection State: $state');
    };

    _peerConnection?.onIceCandidate = (candidate) {
      if (candidate != null) {
        print('Tylar:WebRTC: Generated an ICE candidate. Sending to peer.');
        widget.hubConnection.invoke('SendSignalMessage', args: [
          widget.otherUserId,
          jsonEncode(candidate.toMap()),
        ]);
      }
    };

    // 4. IMPORTANT: Use onAddTrack, not the deprecated onAddStream
    _peerConnection?.onAddTrack = (stream, track) {
      print('Tylar:WebRTC: onAddTrack has fired! Stream ID: ${stream.id}');
      setState(() {
        _remoteStream = stream; // <-- NEW: Store the incoming stream in state
        _remoteRenderer.srcObject =
            _remoteStream; // <-- Assign it to the renderer
      });
    };

    // 5. Listen for incoming signaling messages from the hub
    widget.hubConnection.on('ReceiveSignalMessage', _handleSignalMessage);
    widget.hubConnection.onclose(({error}) {
      print('Tylar:SignalR: Connection closed! Error: $error');
    });
    widget.hubConnection.onreconnecting(({error}) {
      print('Tylar:SignalR: Reconnecting! Error: $error');
    });
    // 6. Handle the video call invitation and start the call
    if (widget.isCallInitiated) {
      print('Tylar:WebRTC: Initiating call as OFFERER.');
      _createOffer();
    }
  }

  // --- Signaling methods ---
  // In your _handleSignalMessage method
  void _handleSignalMessage(List<dynamic>? args) async {
    int arglength = args!.length;
    print("Tylar: Arg on handlesignalmessage length $arglength");
    if (args.length < 2) return;
    final senderUserId = args[0];
    final payload = args[1];

    print(
        'Tylar: WebRTC: _handleSignalMessage received from $senderUserId with payload: $payload'); // <-- UPDATED LOG

    try {
      final Map<String, dynamic> data =
          jsonDecode(payload); // <-- Add this to decode the JSON string
      final type = data['type'];

      if (type == 'offer') {
        print(
            'Tylar:WebRTC: Received an SDP offer. Processing...'); // <-- NEW LOG
        final sdpOffer = RTCSessionDescription(data['sdp'], 'offer');

        // Check if the peer connection is valid before calling setRemoteDescription
        if (_peerConnection != null) {
          await _peerConnection!.setRemoteDescription(sdpOffer);
          print(
              'Tylar:WebRTC: Remote description set. Creating answer...'); // <-- NEW LOG
          _createAnswer();
        }
      } else if (type == 'answer') {
        // ... (your existing logic for handling an answer)
        print(
            'Tylar:WebRTC: Received an SDP answer. Setting remote description...');
        final sdpAnswer = RTCSessionDescription(data['sdp'], 'answer');
        await _peerConnection?.setRemoteDescription(sdpAnswer);
      } else if (data.containsKey('candidate')) {
        // ... (your existing logic for handling ICE candidates)
        print('Tylar:WebRTC: Received an ICE candidate.');
        final candidate = RTCIceCandidate(
          data['candidate'],
          data['sdpMid'],
          data['sdpMLineIndex'],
        );

        await _peerConnection?.addCandidate(candidate);
      }
    } catch (e) {
      print(
          'Tylar:WebRTC: Error processing signaling message: $e'); // <-- CRITICAL NEW LOG
    }
  }

// In your _createOffer method
  void _createOffer() async {
    try {
      final offer = await _peerConnection?.createOffer();

      if (offer != null) {
        await _peerConnection?.setLocalDescription(offer);
        String otherUserId = widget.otherUserId;
        String thisUser = widget.currentUserId;
        print('Tylar: widget otheruserId $otherUserId');
        print('Tylar: widget current $thisUser');
        print('Tylar:WebRTC: Sending SDP Offer via SignalR...');
        await widget.hubConnection.invoke('SendSignalMessage', args: [
          widget.otherUserId,
          jsonEncode({'type': 'offer', 'sdp': offer.sdp}),
        ]);
        print('Tylar:WebRTC: Sent SDP offer.');
      } else {
        print(
            'Tylar:WebRTC: createOffer() returned null, unable to send offer.');
      }
    } catch (e) {
      print('Tylar:WebRTC: Error creating offer: $e');
    }
  }

  void _createAnswer() async {
    final answer = await _peerConnection?.createAnswer();
    if (answer != null) {
      await _peerConnection?.setLocalDescription(answer);

      // CORRECTED: Encode the map into a JSON string
      final payload = jsonEncode({'type': 'answer', 'sdp': answer.sdp});

      widget.hubConnection.invoke('SendSignalMessage', args: [
        widget.otherUserId,
        payload // <-- Now a string, which the server can handle
      ]);
      print('Tylar:WebRTC: Sent SDP answer.');
    }
  }

  Future<void> _setupSignalR(HubConnection hubConnection) async {
    final String? APIkey = await SecureStorageService.getApiKey();
    hubConnection = HubConnectionBuilder()
        .withUrl(
          kServerUrl,
          options: HttpConnectionOptions(
            accessTokenFactory: () async => Future.value(APIkey),
          ),
        )
        .build();
    // It's a good practice to start the connection here if needed.
    await hubConnection.start()?.then((_) {
      print('Tylar:SignalR: Connection started successfully!');
      // Now you can safely navigate to the VideoChatScreen or perform other actions.
    }).catchError((error) {
      print('Tylar:SignalR: Failed to start connection: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    print(
        'Tylar:Building VideoChatScreen. Remote srcObject is null: ${_remoteRenderer.srcObject == null}');
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
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
          ),
          // Local video feed (small overlay)
          Positioned(
            right: 20,
            bottom: 20,
            child: SizedBox(
              width: 120,
              height: 180,
              child: RTCVideoView(_localRenderer, mirror: true),
            ),
          ),
        ],
      ),
    );
  }
}
