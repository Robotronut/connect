import 'package:flutter/material.dart';
import 'dart:io';
import 'package:signalr_core/signalr_core.dart';
import 'package:http/io_client.dart'; // Required for IOClient
import 'package:intl/intl.dart'; // Import for date formatting

import 'package:connect/services/secure_storage_service.dart';

// Define a simple ChatMessage model to match your backend
class ChatMessage {
  final String senderId;
  final String recipientId;
  final String content;
  final DateTime timestamp;
  final bool
  isMe; // Helper to determine if the message was sent by the current user

  ChatMessage({
    required this.senderId,
    required this.recipientId,
    required this.content,
    required this.timestamp,
    this.isMe = false,
  });

  // Factory constructor to parse from SignalR arguments
  factory ChatMessage.fromSignalR(
      List<dynamic>? arguments, String currentUserId) {
    if (arguments == null || arguments.length < 4) {
      throw ArgumentError('Invalid arguments for ChatMessage.fromSignalR');
    }
    final String senderId = arguments[0].toString();
    final String recipientId = arguments[1].toString();
    final String content = arguments[2].toString();
    final DateTime timestamp =
    DateTime.parse(arguments[3].toString()); // Assuming ISO 8601 string

    return ChatMessage(
      senderId: senderId,
      recipientId: recipientId,
      content: content,
      timestamp: timestamp,
      isMe: senderId == currentUserId,
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String username; // Assuming you pass the current user's username
  final String chatHubUrl; // Your SignalR Hub URL
  final String currentUserId; // The ID of the currently logged-in user
  final String otherUserId; // The ID of the user you are chatting with
  final String otherUserName;
  const ChatScreen(
      {Key? key,
        required this.username,
        required this.chatHubUrl,
        required this.currentUserId,
        required this.otherUserId,
        required this.otherUserName})
      : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late HubConnection _hubConnection;
  final List<ChatMessage> _messages =
  []; // To store chat messages (using the new model)
  final TextEditingController _messageController = TextEditingController();
  bool _isConnected = false;
  bool _isLoadingHistory = false;

  @override
  void initState() {
    super.initState();
    _initSignalR();
  }

  Future<void> _initSignalR() async {
    // 1. Create a HubConnection instance
    final IOClient ioClient = IOClient(HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true);
    // 1. Create a HubConnection instance
    // Use accessTokenFactory for authentication and include the custom IOClient
    _hubConnection = HubConnectionBuilder()
        .withUrl(
      widget.chatHubUrl, // e.g., 'https://peek.thegwd.ca/chatHub'
      HttpConnectionOptions(
        // IMPORTANT: If you want the client to perform the negotiation,
        // remove 'skipNegotiation: true' or set it to 'false'.
        // The client library will handle the GET/POST negotiation based on server response.
        // If your server specifically requires POST for negotiation, the client library
        // will typically adapt, but directly forcing POST is not an exposed option.
        // Forcing 'skipNegotiation: true' bypasses the negotiation entirely.
        // skipNegotiation: true, // <--- Consider removing or setting to false
        transport: HttpTransportType.webSockets,
        // Pass the custom IOClient here for SSL bypass
        client: ioClient, // <--- Use IOClient here
        // Use accessTokenFactory to provide the token dynamically
        accessTokenFactory: () async {
          final String? apiKey = await SecureStorageService.getApiKey();
          return apiKey; // Return the raw token string
        },
        // Add logging for detailed SignalR client messages (very useful for debugging!)
        logging: (level, message) =>
            print('SignalR Log [$level]: $message'),
      ),
    )
        .withAutomaticReconnect() // Add automatic reconnection for robustness
        .build();

    // Handler for public messages (if still used)
    _hubConnection.on('ReceiveMessage', (arguments) {
      if (arguments != null && arguments.length >= 3) {
        final String sender = arguments[0].toString();
        final String message = arguments[1].toString();
        final DateTime timestamp = DateTime.parse(arguments[2].toString());
        setState(() {
          _messages.insert(
              0,
              ChatMessage(
                senderId: sender,
                recipientId: 'All', // Or a group identifier for public messages
                content: message,
                timestamp: timestamp,
                isMe: sender ==
                    widget
                        .username, // Assuming username is used for public sender
              ));
        });
        print('Received public message: $sender: $message');
      }
    });

    // Handler for private messages
    _hubConnection.on('ReceivePrivateMessage', (arguments) {
      if (arguments != null && arguments.length >= 4) {
        try {
          final ChatMessage receivedMessage =
          ChatMessage.fromSignalR(arguments, widget.currentUserId);
          setState(() {
            _messages.insert(
                0, receivedMessage); // Add to the top for reverse list
          });
          print(
              'Received private message: ${receivedMessage.senderId} to ${receivedMessage.recipientId}: ${receivedMessage.content}');
        } catch (e) {
          print(
              'Error parsing ReceivePrivateMessage: $e, Arguments: $arguments');
        }
      }
    });

    // Handler for system messages
    _hubConnection.on('ReceiveSystemMessage', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final String message = arguments[0].toString();
        setState(() {
          _messages.insert(
              0,
              ChatMessage(
                senderId: 'System',
                recipientId: widget.currentUserId,
                content: 'System Message: $message',
                timestamp: DateTime.now(),
              ));
        });
        print('Received system message: $message');
      }
    });

    // 3. Start the connection
    try {
      await _hubConnection.start();
      setState(() {
        _isConnected = true;
        _messages.add(ChatMessage(
          senderId: 'System',
          recipientId: widget.currentUserId,
          content: 'Connected to chat hub.',
          timestamp: DateTime.now(),
        ));
      });
      print('Connected to SignalR Hub.');
      // After successful connection, load chat history
      _loadChatHistory();
    } catch (e) {
      setState(() {
        _isConnected = false;
        // Capture and print the full error message for debugging
        _messages.add(ChatMessage(
          senderId: 'System',
          recipientId: widget.currentUserId,
          content: 'Connection failed: ${e.toString()}',
          timestamp: DateTime.now(),
        ));
      });
      print('Error connecting to SignalR Hub: ${e.toString()}');
      // If it's a SocketException, print its details
      if (e is SocketException) {
        print(
            'SocketException: ${e.message} (OS Error: ${e.osError?.message}, Code: ${e.osError?.errorCode})');
      } else if (e is HandshakeException) {
        // Specifically catch HandshakeException for TLS issues
        print('HandshakeException: ${e.message}');
      }
    }
  }

