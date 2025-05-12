import 'package:flutter/material.dart';
import 'dart:math';

class grindr extends StatelessWidget {
  // List of common boy names

  // List of common boy names
  final List<String> boyNames = [
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
      String randomName = boyNames[random.nextInt(boyNames.length)];
      String imageName =
          "assets/auser_${(index % 14) + 1}.jpg"; // Cycle through user_1.jpg to user_7.jpg
      bool isOnline = random.nextBool(); // Randomly assign online status
      return {
        "name": randomName,
        "image": imageName,
        "isOnline": isOnline, // Add online status
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final users = generateUsers(); // Call the method to generate users
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: Container(
        color: Colors.black, // Set the entire body background color to black
        child: Column(
          children: [
            // Top Row with Profile Photo and Search Box
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  // Profile Photo
                  CircleAvatar(
                    radius: 20.0, // Adjust the radius as needed
                    backgroundImage: AssetImage(
                      'assets/auser_6.jpg',
                    ), // Replace with your profile image path
                  ),
                  SizedBox(
                    width: 8.0,
                  ), // Space between profile photo and search box
                  // Search Input Box
                  // Search Input Box
                  Expanded(
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight:
                            30.0, // Set a maximum height for the input box
                      ),
                      child: TextField(
                        style: TextStyle(
                          color: Colors.white,
                        ), // Set the text color to white
                        decoration: InputDecoration(
                          hintText: 'Explore more profiles', // Placeholder text
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.white.withValues(alpha: .9),
                          ),
                          // Magnifying glass icon
                          filled: true,
                          fillColor: Colors.white.withValues(
                            alpha: .1,
                          ), // Background color of the input box
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 1.0,
                            horizontal: 5.0,
                          ), // Adjust vertical padding
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              25.0,
                            ), // Match the profile circle radius
                            borderSide: BorderSide.none, // No border
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Slider with Pill Buttons
            SizedBox(
              height: 30.0, // Height of the slider
              child: ListView(
                scrollDirection: Axis.horizontal, // Horizontal scrolling
                children: [
                  SizedBox(width: 8.0), // Add spacing at the start
                  _buildPillButton(Icons.star_outline, "Favorite"),
                  _buildPillButton(Icons.cake, "Age"),
                  _buildPillButton(Icons.wifi, "Online"),
                  _buildPillButton(Icons.location_on, "Position"),
                  _buildPillButton(Icons.fiber_new, "Fresh"),
                  _buildPillButton(Icons.tag, "Tags"),
                  _buildPillButton(Icons.filter_list, "More Filters"),
                  SizedBox(width: 8.0), // Add spacing at the end
                ],
              ),
            ),
            // Grid of Users
            Expanded(
              child: Container(
                color: Colors.black, // Set the background color to black
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // Number of columns
                    crossAxisSpacing: 2.0, // Space between columns
                    mainAxisSpacing: 2.0, // Space between rows
                    childAspectRatio: 1, // Make the grid items square
                  ),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return GestureDetector(
                      onTap: () {
                        // Handle tap (e.g., navigate to profile page)
                        print("Tapped on ${user['name']}");
                      },
                      child: Stack(
                        children: [
                          // User Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              2.0,
                            ), // Rounded corners
                            child: Image.asset(
                              user["image"]!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          // Gradient Overlay
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height:
                                  50, // Adjust height of the gradient overlay
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withValues(
                                      alpha: .9,
                                    ), // 90% black
                                    Colors.transparent, // Transparent
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // User Name
                          Positioned(
                            bottom: 8.0, // Position above the gradient
                            left: 8.0,
                            child: Row(
                              children: [
                                // Show green circle only if user is online
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
                                SizedBox(
                                  width: 4.0,
                                ), // Space between circle and name
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
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black, // Set the background color to black
        selectedItemColor: Colors.white, // Color of the selected item
        unselectedItemColor: Colors.grey, // Color of the unselected items
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.apps), // App icon for Browse
            label: 'Browse',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fire_extinguisher), // Fire icon for Interest
            label: 'Interest',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message), // Message icon for Inbox
            label: 'Inbox',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store), // Store icon for Store
            label: 'Store',
          ),
        ],
        type: BottomNavigationBarType.fixed, // Ensure the type is fixed
      ),
    );
  }

  // Helper method to build pill buttons
  Widget _buildPillButton(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 4.0,
      ), // Spacing between pills
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 10.0,
          vertical: 0,
        ), // Inner padding for the pill
        decoration: BoxDecoration(
          color: Colors.white.withValues(
            alpha: .1,
          ), // 10% transparent white fill
          borderRadius: BorderRadius.circular(25.0), // Pill shape
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 12.0), // Icon inside the pill
            SizedBox(width: 4.0), // Space between icon and text
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 10.0,
              ), // White text
            ),
          ],
        ),
      ),
    );
  }
}
