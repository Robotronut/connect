import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:math';

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic> user;

  const ProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // List to hold the paths of the selected images
  List<String?> _imagePaths = [null, null, null, null, null];
  final ImagePicker _picker = ImagePicker();
  String _bio =
      'Some details about this person...'; // Initial bio, make it non-const
  final TextEditingController _bioController =
  TextEditingController(); // Controller for the TextField
  bool _isEditingBio =
  false; // Track if the user is currently editing the bio

  @override
  void initState() {
    super.initState();
    // Initialize the bioController with the initial bio text
    _bioController.text = _bio;
  }

  // Function to pick an image
  Future<void> _pickImage(int index) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagePaths[index] = pickedFile.path;
      });
    } else {
      print('No image selected.');
    }
  }

  // Function to handle editing the bio
  void _toggleEditBio() {
    setState(() {
      _isEditingBio = !_isEditingBio;
      if (!_isEditingBio) {
        // When done editing, update the bio
        _bio = _bioController.text;
      }
    });
  }

  @override
  void dispose() {
    _bioController.dispose(); // Dispose the controller to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final imageHeight = screenHeight * 0.5; // Height of the image grid
    final textTopPadding = 100.0 + imageHeight + 20;
    final availableHeight =
        screenHeight - textTopPadding - 80; // 80 for action buttons and padding

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              // Handle edit profile action
              print('Edit profile');
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Color
          Positioned.fill(
            child: Container(color: Colors.black),
          ),
          // Image Cards
          Positioned(
            top: 100.0,
            left: 16.0,
            right: 16.0,
            child: SizedBox(
              height: imageHeight, // Use the calculated image height
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 0.8,
                ),
                itemCount: _imagePaths.length,
                itemBuilder: (context, index) {
                  return _buildImageCard(index, context);
                },
              ),
            ),
          ),
          // Profile Details at the Bottom
          Positioned(
            left: 16.0,
            top: textTopPadding, // Position below the image grid.
            right: 16.0,
            child: SingleChildScrollView( // Wrap with SingleChildScrollView
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: availableHeight, // Use minHeight instead of maxHeight
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Add this line
                  children: [
                    Text(
                      widget.user['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    // Use a TextField for editing, and a Text for display
                    if (_isEditingBio)
                      TextField(
                        controller: _bioController,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 16.0),
                        maxLines:
                        null, // Allow multiple lines, and expand vertically
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(
                          border: InputBorder.none, // Remove the border
                        ),
                      )
                    else
                      Text(
                        _bio,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 16.0),
                      ),
                    const SizedBox(height: 16.0),
                    Row(
                      children: const [
                        Icon(Icons.location_on, color: Colors.white70),
                        SizedBox(width: 4.0),
                        Text('Some Location',
                            style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          color: widget.user['isOnline']
                              ? Colors.greenAccent
                              : Colors.grey,
                          size: 12.0,
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          widget.user['isOnline'] ? 'Online' : 'Offline',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                    // Conditionally show edit/done button
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _toggleEditBio,
                        child: Text(
                          _isEditingBio ? 'Done' : 'Edit Bio',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to build each image card
  Widget _buildImageCard(int index, BuildContext context) {
    // Calculate width based on screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 32) /
        2; // 32 for padding on both sides, 2 for 2 columns, and subtract spacing

    return GestureDetector(
      onTap: () => _pickImage(index),
      child: Container(
        width: cardWidth, // Use calculated width
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: Colors.white30,
            width: 2.0,
          ),
          image: _imagePaths[index] != null
              ? DecorationImage(
            image: FileImage(File(_imagePaths[index]!)),
            fit: BoxFit.cover,
          )
              : const DecorationImage(
            image: AssetImage('assets/placeholder.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: _imagePaths[index] == null
            ? const Center(
          child: Icon(Icons.add_a_photo, color: Colors.white70),
        )
            : null,
      ),
    );
  }
}

class grindr extends StatelessWidget {
  // List of common boy names
  final List<String> boyNames = const [
    "Liam",
    "Noah",
    "Oliver",
    "Elijah",
    "James",
    "William",
    "Benjamin",
    "Lucas",
    "Henry",
    "Alexander",
    "Jackson",
    "Sebastian",
    "Aiden",
    "Matthew",
    "Daniel",
    "Michael",
    "Ethan",
    "Jacob",
    "Logan",
    "David",
  ];

  // Generate random users
  List<Map<String, dynamic>> generateUsers() {
    final random = Random();
    return List.generate(140, (index) {
      String randomName = boyNames.elementAt(random.nextInt(boyNames.length));
      String imageName = "assets/auser_${(index % 14) + 1}.jpg";
      bool isOnline = random.nextBool();
      return {
        "name": randomName,
        "image": imageName,
        "isOnline": isOnline,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final users = generateUsers();
    final loggedInUser = users[0];

    // Define selected index for bottom navigation
    ValueNotifier<int> _selectedIndex = ValueNotifier(0);

    // Function to handle navigation
    void _onItemTapped(int index) {
      _selectedIndex.value = index; // update the selected index
      if (index == 2) {
        // If "Inbox" is tapped (index 2)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MessagingScreen(
              // Pass a list of users instead of just one.
              users: users,
              loggedInUser: loggedInUser,
              user: {},
            ),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: Container(
        color: Colors.black,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(
                            user: loggedInUser,
                          ),
                        ),
                      );
                    },
                    child: const CircleAvatar(
                      radius: 20.0,
                      backgroundImage: AssetImage(
                        'assets/auser_6.jpg',
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 8.0,
                  ),
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(
                        maxHeight: 30.0,
                      ),
                      child: TextField(
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Explore more profiles',
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(
                            0.1,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 1.0,
                            horizontal: 5.0,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              25.0,
                            ),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 30.0,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  const SizedBox(width: 8.0),
                  _buildPillButton(Icons.star_outline, "Favorite"),
                  _buildPillButton(Icons.cake, "Age"),
                  _buildPillButton(Icons.wifi, "Online"),
                  _buildPillButton(Icons.location_on, "Position"),
                  _buildPillButton(Icons.fiber_new, "Fresh"),
                  _buildPillButton(Icons.tag, "Tags"),
                  _buildPillButton(Icons.filter_list, "More Filters"),
                  const SizedBox(width: 8.0),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.black,
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 2.0,
                    mainAxisSpacing: 2.0,
                    childAspectRatio: 1,
                  ),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users.elementAt(index);
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfilePage(user: user),
                          ),
                        );
                      },
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              2.0,
                            ),
                            child: Image.asset(
                              user["image"]!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.9),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 8.0,
                            left: 8.0,
                            child: Row(
                              children: [
                                if (user["isOnline"] as bool) ...{
                                  Container(
                                    width: 10.0,
                                    height: 10.0,
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                },
                                const SizedBox(
                                  width: 4.0,
                                ),
                                Text(
                                  user["name"]!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: ValueListenableBuilder<int>(
        valueListenable: _selectedIndex,
        builder: (context, selectedIndex, child) {
          return BottomNavigationBar(
            backgroundColor: Colors.black,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey,
            currentIndex: selectedIndex, // Use the selectedIndex
            onTap: _onItemTapped, // Call _onItemTapped
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.apps),
                label: 'Browse',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.fire_extinguisher),
                label: 'Interest',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.message),
                label: 'Inbox',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.store),
                label: 'Store',
              ),
            ],
            type: BottomNavigationBarType.fixed,
          );
        },
      ),
    );
  }

  // Helper method to build pill buttons
  Widget _buildPillButton(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 4.0,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10.0,
          vertical: 0,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(
            0.1,
          ),
          borderRadius: BorderRadius.circular(25.0),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 12.0),
            const SizedBox(width: 4.0),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// New screen for messaging
class MessagingScreen extends StatefulWidget {
  final List<Map<String, dynamic>> users; // List of all users
  final Map<String, dynamic> loggedInUser;

  const MessagingScreen({Key? key, required this.users, required this.loggedInUser, required Map<String, dynamic> user}) : super(key: key);

  @override
  _MessagingScreenState createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  final List<Message> _messages = []; // List of messages in the chat
  final TextEditingController _messageController =
  TextEditingController(); // Controller for the message input
  final ScrollController _scrollController =
  ScrollController(); // Scroll controller to manage scrolling
  String _selectedUserId = ""; // Keep track of the selected user to chat with.

  @override
  void initState() {
    super.initState();
    // Initialize _selectedUserId with the first user in the list (or some default).
    if (widget.users.isNotEmpty) {
      _selectedUserId = widget.users[0]['name'];
    }
  }

  // Function to add a new message to the chat
  void _addMessage(String text, bool isMe, String userId) {
    if (text.trim().isNotEmpty) {
      setState(() {
        _messages.add(Message(text: text, isMe: isMe, userId: userId));
        _messageController.clear(); // Clear the input field
        // Scroll to the bottom after adding a new message:
        WidgetsBinding.instance?.addPostFrameCallback((_) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      });
    }
  }

  // Function to get messages for the selected user.
  List<Message> _getMessagesForUser(String userId) {
    return _messages.where((message) => message.userId == userId).toList();
  }

  @override
  void dispose() {
    _messageController.dispose(); // Dispose the text editing controller.
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Find the selected user's data.
    final selectedUser = widget.users.firstWhere(
          (user) => user['name'] == _selectedUserId,
      orElse: () => widget.loggedInUser, // Provide a default if not found
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20.0,
              backgroundImage: AssetImage(selectedUser['image'] ?? 'assets/placeholder.png'),
            ),
            const SizedBox(width: 8.0),
            Text(
              selectedUser['name'],
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        color: Colors.black,
        child: Row(
          children: <Widget>[
            // Left side: List of user profile pictures
            SizedBox(
              width: 150.0, // Increased width to accommodate name
              child: ListView.builder(
                itemCount: widget.users.length,
                itemBuilder: (context, index) {
                  final user = widget.users[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8), // Added horizontal padding
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedUserId = user['name']; // set the selected user ID.
                        });
                      },
                      child: Row( // Use a Row to layout image and text
                        children: [
                          CircleAvatar(
                            radius: 30.0,
                            backgroundImage: AssetImage(user['image']),
                            // Add a border to show which user is selected.
                            backgroundColor: _selectedUserId == user['name']
                                ? Colors.blue
                                : Colors.transparent,
                          ),
                          const SizedBox(width: 8), // Add some spacing
                          Text(
                            user['name'],
                            style: TextStyle(color: Colors.white), // Style the name
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Right side: Messages for the selected user
            Expanded(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: _getMessagesForUser(_selectedUserId).length,
                      itemBuilder: (context, index) {
                        final message = _getMessagesForUser(_selectedUserId)[index];
                        return _buildMessageBubble(message);
                      },
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                    ),
                  ),
                  _buildMessageInput(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to build a single message bubble
  Widget _buildMessageBubble(Message message) {
    final bool isMe = message.isMe;
    return Container(
      margin: EdgeInsets.only(
        top: 8.0,
        bottom: 8.0,
        left: isMe ? 64.0 : 16.0,
        right: isMe ? 16.0 : 64.0,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: isMe ? Colors.blue : Colors.grey[700],
      ),
      child: Text(
        message.text,
        style: const TextStyle(color: Colors.white, fontSize: 16.0),
      ),
    );
  }

  // Function to build the message input field
  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey[800], // A slightly lighter background
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Type your message...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none, // Remove the border
                ),
                filled: true,
                fillColor: Colors.grey[700], // Match bubble color
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              ),
              textInputAction: TextInputAction.send, // Change Enter behavior
              onSubmitted: (text) {
                _addMessage(text, true, _selectedUserId);
              },
            ),
          ),
          const SizedBox(width: 8.0),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.white),
            onPressed: () {
              _addMessage(_messageController.text, true, _selectedUserId);
            },
          ),
        ],
      ),
    );
  }
}

// Model class for a message
class Message {
  final String text;
  final bool isMe; // True if the message is from the current user
  final String userId; // Add the user id

  Message({required this.text, required this.isMe, required this.userId});
}
