import 'package:connect/main.dart';
import 'package:connect/screens/chat_screen.dart';
import 'package:connect/screens/report_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting, add to pubspec.yaml
import 'package:connect/services/secure_storage_service.dart';
import 'package:logging/logging.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:http/io_client.dart';
//import 'package:connect/screens/chat_screen.dart'; // Assuming your ChatScreen is in chat_screen.dart
//import 'package:connect/screens/report_screen.dart'; // Import your ReportScreen

import 'package:signalr_netcore/signalr_client.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';

// Assuming you have these models for your conversation and message data.
// If not, you'll need to define them.
class Conversation {
  final String otherUsername;
  final String otherUserId;
  final String otherUserAvatarUrl;
  String lastMessageContent;
  DateTime lastMessageTimestamp;

  Conversation({
    required this.otherUsername,
    required this.otherUserId,
    required this.otherUserAvatarUrl,
    required this.lastMessageContent,
    required this.lastMessageTimestamp,
  });
}

// Your existing InboxScreen widget
class InboxScreen extends StatefulWidget {
  final String currentUserId;
  final String currentUserImgUrl;
  final String currentUserUserName;
  final String chatHubUrl;

  const InboxScreen(
      {Key? key,
      required this.currentUserId,
      required this.chatHubUrl,
      required this.currentUserImgUrl,
      required this.currentUserUserName})
      : super(key: key);

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  // SignalR Hub Connection
  late HubConnection hubConnection;

  // State variables for the UI
  bool _isLoading = true;
  String? _errorMessage;
  final List<Conversation> _conversations = [];

  @override
  void initState() {
    super.initState();
    // Initialize the SignalR connection when the widget is created
    _initSignalR();
  }

  // Remember to dispose of the hub connection when the widget is removed
  @override
  void dispose() {
    hubConnection.stop();
    super.dispose();
  }

  // --- SignalR Logic ---
  Future<void> _initSignalR() async {
    // 1. Create the HubConnection.
    final String? APIkey = await SecureStorageService.getApiKey();
    hubConnection = HubConnectionBuilder()
        .withUrl(
          kServerUrl,
          options: HttpConnectionOptions(
            accessTokenFactory: () async => Future.value(APIkey),
          ),
        )
        .build();

    // 2. Set up event handlers.
    hubConnection.on('ReceiveMessage', _handleReceiveMessage);
    hubConnection.on('ReceiveConversations', _handleReceiveConversations);

    hubConnection.onclose(({error}) {
      if (error != null) {
        print("Tylar: Connection closed with error: $error");
        // Implement a reconnection logic here if needed
      } else {
        print("Tylar: Connection closed without error.");
      }
    });

    // 3. Start the connection.
    try {
      await hubConnection.start();
      print("Tylar: SignalR connection started successfully.");
      setState(() {
        _isLoading = false;
        _errorMessage = null;
      });

      _fetchInitialConversations();
    } catch (e) {
      print("Tylar: Error starting SignalR connection: $e");
      setState(() {
        _isLoading = false;
        _errorMessage =
            "Failed to connect to the server. Please try again later.";
      });
    }
  }

