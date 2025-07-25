import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting, add to pubspec.yaml
// Assuming SecureStorageService and ChatScreen are defined elsewhere
import 'package:connect/services/secure_storage_service.dart';
import 'package:signalr_core/signalr_core.dart';
import 'dart:io';
import 'package:http/io_client.dart';
import 'package:connect/screens/chat_screen.dart'; // Assuming your ChatScreen is in chat_screen.dart

// --- New Data Model for Conversation Preview ---
class ConversationPreview {
  final String otherUserId;
  final String otherUsername;
  final String? otherUserAvatarUrl; // Nullable if avatar might not exist
  final String lastMessageContent;
  final DateTime lastMessageTimestamp;

  ConversationPreview({
    required this.otherUserId,
    required this.otherUsername,
    this.otherUserAvatarUrl,
    required this.lastMessageContent,
    required this.lastMessageTimestamp,
  });

  // Factory constructor to parse JSON from the backend DTO
  factory ConversationPreview.fromJson(Map<String, dynamic> json) {
    return ConversationPreview(
      otherUserId: json['otherUserId'].toString(),
      otherUsername: json['otherUsername'].toString(),
      otherUserAvatarUrl:
      json['otherUserAvatarUrl']?.toString(), // Handle nullable
      lastMessageContent: json['lastMessageContent'].toString(),
      lastMessageTimestamp:
      DateTime.parse(json['lastMessageTimestamp'].toString()),
    );
  }
}

class InboxScreen extends StatefulWidget {
  final String currentUserId; // The ID of the currently logged-in user
  final String chatHubUrl; // The URL of your SignalR ChatHub

  const InboxScreen({
    Key? key,
    required this.currentUserId,
    required this.chatHubUrl,
  }) : super(key: key);

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  late HubConnection _hubConnection;
  List<ConversationPreview> _conversations = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initSignalRAndLoadInbox();
  }

  // Helper function to format the date/time as requested
  String _formatDateTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24 && now.day == timestamp.day) {
      return DateFormat('HH:mm').format(timestamp); // Time (e.g., "14:30")
    } else if (difference.inDays < 7) {
      return DateFormat('EEE')
          .format(timestamp); // Day of the week (e.g., "Mon")
    } else {
      return DateFormat('MM/dd/yy')
          .format(timestamp); // Short date (e.g., "07/19/25")
    }
  }

  Future<void> _initSignalRAndLoadInbox() async {
    // Create an IOClient instance wrapping the HttpClient for SSL bypass (DEV ONLY!)
    final IOClient ioClient = IOClient(HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true);

    final String? apiKey = await SecureStorageService.getApiKey();
    final String? rawToken = apiKey;

    _hubConnection = HubConnectionBuilder()
        .withUrl(
      widget.chatHubUrl,
      HttpConnectionOptions(
        transport: HttpTransportType.webSockets,
        client: ioClient,
        accessTokenFactory: () async => rawToken,
        logging: (level, message) =>
            print('SignalR Log [$level]: $message'),
      ),
    )
        .withAutomaticReconnect()
        .build();

    _hubConnection.onclose((error) {
      setState(() {
        _isLoading = false;
        _errorMessage =
        'Connection closed: ${error?.toString() ?? "Unknown error"}';
      });
      print('Connection closed: $error');
    });

    try {
      await _hubConnection.start();
      print('Connected to SignalR Hub for Inbox.');
      await _loadInboxPreviews(); // Load data after connection
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Connection failed: ${e.toString()}';
      });
      print('Error connecting to SignalR Hub for Inbox: $e');
    }
  }

  Future<void> _loadInboxPreviews() async {
    if (_hubConnection.state != HubConnectionState.connected) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Not connected to chat hub to load inbox.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Invoke the new backend method to get conversation previews
      final List<dynamic>? result =
      await _hubConnection.invoke('GetInboxPreviews');

      if (result != null) {
        final List<ConversationPreview> loadedConversations = result
            .map<ConversationPreview>(
                (jsonMap) => ConversationPreview.fromJson(jsonMap))
            .toList();

        setState(() {
          _conversations = loadedConversations;
          _isLoading = false;
        });
        print('Inbox previews loaded successfully.');
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No inbox data received.';
        });
        print('No inbox data received from GetInboxPreviews.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load inbox: ${e.toString()}';
      });
      print('Error loading inbox previews: $e');
    }
  }

  @override
  void dispose() {
    _hubConnection.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900, // Overall dark background
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
          return Card(
            margin: const EdgeInsets.symmetric(
                horizontal: 10.0, vertical: 4.0),
            color: Colors.grey.shade800, // Dark card background
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () {
                // Navigate to the ChatScreen for this conversation
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      username: conversation.otherUsername,
                      chatHubUrl: widget.chatHubUrl,
                      currentUserId: widget.currentUserId,
                      otherUserId: conversation.otherUserId,
                      otherUserName: conversation.otherUsername,
                    ),
                  ),
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
                      backgroundImage: conversation
                          .otherUserAvatarUrl !=
                          null
                          ? NetworkImage(
                          conversation.otherUserAvatarUrl!)
                          : null,
                      child:
                      conversation.otherUserAvatarUrl == null
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
                              color: Colors.white,
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
                              color: Colors.grey.shade400,
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
          );
        },
      ),
    );
  }
}