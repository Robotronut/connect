import 'package:flutter/material.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:intl/intl.dart';

// Assuming you have these models for your conversation and user data.
// If not, you'll need to define them.
// import 'package:connect/models/user_model.dart';
// import 'package:connect/screens/report_screen.dart';

// --- Message Model ---
// This class represents a single chat message, mirroring the data you would
// expect to receive from your SignalR hub and store in your database.
class Message {
  final String senderId;
  final String content;
  final DateTime timestamp;
  final String recipentId;
  final String senderUserName;
  final String senderAvatarUrl;
  final bool isSender;

  Message(
      {required this.senderId,
      required this.content,
      required this.timestamp,
      required this.recipentId,
      required this.senderAvatarUrl,
      required this.senderUserName,
      required this.isSender});
}

// --- ChatScreen Widget ---
class ChatScreen extends StatefulWidget {
  final String chatHubUrl;
  final String currentUserId;
  final String otherUserId;
  final String otherUserName;
  final HubConnection hubConnection;

  const ChatScreen({
    Key? key,
    required this.chatHubUrl,
    required this.currentUserId,
    required this.otherUserId,
    required this.otherUserName,
    required this.hubConnection,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // Use a TextEditingController to manage the text in the input field.
  final TextEditingController _messageController = TextEditingController();

  // This list will hold all messages for the current conversation.
  final List<Message> _messages = [];

  // A scroll controller to automatically scroll to the bottom of the list.
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Add a listener to handle incoming messages from the hub.
    // This listener will be a new instance and will be specific to this chat.
    widget.hubConnection.on('ReceiveMessage', _handleReceiveMessage);

    // Fetch the initial chat history for this specific conversation.
    _fetchChatHistory();
  }

  @override
  void dispose() {
    // Stop listening for messages when the widget is disposed.
    // This is crucial to prevent memory leaks and unexpected behavior.
    widget.hubConnection.off('ReceiveMessage');
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // --- SignalR Logic ---

  Future<void> _fetchChatHistory() async {
    try {
      // Invoke the 'GetConversationHistory' method on the hub, passing both user IDs.
      // The server will use these to fetch all messages between the two users.
      final history = await widget.hubConnection.invoke(
        'GetConversationHistory',
        args: [widget.otherUserId],
      );

      if (history != null) {
        final List<Message> parsedMessages = (history as List)
            .map((e) => Message(
                senderId: e['senderId'] as String,
                content: e['content'] as String,
                timestamp: DateTime.parse(e['timestamp'] as String),
                recipentId: e['recipientId'],
                senderAvatarUrl: e['senderAvatarUrl'],
                senderUserName: e['senderUsername'],
                isSender: e['isSender']))
            .toList();

        setState(() {
          _messages.addAll(parsedMessages);
          _isLoading = false;
          _errorMessage = null;
        });

        // Automatically scroll to the bottom after messages are loaded.
        _scrollToBottom();
      }
    } catch (e) {
      print("Error fetching chat history: $e");
      setState(() {
        _isLoading = false;
        _errorMessage = "Could not load messages. Please try again.";
      });
    }
  }

  void _handleReceiveMessage(List<Object?>? arguments) {
    if (arguments != null && arguments.isNotEmpty) {
      final messageData = arguments[0] as Map<String, dynamic>;
      final senderId = messageData['senderId'] as String;
      final receiverId = messageData['receiverId'] as String;
      final timeStamp = messageData['timeStamp'] as String;
      final otherUsername = messageData['otherUsername'] as String;
      final otherUserAvatarUrl = messageData['OtherUserAvatarUrl'] as String;
      final isSender = messageData['isSender'] as bool;
      // Only add the message to this screen if it's for this conversation.
      if ((senderId == widget.currentUserId &&
              receiverId == widget.otherUserId) ||
          (senderId == widget.otherUserId &&
              receiverId == widget.currentUserId)) {
        // Find the optimistic message in the list and update it with the official server timestamp
        // This is not the most robust way to handle this, but it will prevent duplicates for now.
        final existingMessageIndex =
            _messages.indexWhere((m) => m.timestamp == timeStamp);
        if (existingMessageIndex != -1) {
          // We've already shown this message optimistically, so do nothing.
          // You could update the timestamp here if needed, but for simplicity, we'll let it be.
        } else {
          // It's a new message from the other user, so add it.
          final newMessage = Message(
              senderId: senderId,
              content: messageData['content'] as String,
              timestamp: DateTime.parse(messageData['timestamp'] as String),
              recipentId: receiverId,
              senderAvatarUrl: otherUserAvatarUrl,
              senderUserName: otherUsername,
              isSender: isSender);

          setState(() {
            _messages.add(newMessage);
          });

          // Automatically scroll to the bottom when a new message arrives.
          _scrollToBottom();
        }
      }
    }
  }

  Future<void> _sendMessage() async {
    final messageContent = _messageController.text.trim();
    if (messageContent.isNotEmpty) {
      try {
        // Clear the text field immediately.
        _messageController.clear();

        // Invoke the 'SendMessage' method on the hub.
        // The server will handle storing the message and broadcasting it.
        await widget.hubConnection.invoke(
          'SendPrivateMessage',
          args: [widget.otherUserId, messageContent],
        );

        // Optionally, you can optimistically add the message to the list
        // and let the 'ReceiveMessage' listener update it with the official timestamp.
        // For simplicity, we'll let the listener handle the new message.
      } catch (e) {
        print("Error sending message: $e");
        // You could show a snackbar or an error message to the user here.
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    // Formats the timestamp for display in the chat bubble.
    return DateFormat('h:mm a').format(dateTime);
  }

  // --- UI Build Method ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 8,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.otherUserName,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          // A placeholder button for more options, like reporting.
          // You would implement this to open a modal sheet similar to your inbox screen.
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // TODO: Implement a modal bottom sheet for options like 'Report User'.
              // Example: showModalBottomSheet(context: context, builder: (context) => ...);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.orange)))
                : _errorMessage != null
                    ? Center(
                        child: Text(_errorMessage!,
                            style: const TextStyle(color: Colors.redAccent)))
                    : _messages.isEmpty
                        ? Center(
                            child: Text(
                                'Start a conversation with ${widget.otherUserName}',
                                style: TextStyle(color: Colors.grey.shade500)))
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(10.0),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final message = _messages[index];
                              return Align(
                                alignment: message.isSender
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 5.0, horizontal: 8.0),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 10.0),
                                  decoration: BoxDecoration(
                                    color: message.senderId.isNotEmpty
                                        ? Colors.redAccent.withOpacity(0.8)
                                        : Colors.grey.shade800,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(20),
                                      topRight: const Radius.circular(20),
                                      bottomLeft: message.senderId.isNotEmpty
                                          ? const Radius.circular(20)
                                          : const Radius.circular(5),
                                      bottomRight: message.senderId.isNotEmpty
                                          ? const Radius.circular(5)
                                          : const Radius.circular(20),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        message.content,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16.0),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatDateTime(message.timestamp),
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.6),
                                          fontSize: 10.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
          // Message input area
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 50.0),
            color: Colors.grey.shade900,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade800,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8.0),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
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