  Future<void> _fetchInitialConversations() async {
    try {
      // Corrected line: Invoke GetChatHistory without any arguments.
      final conversations = await hubConnection.invoke('GetInboxPreviews');

      if (conversations != null) {
        final List<Conversation> parsedConversations = (conversations as List)
            .map((e) => Conversation(
                  otherUsername: e['otherUsername'] as String,
                  otherUserId: e['otherUserId'] as String,
                  otherUserAvatarUrl: e['otherUserAvatarUrl'] as String,
                  lastMessageContent: e['lastMessageContent'] as String,
                  lastMessageTimestamp:
                      DateTime.parse(e['lastMessageTimestamp'] as String),
                ))
            .toList();

        setState(() {
          _conversations.clear();
          _conversations.addAll(parsedConversations);
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      print("Error fetching conversations: $e");
      setState(() {
        _isLoading = false;
        _errorMessage = "Could not load conversations. Please try again.";
      });
    }
  }

  void _handleReceiveMessage(List<Object?>? arguments) {
    if (arguments != null && arguments.isNotEmpty) {
      final message = arguments[0] as Map<String, dynamic>;
      final senderId = message['senderId'] as String;
      final receiverId = message['receiverId'] as String;
      final content = message['content'] as String;
      final senderImgUrl = message['senderAvatarUrl'] as String;
      final receiverImgUrl = message['otherUserAvatarUrl'] as String;
      final timestamp = DateTime.parse(message['timestamp'] as String);
      final receiverUserName = message['otherUsername'] as String;
      setState(() {
        final existingIndex = _conversations.indexWhere((conv) =>
            conv.otherUserId == senderId || conv.otherUserId == receiverId);

        if (existingIndex != -1) {
          final existingConv = _conversations[existingIndex];
          existingConv.lastMessageContent = content;
          existingConv.lastMessageTimestamp = timestamp;

          final updatedConv = _conversations.removeAt(existingIndex);
          _conversations.insert(0, updatedConv);
        } else {
          _conversations.insert(
              0,
              Conversation(
                otherUsername: message['senderUsername'] as String,
                otherUserId: receiverId,
                otherUserAvatarUrl: receiverImgUrl,
                lastMessageContent: content,
                lastMessageTimestamp: timestamp,
              ));
        }
      });
    }
  }

  void _handleReceiveConversations(List<Object?>? arguments) {
    if (arguments != null && arguments.isNotEmpty) {
      final List<dynamic> conversationData = arguments[0] as List<dynamic>;
      final List<Conversation> newConversations = conversationData
          .map((e) => Conversation(
                otherUsername: e['otherUsername'] as String,
                otherUserId: e['otherUserId'] as String,
                otherUserAvatarUrl: e['otherUserAvatarUrl'] as String,
                lastMessageContent: e['lastMessageContent'] as String,
                lastMessageTimestamp:
                    DateTime.parse(e['lastMessageTimestamp'] as String),
              ))
          .toList();

      setState(() {
        _conversations.clear();
        _conversations.addAll(newConversations);
        _isLoading = false;
        _errorMessage = null;
      });
    }
  }

  String _formatDateTime(DateTime dateTime) {
    // This is a placeholder; you'll want a more robust implementation.
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // --- The missing build method, which uses your original UI layout ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Overall dark background
      appBar: AppBar(
        title: const Text(
          'Inbox',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black, // Dark app bar
        elevation: 8, // Prominent shadow
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black87, Colors.black],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // Add a leading back arrow button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Navigate back to the previous screen
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.orange), // Orange loading indicator
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Text(
                    _errorMessage!,
                    style:
                        const TextStyle(color: Colors.redAccent, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                )
              : _conversations.isEmpty
                  ? Center(
                      child: Text(
                        'No conversations yet.',
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _conversations.length,
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      itemBuilder: (context, index) {
                        final conversation = _conversations[index];
                        return Column(
                          children: [
                            Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 4.0),
                              color: Colors.black, // Dark card background
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                        hubConnection: hubConnection,
                                        chatHubUrl: widget.chatHubUrl,
                                        currentUserId: widget.currentUserId,
                                        currentUserImgUrl:
                                            widget.currentUserImgUrl,
                                        currentUserName:
                                            widget.currentUserUserName,
                                        otherUserId: conversation.otherUserId,
                                        otherUserName:
                                            conversation.otherUsername,
                                        otherUserImgUrl:
                                            conversation.otherUserAvatarUrl,
                                      ),
                                    ),
                                  );
                                },
                                onLongPress: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (BuildContext bc) {
                                      return SafeArea(
                                        child: Wrap(
                                          children: <Widget>[
                                            ListTile(
                                              leading: const Icon(Icons.flag,
                                                  color: Colors.redAccent),
                                              title: const Text('Report User'),
                                              onTap: () {
                                                Navigator.pop(
                                                    bc); // Close the bottom sheet
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ReportScreen(
                                                      reportedUserId:
                                                          conversation
                                                              .otherUserId,
                                                      reportedUsername:
                                                          conversation
                                                              .otherUsername,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: [
                                      // User Profile Image (Left)
                                      CircleAvatar(
                                        radius: 28,
                                        backgroundColor: Colors.grey.shade700,
                                        backgroundImage:
                                            // ignore: unnecessary_null_comparison
                                            conversation.otherUserAvatarUrl !=
                                                    null
                                                ? NetworkImage(conversation
                                                    .otherUserAvatarUrl)
                                                : null,
                                        child:
                                            // ignore: unnecessary_null_comparison
                                            conversation.otherUserAvatarUrl ==
                                                    null
                                                ? Icon(Icons.person,
                                                    color: Colors.grey.shade400,
                                                    size: 30)
                                                : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Username
                                            Text(
                                              conversation.otherUsername,
                                              style: const TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 17,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            // Last Message Content
                                            Text(
                                              conversation.lastMessageContent,
                                              style: TextStyle(
                                                color: Colors.cyan,
                                                fontSize: 14,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Date/Time of Last Message (Far Right)
                                      Text(
                                        _formatDateTime(
                                            conversation.lastMessageTimestamp),
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (index < _conversations.length - 1)
                              Divider(
                                color: Colors.grey.shade700,
                                thickness: 1,
                                indent: 20,
                                endIndent: 20,
                              ),
                          ],
                        );
                      },
                    ),
    );
  }
}
