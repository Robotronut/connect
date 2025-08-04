import 'package:connect/screens/profile_screen.dart';
import 'package:connect/screens/report_screen.dart';
import 'package:connect/screens/video_chat_screen.dart';
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
  // ... (your existing constructor) ...
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
    // Register the video call listeners here, as they are crucial for the ChatScreen's logic.
    widget.hubConnection.on('ReceiveVideoCallInvitation', _handleVideoCallInvitation);
    widget.hubConnection.on('VideoCallAccepted', _handleVideoCallAccepted);
    widget.hubConnection.on('VideoCallRejected', _handleVideoCallRejected);

    // Add the message listener back in, as you removed it.
    widget.hubConnection.on('ReceiveMessage', _handleReceiveMessage);

    _fetchChatHistory();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  void _handleVideoCallAccepted(List<Object?>? args) {
    // This is called on the caller's device when the callee accepts.
    Navigator.pop(context); // Close the "Calling..." dialog

    // Now that the call is accepted, navigate to the video screen.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoChatScreen(
            hubConnection: widget.hubConnection,
            currentUserId: widget.currentUserId,
            otherUserId: widget.otherUserId,
            isCallInitiated: true),
      ),
    );
  }

  void _handleVideoCallRejected(List<Object?>? args) {
    // This is called on the caller's device when the callee rejects.
    Navigator.pop(context); // Close the "Calling..." dialog

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Video call rejected.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleVideoCallInvitation(List<Object?>? args) {
    if (args == null || args.isEmpty) return;
    final String callerId = args[0] as String;

    // Only handle the invitation if it's from the person we're currently chatting with.
    if (callerId != widget.otherUserId) {
      // You might want to handle this case differently, e.g., show a toast.
      return;
    }

    // This is the correct location for the dialog logic.
    // The previous code had a nested method definition here.
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Incoming Video Call'),
        content: Text('Call from user: ${widget.otherUserName}'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close the dialog
              await widget.hubConnection.invoke('RejectVideoCall', args: [callerId]);
            },
            child: const Text('Reject'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close the dialog
              await widget.hubConnection.invoke('AcceptVideoCall', args: [callerId]);
              // Callee navigates here, after accepting.
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoChatScreen(
                      hubConnection: widget.hubConnection,
                      currentUserId: widget.currentUserId,
                      otherUserId: callerId,
                      isCallInitiated: false),
                ),
              );
            },
            child: const Text('Accept'),
          ),
        ],
      ),
    );
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
    // Also stop listening to the video call events.
    widget.hubConnection.off('ReceiveVideoCallInvitation');
    widget.hubConnection.off('VideoCallAccepted');
    widget.hubConnection.off('VideoCallRejected');

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

      // Add the message to the list.
      // The previous duplicate check is removed as we are no longer optimistically adding.
      setState(() {
        _messages.add(newMessage);
      });
      _scrollToBottom();
    } else {
      print('something is amist here ');
    }
  }

  Future<void> _sendMessage() async {
    final messageContent = _messageController.text.trim();
    if (messageContent.isNotEmpty) {
      // Clear the text field immediately.
      _messageController.clear();

      try {
        // Send the message to the hub.
        // The message will be added to the _messages list when the server broadcasts it back
        // via the _handleReceiveMessage callback.
        await widget.hubConnection.invoke(
          'SendPrivateMessage',
          args: [widget.otherUserId, messageContent],
        );
      } catch (e) {
        print("Error sending message: $e");
        // TODO: Handle the error gracefully (e.g., show an error message to the user).
      }
    }
  }

  void _startVideoCall() async {
    try {
      // 1. Send the invitation.
      await widget.hubConnection.invoke('InviteToVideoCall', args: [widget.otherUserId]);

      // 2. Show a dialog indicating the call is in progress.
      // Do NOT navigate yet.
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Calling...'),
          content: Text('Waiting for ${widget.otherUserName} to answer.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                // TODO: You may want to send a 'CancelCall' message to the hub here.
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      );

      // The `_handleVideoCallAccepted` listener will handle navigation to `VideoChatScreen`
      // if the callee accepts the call.
    } catch (e) {
      print('Tylar: Failed to send video call invitation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start call. Error: $e')),
      );
    }
  }

  // New method to handle blocking a user
  Future<void> _blockUser() async {
    Navigator.pop(context); // Close the modal bottom sheet first

    try {
      // Show a confirmation dialog before blocking
      final bool? confirmBlock = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Block User?'),
          content: Text('Are you sure you want to block ${widget.otherUserName}? You will no longer receive messages from them.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false), // User cancels
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true), // User confirms
              child: const Text('Block'),
            ),
          ],
        ),
      );

      if (confirmBlock == true) {
        // Invoke the SignalR hub method to block the user
        await widget.hubConnection.invoke(
          'BlockUser',
          args: [widget.otherUserId],
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.otherUserName} has been blocked.'),
            backgroundColor: Colors.red,
          ),
        );

        // Optionally, navigate back or clear chat history after blocking
        Navigator.pop(context); // Go back from the chat screen
      }
    } catch (e) {
      print("Error blocking user: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to block user. Error: $e'),
          backgroundColor: Colors.red,
        ),
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
                      height: 200, // Adjust height as needed to fit new option
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
                                    reportedUserId: widget.otherUserId,
                                    reportedUsername: widget
                                        .otherUserName, // Pass the other user's ID
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
                          ListTile(
                            leading: const Icon(Icons.block,
                                color: Colors.white), // Block icon
                            title: const Text(
                              'Block User',
                              style: TextStyle(color: Colors.white),
                            ),
                            onTap: _blockUser, // Call the new block user method
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          // New video call button
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.white),
            onPressed: () {
              // TODO: Implement the call invitation logic
              // For now, let's just navigate to the video screen
              _startVideoCall();
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
