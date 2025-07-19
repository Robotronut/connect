import 'package:flutter/material.dart';
import 'package:connect/services/api_service.dart'; // Import your ApiService
import 'package:connect/services/secure_storage_service.dart'; // Import SecureStorageService

class MessageScreen extends StatefulWidget {
  // Optional parameter to directly open a chat with a specific user
  final Map<String, dynamic>? initialChatUser;

  const MessageScreen({super.key, this.initialChatUser});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  // Stores the currently selected user for chat, null if showing inbox list
  Map<String, dynamic>? _currentChatUser;

  // List to hold actual Message objects
  final List<Message> _messages = [];
  bool _isLoadingHistory = false; // New state for loading history

  // Mock list of users/conversations for the inbox
  final List<Map<String, dynamic>> _mockConversations = [
    {
      'id': 'user1',
      'name': 'Alice',
      'lastMessage': 'Hey there!',
      'time': '10:30 AM',
      'unread': 2,
      'isOnline': true,
      'profilePic': 'https://placehold.co/100x100/FF5733/FFFFFF?text=A',
      'email': 'alice@example.com' // Added email for SignalR
    },
    {
      'id': 'user2',
      'name': 'Bob',
      'lastMessage': 'Sounds good, see you then.',
      'time': 'Yesterday',
      'unread': 0,
      'isOnline': false,
      'profilePic': 'https://placehold.co/100x100/33FF57/FFFFFF?text=B',
      'email': 'bob@example.com' // Added email for SignalR
    },
    {
      'id': 'user3',
      'name': 'Charlie',
      'lastMessage': 'Don\'t forget the meeting.',
      'time': 'Mon',
      'unread': 0,
      'isOnline': true,
      'profilePic': 'https://placehold.co/100x100/3357FF/FFFFFF?text=C',
      'email': 'charlie@example.com' // Added email for SignalR
    },
    {
      'id': 'user4',
      'name': 'Diana',
      'lastMessage': 'Got it!',
      'time': '2 days ago',
      'unread': 1,
      'isOnline': false,
      'profilePic': 'https://placehold.co/100x100/FF33CC/FFFFFF?text=D',
      'email': 'diana@example.com' // Added email for SignalR
    },
  ];

  String? _currentUserEmail; // Store the current logged-in user's email

  @override
  void initState() {
    super.initState();
    _initializeChat();
    _listenForNewMessages();
  }

  @override
  void dispose() {
    // No need to stop SignalR here if it's a global service managed by MainBrowseScreen
    // ApiService.stopSignalR(); // Only if SignalR connection is managed per screen
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    _currentUserEmail = await SecureStorageService.getEmail();
    print(
        'MessageScreen: Current User Email: $_currentUserEmail'); // Debug print
    setState(() {
      _currentChatUser = widget.initialChatUser;
    });
    print('MessageScreen: Initial Chat User: $_currentChatUser'); // Debug print
    _currentChatUser!['email'] = "user1@example.com";
    // Fetch historical messages here for _currentChatUser if it's not null
    if (_currentChatUser != null && _currentUserEmail != null) {
      _fetchChatHistory(_currentUserEmail!, _currentChatUser!['email']);
    }
  }

  Future<void> _fetchChatHistory(String userId, String user2Email,
      {int count = 5, int offset = 0}) async {
    setState(() {
      _isLoadingHistory = true;
      _messages.clear(); // Clear existing messages before loading history
    });
    try {
      final fetchedMessages =
          await ApiService.fetchChatHistory(userId, user2Email);
      setState(() {
        _messages.addAll(fetchedMessages);
        _isLoadingHistory = false;
      });
      print(
          'MessageScreen: Fetched ${fetchedMessages.length} messages.'); // Debug print
    } catch (e) {
      print('MessageScreen: Error fetching chat history: $e'); // Debug print
      setState(() {
        _isLoadingHistory = false;
        // Optionally show an error message to the user
      });
    }
  }

