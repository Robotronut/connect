import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart'; // For scroll controller

// --- Models ---
// A simple model for a User profile
class User {
  final String id;
  final String name;
  final String? profileImageUrl;

  User({required this.id, required this.name, this.profileImageUrl});
}

// A simple model for a Chat Message
class Message {
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isMe; // True if the current user sent the message

  Message({
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.isMe = false,
  });
}

// --- Chat Screen Widget ---
class ChatScreen extends StatefulWidget {
  final String
      userId; // The ID of the user whose profile we are viewing/chatting with
  final String currentUserId; // The ID of the currently logged-in user

  const ChatScreen({
    Key? key,
    required this.userId,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  User? _userProfile;
  String? _errorMessage;
  bool _isLoadingProfile = true;
  bool _isOwnProfile = false;

  final List<Message> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMessages = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Simulates fetching user profile data
  Future<void> _loadProfileData() async {
    setState(() {
      _isLoadingProfile = true;
      _errorMessage = null;
    });

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Simulate different scenarios based on userId
      if (widget.userId == 'error_user') {
        throw Exception('Failed to load user profile: Network error.');
      } else if (widget.userId == 'not_found') {
        _userProfile = null; // Profile not found
      } else {
        // Simulate a successful profile load
        _userProfile = User(
          id: widget.userId,
          name: 'John Doe',
          profileImageUrl:
              'https://placehold.co/100x100/000000/FFFFFF?text=JD', // Placeholder
        );

        // Determine if it's the current user's own profile
        _isOwnProfile = (widget.userId == widget.currentUserId);
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      setState(() {
        _isLoadingProfile = false;
      });
    }
  }

  // Simulates fetching chat messages
  Future<void> _loadMessages() async {
    setState(() {
      _isLoadingMessages = true;
    });

    try {
      await Future.delayed(
          const Duration(seconds: 2)); // Simulate message loading delay

      // Clear existing messages and add simulated ones
      _messages.clear();
      _messages.addAll([
        Message(
            senderId: widget.userId,
            text: 'Hello there!',
            timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
            isMe: false),
        Message(
            senderId: widget.currentUserId,
            text: 'Hi! How are you doing?',
            timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
            isMe: true),
        Message(
            senderId: widget.userId,
            text: 'I\'m great, thanks! Just chilling.',
            timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
            isMe: false),
        Message(
            senderId: widget.currentUserId,
            text: 'Nice! What\'s up?',
            timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
            isMe: true),
        Message(
            senderId: widget.userId,
            text: 'Not much, just coding a bit. What about you?',
            timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
            isMe: false),
        Message(
            senderId: widget.currentUserId,
            text: 'Same here, trying to get this chat screen working!',
            timestamp: DateTime.now(),
            isMe: true),
      ]);

      // Scroll to the bottom after messages are loaded
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    } catch (e) {
      _errorMessage = 'Failed to load messages: $e';
    } finally {
      setState(() {
        _isLoadingMessages = false;
      });
    }
  }

  // Handles sending a new message
  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      setState(() {
        _messages.add(
          Message(
            senderId: widget.currentUserId,
            text: _messageController.text,
            timestamp: DateTime.now(),
            isMe: true,
          ),
        );
        _messageController.clear(); // Clear the text input
      });
      // Scroll to the new message after it's added
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- Error and Loading States based on provided layout ---
    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Center(
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_userProfile == null && !_isLoadingProfile) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: const Center(
          child: Text(
            'Profile not found.',
            style: TextStyle(color: Colors.grey, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // --- Main Chat Screen Layout ---
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: _isLoadingProfile
            ? const CircularProgressIndicator(color: Colors.white)
            : Row(
                children: [
                  CircleAvatar(
                    backgroundImage: _userProfile?.profileImageUrl != null
                        ? NetworkImage(_userProfile!.profileImageUrl!)
                        : null,
                    backgroundColor: Colors.grey[800],
                    child: _userProfile?.profileImageUrl == null
                        ? Text(
                            _userProfile?.name[0].toUpperCase() ?? '',
                            style: const TextStyle(color: Colors.white),
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _userProfile?.name ?? 'Loading...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
        actions: [
          if (_isOwnProfile)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () async {
                // Navigate to a placeholder EditProfileScreen
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const EditProfileScreen()),
                );
                _loadProfileData(); // Refresh data after editing
              },
            ),
          if (!_isOwnProfile) ...[
            IconButton(
              icon: const Icon(Icons.person_outline, color: Colors.white),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Reporting user... (Not implemented)')),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.star_border, color: Colors.white),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Super Liking user... (Not implemented)')),
                );
              },
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoadingMessages
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 15),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return MessageBubble(message: message);
                    },
                  ),
          ),
          _buildMessageInput(), // Message input field
        ],
      ),
    );
  }

  // Builds the message input field at the bottom
  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.grey[900], // Dark background for input area
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              onSubmitted: (_) => _sendMessage(), // Send message on enter key
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: _sendMessage,
            backgroundColor: Colors.blueAccent, // Send button color
            mini: true,
            child: const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

// --- Message Bubble Widget ---
class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isMe = message.isMe;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: isMe
              ? Colors.blueAccent
              : Colors.grey[700], // Different colors for sent/received
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            topRight: const Radius.circular(15),
            bottomLeft:
                isMe ? const Radius.circular(15) : const Radius.circular(0),
            bottomRight:
                isMe ? const Radius.circular(0) : const Radius.circular(15),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
              style: TextStyle(color: Colors.grey[400], fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Placeholder Edit Profile Screen ---
// This is a simple screen to satisfy the navigation in the AppBar.
class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title:
            const Text('Edit Profile', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: const Center(
        child: Text(
          'Edit Profile functionality goes here.',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}

// --- How to use this in your main.dart or a similar file ---
/*
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      theme: ThemeData.dark(), // Use a dark theme for consistency
      home: const ChatScreen(
        userId: 'some_other_user_id', // ID of the user you are chatting with
        currentUserId: 'my_user_id', // Your logged-in user ID
      ),
      // You can test different states by changing userId:
      // home: const ChatScreen(userId: 'error_user', currentUserId: 'my_user_id'),
      // home: const ChatScreen(userId: 'not_found', currentUserId: 'my_user_id'),
      // home: const ChatScreen(userId: 'my_user_id', currentUserId: 'my_user_id'), // To test own profile
    );
  }
}
*/