  // Function to load chat history
  Future<void> _loadChatHistory() async {
    if (_hubConnection.state == HubConnectionState.connected) {
      setState(() {
        _isLoadingHistory = true;
      });
      try {
        // Invoke the GetChatHistory method on the backend hub
        final List<dynamic>? historyArgs = await _hubConnection.invoke(
          'GetChatHistory',
          args: [widget.currentUserId, widget.otherUserId],
        );

        if (historyArgs != null) {
          final List<ChatMessage> loadedMessages = historyArgs.map((msgMap) {
            // Assuming msgMap is a Map<String, dynamic> from the backend
            // You might need to adjust key names based on your ChatMessage model in C#
            return ChatMessage(
              senderId: msgMap['senderId'].toString(),
              recipientId: msgMap['recipientId'].toString(),
              content: msgMap['content'].toString(),
              timestamp: DateTime.parse(msgMap['timestamp'].toString()),
              isMe: msgMap['senderId'].toString() == widget.currentUserId,
            );
          }).toList();

          setState(() {
            // Clear existing messages and add loaded history
            _messages.clear();
            _messages.addAll(loadedMessages
                .reversed); // Display oldest first if not reversed
            // Add a system message indicating history loaded

          });
          print('Chat history loaded successfully.');
        }
      } catch (e) {
        setState(() {
          _messages.insert(
              0,
              ChatMessage(
                senderId: 'System',
                recipientId: widget.currentUserId,
                content: 'Failed to load chat history: ${e.toString()}',
                timestamp: DateTime.now(),
              ));
        });
        print('Error loading chat history: $e');
      } finally {
        setState(() {
          _isLoadingHistory = false;
        });
      }
    } else {
      print('Cannot load chat history: Not connected.');
    }
  }

  @override
  void dispose() {
    _hubConnection.stop(); // Stop the connection when the widget is disposed
    _messageController.dispose();
    super.dispose();
  }

  // Function to send a private message
  Future<void> _sendPrivateMessage() async {
    if (_hubConnection.state == HubConnectionState.connected) {
      final messageContent = _messageController.text.trim();
      if (messageContent.isNotEmpty) {
        try {
          // Invoke the SendPrivateMessage method on your SignalR Hub
          await _hubConnection.invoke('SendPrivateMessage',
              args: [widget.otherUserId, messageContent]);
          _messageController.clear(); // Clear the input field after sending
          print(
              'Private message sent: $messageContent to ${widget.otherUserId}');
          // The message will be added to _messages via the 'ReceivePrivateMessage' handler
          // which is called for both sender and receiver.
        } catch (e) {
          setState(() {
            _messages.insert(
                0,
                ChatMessage(
                  senderId: 'System',
                  recipientId: widget.currentUserId,
                  content: 'Failed to send message: ${e.toString()}',
                  timestamp: DateTime.now(),
                ));
          });
          print('Error sending private message: $e');
        }
      }
    } else {
      setState(() {
        _messages.insert(
            0,
            ChatMessage(
              senderId: 'System',
              recipientId: widget.currentUserId,
              content: 'Cannot send message: Not connected.',
              timestamp: DateTime.now(),
            ));
      });
      print('Cannot send message: Not connected.');
    }
  }