  void _listenForNewMessages() {
    ApiService.onNewMessage.listen((message) {
      print(
          'MessageScreen: Received new message from stream: ${message.content}'); // Debug print
      // Only add message to current chat if it's relevant
      // (either sent by current user, or received from current chat partner)
      if (message.senderId == _currentChatUser?['email'] ||
          (message.recipientId == "" &&
              message.senderId == _currentChatUser?['email'])) {
        setState(() {
          _messages.add(message);
        });
      }
      // You might also want to update the last message in _mockConversations
      // for the inbox view if the message is for a different chat.
    });
  }

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty &&
        _currentChatUser != null &&
        _currentUserEmail != null) {
      final String messageContent = _messageController.text;
      final String recipientEmail = _currentChatUser!['email'];

      print(
          'MessageScreen: Attempting to send message: "$messageContent"'); // Debug print
      print(
          'MessageScreen: Sender: $_currentUserEmail, Recipient: $recipientEmail'); // Debug print

      // Add message to local list immediately for optimistic UI update
      setState(() {
        _messages.add(
          Message(
            id: UniqueKey().toString(), // Client-side ID
            senderId: _currentUserEmail!,
            recipientId: recipientEmail,
            content: messageContent,
            timestamp: DateTime.now(),
          ),
        );
      });
      _messageController.clear();

      // Send message via SignalR
      await ApiService.sendChatMessage(
        senderId: _currentUserEmail!,
        recipientId: recipientEmail,
        content: messageContent,
      );
    } else {
      print(
          'MessageScreen: Cannot send message. Conditions not met:'); // Debug print
      print('  Text empty: ${_messageController.text.isEmpty}');
      print('  _currentChatUser is null: ${_currentChatUser == null}');
      print('  _currentUserEmail is null: ${_currentUserEmail == null}');
    }
  }

  // Function to handle tapping on a user in the inbox list
  void _onUserTap(Map<String, dynamic> user) {
    setState(() {
      _currentChatUser = user;
      if (_currentUserEmail != null) {
        _fetchChatHistory(_currentUserEmail!, _currentChatUser!['email']);
      }
    });
  }

  // Function to show the media options bottom sheet
  void _showMediaOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[850], // Darker background for bottom sheet
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Media title
              Container(
                height: 5,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Media',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Grid of media options
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                children: [
                  _buildMediaOption(Icons.camera_alt, 'Take Photo'),
                  _buildMediaOption(Icons.photo_library, 'Camera Roll'),
                  _buildMediaOption(Icons.video_camera_back, 'Video'),
                  _buildMediaOption(Icons.create_new_folder, 'Create Album'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper widget for media options
  Widget _buildMediaOption(IconData icon, String text) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.grey[700],
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, size: 30, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(text, style: const TextStyle(color: Colors.white)),
      ],
    );
  }

  // Function to show the location sharing bottom sheet
  void _showLocationOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[850],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Handle at the top
              Container(
                height: 5,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Location',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              // Safety guide
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, color: Colors.grey[400], size: 18),
                  const SizedBox(width: 5),
                  Text(
                    'Grindr Safety Guide', // Placeholder text
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              // Simplified map view (placeholder)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                        color: Colors.blueAccent,
                        width: 2), // Simulate location marker
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_on,
                            color: Colors.blueAccent, size: 50),
                        const SizedBox(height: 10),
                        Text(
                          'Simulated Map Area',
                          style:
                              TextStyle(color: Colors.grey[300], fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Send Current Location button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Logic to send current location
                    Navigator.pop(context); // Close bottom sheet
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.amber[700], // Orange color from image
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text(
                    'Send Current Location',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'At any time, you can send or unsend this location',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '©Maps Legal', // Placeholder
                  style: TextStyle(color: Colors.grey[600], fontSize: 10),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to show the GIF options bottom sheet
  void _showGifOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[850],
      isScrollControlled: true, // Allow it to take full height if needed
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8, // Initial height of the bottom sheet
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false, // Don't expand to full screen initially
          builder: (_, controller) {
            return Column(
              children: <Widget>[
                // Handle at the top
                Container(
                  height: 5,
                  width: 40,
                  margin: const EdgeInsets.only(top: 10, bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10),
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      hintText: 'Search GIPHY',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.grey[700],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                // Categories/Tabs
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: const Text('Recently Sent',
                            style: TextStyle(color: Colors.blueAccent)),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Trending',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // GIF Grid (mocked)
                Expanded(
                  child: GridView.builder(
                    controller: controller, // Link controller to grid view
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.0, // Square aspect ratio for images
                    ),
                    itemCount: 8, // Number of mocked GIFs
                    itemBuilder: (context, index) {
                      // Mock GIF images - replace with actual GIF loading if integrated
                      final List<String> mockGifTitles = [
                        'Happy Family',
                        'Father\'s Day Beer',
                        'Birthday Cake',
                        'Happy Father\'s Day',
                        'Cute Cat',
                        'Happy F♡THER\'S DAY',
                        'Red Heart Kiss',
                        'Gift Box',
                      ];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[700],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            mockGifTitles[index],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // GIF tag at the bottom
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0, top: 10),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Text(
                      'GIF',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Function to show more chat options (Received Photos, Block, Report, Spam)
  void _showMoreChatOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[850],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Handle at the top
              Container(
                height: 5,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              // Options grid
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 4,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                children: [
                  _buildOptionIcon(Icons.photo, 'Received Photos'),
                  _buildOptionIcon(Icons.block, 'Block'),
                  _buildOptionIcon(Icons.flag, 'Report'),
                  _buildOptionIcon(Icons.report_problem, 'Spam'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper widget for general options icon
  Widget _buildOptionIcon(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Colors.white),
        const SizedBox(height: 8),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set the background to black
      appBar: AppBar(
        backgroundColor: Colors.black, // Ensure app bar is also black
        leading: _currentChatUser == null
            ? null // No back arrow when on the inbox list
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () {
                  // If currently in a chat, go back to the inbox list
                  setState(() {
                    _currentChatUser = null;
                    _messages
                        .clear(); // Clear messages when going back to inbox
                  });
                },
              ),
        title: _currentChatUser == null
            ? const Text(
                'Inbox', // Title for the inbox list
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              )
            : Row(
                children: [
                  // User profile picture for the current chat
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(_currentChatUser![
                            'profilePic'] ??
                        'https://placehold.co/100x100/000000/FFFFFF?text=P'),
                  ),
                  const SizedBox(width: 8),
                  // Online indicator
                  Stack(
                    children: [
                      Text(
                        _currentChatUser![
                            'name'], // Display current chat user's name
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      if (_currentChatUser!['isOnline'])
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.greenAccent,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz,
                color: Colors.white), // Set icon color to white
            onPressed: _showMoreChatOptions, // Show more chat options
          ),
        ],
      ),
      body: _currentChatUser == null
          ? ListView.builder(
              // Display the list of conversations (inbox)
              itemCount: _mockConversations.length,
              itemBuilder: (context, index) {
                final conversation = _mockConversations[index];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(conversation['profilePic']),
                  ),
                  title: Text(
                    conversation['name'],
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    conversation['lastMessage'],
                    style: TextStyle(color: Colors.grey[400]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        conversation['time'],
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                      if (conversation['unread'] > 0)
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            conversation['unread'].toString(),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 10),
                          ),
                        ),
                    ],
                  ),
                  onTap: () =>
                      _onUserTap(conversation), // Navigate to chat on tap
                );
              },
            )
          : Column(
              // Display the chat messages for the selected user
              children: [
                // "Today" divider
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    'Today',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ),
                // Loading indicator for chat history
                if (_isLoadingHistory)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                // Chat messages list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      // Determine if the message is from the current user
                      final bool isMe = message.senderId == _currentUserEmail;

                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 8),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blueAccent : Colors.grey[700],
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(15),
                              topRight: const Radius.circular(15),
                              bottomLeft: isMe
                                  ? const Radius.circular(15)
                                  : const Radius.circular(0),
                              bottomRight: isMe
                                  ? const Radius.circular(0)
                                  : const Radius.circular(15),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: isMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.content,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Message input area
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              // Camera icon
                              IconButton(
                                icon: const Icon(Icons.camera_alt,
                                    color: Colors.grey),
                                onPressed:
                                    _showMediaOptions, // Show media options
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _messageController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: 'Say something...',
                                    hintStyle:
                                        TextStyle(color: Colors.grey[400]),
                                    border: InputBorder.none,
                                    filled:
                                        true, // Ensure the TextField itself is filled
                                    fillColor: Colors.grey[
                                        700], // Set a distinct fill color for visibility
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                  ),
                                  onSubmitted: (_) => _sendMessage(),
                                ),
                              ),
                              // Emoji icon
                              IconButton(
                                icon: const Icon(Icons.sentiment_satisfied_alt,
                                    color: Colors.grey),
                                onPressed: () {
                                  // Implement emoji picker
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Send button
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: _sendMessage,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Microphone icon
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors
                              .grey, // Grey color for microphone icon button
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.mic, color: Colors.white),
                          onPressed: () {
                            // Implement voice message recording
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // Bottom Navigation Bar with additional options (only for chat view)
                // This section is commented out as the main app now manages the global BottomNavigationBar.
                /*
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black, // Match background
                    border: Border(
                      top: BorderSide(color: Colors.grey[900]!, width: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildBottomNavItem(Icons.camera_alt, 'Camera', _showMediaOptions), // Re-using for demonstration
                      _buildBottomNavItem(Icons.location_on, 'Location', _showLocationOptions),
                      _buildBottomNavItem(Icons.gif_box, 'GIF', _showGifOptions),
                      _buildBottomNavItem(Icons.photo, 'Photos', () {
                        // Navigate to photos or show relevant modal
                      }),
                      _buildBottomNavItem(Icons.chat_bubble, 'Messages', () {
                        // Navigate to messages
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 10), // Space for home indicator
                */
              ],
            ),
    );
  }

  // Helper widget for bottom navigation items (kept for other bottom sheets if needed)
  Widget _buildBottomNavItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.grey, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
