import 'package:flutter/material.dart';
import 'dart:math';
import 'package:image_picker/image_picker.dart'; // Import the image_picker package

class grindr extends StatelessWidget {
  final List<String> boyNames = [
    "Liam", "Noah", "Oliver", "Elijah", "James", "William", "Benjamin", "Lucas",
    "Henry", "Alexander", "Jackson", "Sebastian", "Aiden", "Matthew", "Daniel",
    "Michael", "Ethan", "Jacob", "Logan", "David",
  ];

  List<Map<String, dynamic>> generateUsers() {
    final random = Random();
    return List.generate(140, (index) {
      String randomName = boyNames[random.nextInt(boyNames.length)];
      String imageName = "assets/auser_${(index % 14) + 1}.jpg";
      bool isOnline = random.nextBool();
      int age = random.nextInt(40) + 18;
      String bio = _generateBio(randomName, age);
      List<String> interests = _generateInterests();
      // Simulate recent messages
      List<Map<String, String>> recentMessages = List.generate(
        random.nextInt(5), // Generate between 0 and 4 messages
            (i) => {
          'sender': random.nextBool() ? 'self' : 'other',
          'text': _generateRandomMessage(),
          'timestamp': DateTime.now()
              .subtract(Duration(minutes: random.nextInt(120)))
              .toIso8601String(),
        },
      );
      return {
        "name": randomName,
        "image": imageName,
        "isOnline": isOnline,
        "age": age,
        "bio": bio,
        "interests": interests,
        "recentMessages": recentMessages,
      };
    });
  }

  String _generateBio(String name, int age) {
    final random = Random();
    final bios = [
      "Just looking to chat and see where things go.",
      "Into fitness, good food, and even better company.",
      "Seeking genuine connections. Let's grab a coffee?",
      "Adventurous soul, always up for exploring new things.",
      "Quiet and thoughtful. Open to interesting conversations.",
      "Love music, art, and deep talks.",
      "Working hard, playing harder. Let's connect!",
      "Sarcastic and fun-loving. Don't be shy!",
      "Looking for friends and maybe more.",
      "Enjoying life one day at a time.",
    ];
    return "${bios[random.nextInt(bios.length)]} I'm $age.";
  }

  List<String> _generateInterests() {
    final random = Random();
    final allInterests = [
      "Hiking", "Gaming", "Cooking", "Reading", "Traveling", "Photography",
      "Music", "Movies", "Art", "Sports", "Technology", "Coffee", "Animals",
      "Yoga", "Meditation",
    ];
    final numberOfInterests = random.nextInt(3) + 1;
    return (List.generate(allInterests.length, (index) => index)..shuffle())
        .take(numberOfInterests)
        .map((index) => allInterests[index])
        .toList();
  }

  String _generateRandomMessage() {
    final random = Random();
    final messages = [
      "Hey!", "How's it going?", "What are you up to?", "Nice profile!",
      "Interested in chatting?", "Good vibes only.",
      "Long message to test how the text wrapping works. This should take up multiple lines.",
      "Okay", "Sounds good", "See you later!", "👋", "😄",
    ];
    return messages[random.nextInt(messages.length)];
  }

  @override
  Widget build(BuildContext context) {
    final users = generateUsers();
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
                  // Navigate to EditProfileScreen when the user taps on their profile picture
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfileScreen(),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 20.0,
                      backgroundImage: AssetImage('assets/auser_6.jpg'),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: Container(
                      constraints: BoxConstraints(maxHeight: 30.0),
                      child: TextField(
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Explore more profiles',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                          prefixIcon:
                          Icon(Icons.search, color: Colors.white.withOpacity(0.9)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          contentPadding:
                          EdgeInsets.symmetric(vertical: 1.0, horizontal: 5.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
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
                  SizedBox(width: 8.0),
                  _buildPillButton(Icons.star_outline, "Favorite"),
                  _buildPillButton(Icons.cake, "Age"),
                  _buildPillButton(Icons.wifi, "Online"),
                  _buildPillButton(Icons.location_on, "Position"),
                  _buildPillButton(Icons.fiber_new, "Fresh"),
                  _buildPillButton(Icons.tag, "Tags"),
                  _buildPillButton(Icons.filter_list, "More Filters"),
                  SizedBox(width: 8.0),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.black,
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 2.0,
                    mainAxisSpacing: 2.0,
                    childAspectRatio: 1,
                  ),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MessagingScreen(user: user),
                          ),
                        );
                      },
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2.0),
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
                                    Colors.transparent
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
                                if (user["isOnline"]) ...[
                                  Container(
                                    width: 10.0,
                                    height: 10.0,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                                SizedBox(width: 4.0),
                                Text(
                                  user["name"]!,
                                  style: TextStyle(
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.apps), label: 'Browse'),
          BottomNavigationBarItem(
              icon: Icon(Icons.fire_extinguisher), label: 'Interest'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Inbox'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Store'),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Widget _buildPillButton(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(25.0),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 12.0),
            SizedBox(width: 4.0),
            Text(
              label,
              style: TextStyle(color: Colors.white, fontSize: 10.0),
            ),
          ],
        ),
      ),
    );
  }
}

class MessagingScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const MessagingScreen({super.key, required this.user});

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [];

  @override
  void initState() {
    super.initState();
    // Load recent messages for this user
    if (widget.user.containsKey('recentMessages') &&
        widget.user['recentMessages'] is List) {
      _messages.addAll(
          List<Map<String, String>>.from(widget.user['recentMessages']));
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add({
          'sender': 'self',
          'text': _messageController.text.trim(),
          'timestamp': DateTime.now().toIso8601String(),
        });
        _messageController.clear();
      });
      // In a real app, you would send this message to the server
    }
  }

  String _formatTimestamp(String timestamp) {
    DateTime messageTime = DateTime.parse(timestamp);
    DateTime now = DateTime.now();
    Duration difference = now.difference(messageTime);

    if (difference.inDays > 1) {
      return "${messageTime.day}/${messageTime.month}/${messageTime.year}";
    } else if (difference.inHours > 1) {
      return "${difference.inHours} hours ago";
    } else if (difference.inMinutes > 1) {
      return "${difference.inMinutes} minutes ago";
    } else {
      return "Just now";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18.0,
              backgroundImage: AssetImage(widget.user['image']!),
            ),
            SizedBox(width: 10.0),
            Text(
              widget.user['name']!,
              style:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                final isSelf = message['sender'] == 'self';
                return Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  child: Align(
                    alignment: isSelf ? Alignment.topRight : Alignment.topLeft,
                    child: Column(
                      crossAxisAlignment:
                      isSelf ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: isSelf
                                ? Colors.blue
                                : Colors
                                .white
                                .withOpacity(0.1), // Use Grindr blue for sent messages
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            message['text']!,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          _formatTimestamp(message['timestamp']!),
                          style: TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: TextField(
                        controller: _messageController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Send a message...',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                CircleAvatar(
                  backgroundColor:
                  Colors.blue, // Grindr-like send button color
                  radius: 25.0,
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
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

// new widget for the edit profile screen
class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // text editing controllers for the text fields
  final TextEditingController _bioController = TextEditingController();
  // list of images.  The first image is the profile image.
  List<String> _imageUrls = ['assets/auser_6.jpg']; // start with the default image
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // set the initial value of the bio text field.
    _bioController.text =
    "Just looking to chat and see where things go. I'm 28."; // set a default bio
  }

  // function to select an image from device
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageUrls.add(pickedFile.path); // add the image to the list
      });
    } else {
      print('No image selected.');
    }
  }

  // function to remove an image from the list
  void _removeImage(int index) {
    setState(() {
      if (index > 0) {
        // prevent removing the first image.
        _imageUrls.removeAt(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Edit Profile', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          // save button in the app bar
          IconButton(
            icon: Icon(Icons.save, color: Colors.white),
            onPressed: () {
              // save the profile data
              Navigator.of(context).pop(); // go back to the previous screen.
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile Image',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              // display the profile image.  Make it tappable to edit.
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50.0,
                  backgroundImage: AssetImage(_imageUrls[0]),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Bio',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              // text field for the user to edit their bio
              TextField(
                controller: _bioController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter your bio',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 20),
              Text(
                'Other Images',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              // display the other images
              SizedBox(
                height: 100, // set a height for the horizontal list view
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _imageUrls.length -
                      1, // -1 because the first image is the profile image
                  itemBuilder: (context, index) {
                    final imageIndex =
                        index + 1; // adjust the index to start from the second image
                    return Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: Stack(
                        children: [
                          // GestureDetector to make the image tappable
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                image: DecorationImage(
                                  image: AssetImage(_imageUrls[imageIndex]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          // button to remove the image
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => _removeImage(imageIndex),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              // button to add more images
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Add Image'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }
}

