import 'package:connect/screens/profile_screen.dart';
import 'package:connect/screens/report_screen.dart';
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
  final String senderUserName;
  final String senderAvatarUrl;
  final String recipientId;
  final String recipientUserName;
  final String recipientAvatarUrl;
  final String content;
  final DateTime timestamp;
  final bool isSender;

  Message(
      {required this.senderId,
      required this.senderAvatarUrl,
      required this.senderUserName,
      required this.recipientId,
      required this.recipientUserName,
      required this.recipientAvatarUrl,
      required this.content,
      required this.timestamp,
      required this.isSender});
}

// --- ChatScreen Widget ---
class ChatScreen extends StatefulWidget {
  final String chatHubUrl;
  final String currentUserId;
  final String currentUserName;
  final String currentUserImgUrl;
  final String otherUserId;
  final String otherUserImgUrl;
  final String otherUserName;
  final HubConnection hubConnection;

  const ChatScreen({
    Key? key,
    required this.chatHubUrl,
    required this.currentUserId,
    required this.currentUserName,
    required this.currentUserImgUrl,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserImgUrl,
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
    WidgetsBinding.instance.addPostFrameCallback((_) {});
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
        print(history);
        final List<Message> parsedMessages = (history as List)
            .map((e) => Message(
                senderId: e['senderId'],
                senderAvatarUrl: e['senderAvatarUrl'],
                senderUserName: e['senderUserName'],
                recipientId: e['recipientId'],
                recipientAvatarUrl: e['recipientAvatarUrl'],
                recipientUserName: e['recipientUserName'],
                content: e['content'],
                timestamp: DateTime.parse(e['timestamp'] as String),
                isSender: e['isSender']))
            .toList();

        setState(() {
          _messages.addAll(parsedMessages);
          _isLoading = false;
          _errorMessage = null;
        });

        // Automatically scroll to the bottom after messages are loaded.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
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
    if (arguments == null || arguments.isEmpty) return;

    final messageData = arguments[0] as Map<String, dynamic>;
    final String senderId = messageData['senderId'] as String;
    final String receiverId = messageData['receiverId'] as String;

    // Check if the message is part of the current conversation.
    if ((senderId == widget.currentUserId &&
            receiverId == widget.otherUserId) ||
        (senderId == widget.otherUserId &&
            receiverId == widget.currentUserId)) {
      // Safely parse the incoming message data.
      final String content = messageData['content'] as String;
      final DateTime timestamp =
          DateTime.parse(messageData['timestamp'] as String);

      // Determine who the sender is for THIS specific chat screen.
      final bool isSender = senderId == widget.currentUserId;

      // For now, let's just add the message if it's new.
      final newMessage = Message(
        senderId: senderId,
        senderAvatarUrl: (messageData['SenderAvatarUrl'] as String?) ?? '',
        senderUserName:
            (messageData['senderUsername'] as String?) ?? 'Unknown User',
        recipientId:
            receiverId, // NOTE: this is different from the JSON key `recipientId`
        recipientAvatarUrl:
            (messageData['OtherUserAvatarUrl'] as String?) ?? '',
        recipientUserName:
            (messageData['otherUsername'] as String?) ?? 'Unknown User',
        content: content,
        timestamp: timestamp,
        isSender: isSender,
      );

      // This is the crucial part that was missing or buggy.
      // The previous implementation had a flaw with the `indexWhere` on `timestamp`.
      // The simplest fix is to just add the message and let it show up.
      // Your `_sendMessage` function is already adding an optimistic one, so we need to be careful not to add duplicates.
      // A better approach is to use a message ID from the server.
      // Since you don't have one, let's just check if a message from the same sender with the same content exists nearby in time.
      final exists = _messages.any((m) =>
          m.senderId == newMessage.senderId &&
          m.content == newMessage.content &&
          m.timestamp.difference(newMessage.timestamp).abs().inSeconds < 2);

      if (!exists) {
        setState(() {
          _messages.add(newMessage);
        });
        _scrollToBottom();
      }
    } else {
      print('something is amist here ');
    }
  }

  Future<void> _sendMessage() async {
    final messageContent = _messageController.text.trim();
    if (messageContent.isNotEmpty) {
      // 1. Create a message object for optimistic display.
      final optimisticMessage = Message(
        senderId: widget.currentUserId,
        senderAvatarUrl:
            widget.currentUserImgUrl, // Provide the current user's avatar URL
        senderUserName: widget
            .currentUserName, // Provide the current user's username // It's from the current user
        content: messageContent,
        // Use a temporary timestamp; it will be replaced by the server's.
        timestamp: DateTime.now(),
        recipientId: widget.otherUserId,
        recipientAvatarUrl:
            widget.otherUserImgUrl, // Provide the current user's avatar URL
        recipientUserName:
            widget.otherUserName, // Provide the current user's username
        isSender: true,
      );

      // 2. Clear the text field and update the UI immediately.
      _messageController.clear();
      setState(() {
        _messages.add(optimisticMessage);
      });

      // Scroll to the bottom to show the new message
      _scrollToBottom();

      try {
        // 3. Send the message to the hub.
        await widget.hubConnection.invoke(
          'SendPrivateMessage',
          args: [widget.otherUserId, messageContent],
        );
      } catch (e) {
        print("Error sending message: $e");
        // TODO: Handle the error gracefully (e.g., remove the message from the list or show an error indicator).
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    // Formats the timestamp for display in the chat bubble.
    return DateFormat('h:mm a').format(dateTime);
  }

  // --- UI Build Method ---
  @override
  Widget build(BuildContext context) {
    // Get the safe area at the bottom of the device (e.g., for gesture navigators)
    final double bottomSafeArea = MediaQuery.of(context).padding.bottom;

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
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.black, // Match the app's dark theme
                builder: (BuildContext context) {
                  return SafeArea(
                    child: SizedBox(
                      height: 150, // Adjust height as needed
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            leading: const Icon(Icons.account_circle,
                                color: Colors.white),
                            title: const Text(
                              'Visit Profile',
                              style: TextStyle(color: Colors.white),
                            ),
                            onTap: () {
                              // Close the modal bottom sheet
                              Navigator.pop(context);
                              // Navigate to the user's profile screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProfileScreen(
                                    userId: widget
                                        .otherUserId, // Pass the other user's ID
                                  ),
                                ),
                              );
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.report_problem,
                                color: Colors.white),
                            title: const Text(
                              'Report User',
                              style: TextStyle(color: Colors.white),
                            ),
                            onTap: () {
                              // Close the modal bottom sheet
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReportScreen(
                                    reportedUserId: widget
                                        .otherUserId,
                                      reportedUsername: widget.otherUserName, // Pass the other user's ID
                                  ),
                                ),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('User reported.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
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
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.red)))
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

                              // Use the isSender property for all conditional styling
                              final bool isSender = message.isSender;

                              return Align(
                                alignment: isSender
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 5.0, horizontal: 4.0),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 5.0),
                                  decoration: BoxDecoration(
                                    color: isSender ? Colors.red : Colors.blue,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(10),
                                      topRight: const Radius.circular(10),
                                      bottomLeft: isSender
                                          ? const Radius.circular(10)
                                          : const Radius.circular(2),
                                      bottomRight: isSender
                                          ? const Radius.circular(2)
                                          : const Radius.circular(10),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: isSender
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        message.content,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14.0),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _formatDateTime(message.timestamp),
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.6),
                                          fontSize: 8.0,
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
          // Use a padding that accounts for the safe area at the bottom
          // This will prevent the input field from being hidden by the system navigation bar.
          Container(
            padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0 + bottomSafeArea),
            color: Colors.black,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(color: Colors.grey.shade900),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade800,
                      // Use vertical padding for a sensible text field height.
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8.0),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.red,
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