  // Original _sendMessage for public broadcast (kept for reference, but primary focus is private)
  Future<void> _sendMessage() async {
    if (_hubConnection.state == HubConnectionState.connected) {
      final message = _messageController.text.trim();
      if (message.isNotEmpty) {
        try {
          // 'SendMessage' is the method name on your SignalR Hub
          await _hubConnection
              .invoke('SendMessage', args: [widget.username, message]);
          _messageController.clear(); // Clear the input field after sending
          print('Public message sent: $message');
        } catch (e) {
          setState(() {
            _messages.insert(
                0,
                ChatMessage(
                  senderId: 'System',
                  recipientId: widget.currentUserId,
                  content: 'Failed to send public message: ${e.toString()}',
                  timestamp: DateTime.now(),
                ));
          });
          print('Error sending public message: $e');
        }
      }
    } else {
      setState(() {
        _messages.insert(
            0,
            ChatMessage(
              senderId: 'System',
              recipientId: widget.currentUserId,
              content: 'Cannot send public message: Not connected.',
              timestamp: DateTime.now(),
            ));
      });
      print('Cannot send public message: Not connected.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Changed title to be dynamic based on the other user
        title: Text(
          'Chat with ${widget.username}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14, // <-- You can change the font size here
            fontWeight: FontWeight.bold, // Optional: make it bold
          ),
        ),
        backgroundColor: Colors.black,
        // Dark background for app bar
        elevation: 4, // Add a subtle shadow
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black87,
                Colors.black
              ], // Darker gradient for app bar
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Display loading indicator for chat history
          _isLoadingHistory
              ? const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.orange), // Orange loading indicator
            ),
          )
              : const SizedBox.shrink(),
          Expanded(
            child: Container(
              color: Colors.grey.shade900, // Dark background for chat area
              child: ListView.builder(
                reverse: true, // Show latest messages at the bottom
                itemCount: _messages.length,
                padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 8.0), // Overall padding for list
                itemBuilder: (context, index) {
                  final chatMessage = _messages[index];

                  // Determine alignment for the whole message block (bubble + timestamp)
                  final Alignment messageAlignment = chatMessage.isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft;

                  // Determine cross-axis alignment for content within the block
                  final CrossAxisAlignment contentAlignment = chatMessage.isMe
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start;

                  return Align(
                    alignment: messageAlignment,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Column(
                        crossAxisAlignment: contentAlignment,
                        children: [
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width *
                                  0.75, // Limit bubble width
                            ),
                            padding: const EdgeInsets.all(
                                8), // Padding inside the bubble
                            decoration: BoxDecoration(
                              color: Colors
                                  .transparent, // Set the fill color to transparent
                              borderRadius: BorderRadius.circular(
                                  16), // Keep rounded corners
                              border: Border.all(
                                color: chatMessage.isMe
                                    ? Colors
                                    .red // Orange outline for sent messages
                                    : Colors.lightBlue
                                    .shade400, // Light Blue outline for received messages
                                width:
                                1.0, // Adjust the width of the outline as desired
                              ),
                              boxShadow: [
                                // Subtle shadow for depth (keep as is)
                                BoxShadow(
                                  color: Colors.black.withOpacity(
                                      0.2), // Darker shadow for dark theme
                                  blurRadius: 3,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              chatMessage.content,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors
                                    .white, // White text for message content
                              ),
                            ),
                          ),
                          const SizedBox(
                              height:
                              4), // Small space between bubble and timestamp
                          Text(
                            DateFormat('MMM dd hh:mm a').format(chatMessage.timestamp),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors
                                  .grey.shade400, // Lighter grey for timestamp
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Input area
          Container(
            padding: const EdgeInsets.only(bottom: 60, left: 12.0, right: 12.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade900, // Dark background for input area
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3), // Darker shadow
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(
                          color:
                          Colors.grey.shade500), // Lighter grey hint text
                      filled: true,
                      fillColor:
                      Colors.grey.shade800, // Darker fill for text field
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25), // More rounded
                        borderSide: BorderSide.none, // No border line
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(
                            color: Colors.grey.shade700,
                            width: 1), // Darker grey border
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(
                            color: Colors.red.shade400,
                            width: 1), // Orange accent when focused
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    enabled: _isConnected, // Disable input if not connected
                    style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white), // White text for input
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent, // Make the fill transparent
                    border: Border.all(
                      color: Colors.red.shade400, // The color of your outline
                      width: 1.0, // The thickness of your outline
                    ),
                  ),
                  child: FloatingActionButton(
                    onPressed: _isConnected
                        ? _sendPrivateMessage // Changed to send private messages
                        : null, // Disable button if not connected
                    mini: false, // Make it a standard size button
                    backgroundColor:
                    Colors.transparent, // Transparent to show gradient
                    elevation: 0, // No default elevation
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}