import 'package:flutter/material.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {'text': 'Hello', 'isMe': false, 'time': '22:26'},
    {'text': 'How are you?', 'isMe': true, 'time': '22:30'},
    {'text': 'Looking for?', 'isMe': false, 'time': '22:39'},
  ];

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      setState(() {
        _messages.add({
          'text': _messageController.text,
          'isMe': true, // Assuming sent messages are from 'me'
          'time': '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        });
      });
      _messageController.clear();
    }
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
                    border: Border.all(color: Colors.blueAccent, width: 2), // Simulate location marker
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_on, color: Colors.blueAccent, size: 50),
                        const SizedBox(height: 10),
                        Text(
                          'Simulated Map Area',
                          style: TextStyle(color: Colors.grey[300], fontSize: 16),
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
                    backgroundColor: Colors.amber[700], // Orange color from image
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
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
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
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
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
                        child: const Text('Recently Sent', style: TextStyle(color: Colors.blueAccent)),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Trending', style: TextStyle(color: Colors.white)),
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
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                            style: const TextStyle(color: Colors.white, fontSize: 14),
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            // Implement back functionality
          },
        ),
        title: Row(
          children: [
            // User profile picture (placeholder)
            const CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(
                  'https://placehold.co/100x100/000000/FFFFFF?text=P'), // Placeholder image
            ),
            const SizedBox(width: 8),
            // Online indicator
            Stack(
              children: [
                const Text(
                  'Profile Name', // Placeholder name
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
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
            icon: const Icon(Icons.more_horiz),
            onPressed: _showMoreChatOptions, // Show more chat options
          ),
        ],
      ),
      body: Column(
        children: [
          // "Today" divider
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Text(
              'Today',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          // Chat messages list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment: message['isMe'] ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                    padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    decoration: BoxDecoration(
                      color: message['isMe'] ? Colors.blueAccent : Colors.grey[700],
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(15),
                        topRight: const Radius.circular(15),
                        bottomLeft: message['isMe']
                            ? const Radius.circular(15)
                            : const Radius.circular(0),
                        bottomRight: message['isMe']
                            ? const Radius.circular(0)
                            : const Radius.circular(15),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: message['isMe'] ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(
                          message['text'],
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          message['time'],
                          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10),
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
                          icon: const Icon(Icons.camera_alt, color: Colors.grey),
                          onPressed: _showMediaOptions, // Show media options
                        ),
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Say something...',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
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
                    color: Colors.grey, // Grey color for microphone icon button
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
          // Bottom Navigation Bar with additional options
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
        ],
      ),
    );
  }

  // Helper widget for bottom navigation items
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

