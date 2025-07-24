import 'package:connect/models/user_model.dart';
import 'package:connect/screens/edit_profile_screen.dart';
import 'package:connect/services/secure_storage_service.dart';
import 'package:flutter/material.dart';

import 'package:connect/screens/profile_screen.dart'; // Ensure this path is correct
import 'package:connect/services/api_service.dart'; // Import your API service
import 'package:connect/screens/chat_screen.dart'
    hide
        EditProfileScreen; // Import your ChatScreen, but hide its placeholder EditProfileScreen

class MainBrowseScreen extends StatefulWidget {
  const MainBrowseScreen({super.key});

  @override
  State<MainBrowseScreen> createState() => _MainBrowseScreenState();
}

class _MainBrowseScreenState extends State<MainBrowseScreen> {
  // --- Existing state variables for MainBrowseScreen content ---
  List<UserModel> _users = []; // List to hold fetched UserProfile objects
  bool _isLoading = true;
  String _errorMessage = '';
  int _currentPage = 1;
  final int _pageSize = 15; // Number of users to fetch per page
  bool _hasMore = true; // To know if there are more users to load
  final ScrollController _scrollController =
      ScrollController(); // For infinite scrolling

  // Logged-in user data
  UserModel? _loggedInUser;
  bool _isLoggedInUserLoading = true;
  String _loggedInUserErrorMessage = '';

  // --- New state variables for Bottom Navigation ---
  int _selectedIndex = 0; // Current selected tab index (0 = Browse, 2 = Inbox)
  late final List<Widget> _pages; // List of screens for each tab

  @override
  void initState() {
    super.initState();
    _fetchLoggedInUser(); // Fetch logged-in user when screen initializes
    _fetchUsers(); // Fetch other users
    _scrollController
        .addListener(_onScroll); // Add scroll listener for infinite scrolling

    // Initialize the list of pages/screens for the BottomNavigationBar
    // The order here must match the order of BottomNavigationBarItems
    _pages = [
      // Index 0: Browse Screen Content (Current MainBrowseScreen body)
      _buildBrowseContent(),
      // Index 1: Interest Screen (Placeholder)
      const Center(
          child: Text('Interest Screen Content',
              style: TextStyle(color: Colors.white, fontSize: 24))),
      // Index 2: Inbox Screen (Your ChatScreen)
      // NOTE: For a real app, 'some_other_user_id' should come from selecting a conversation.
      // For demonstration, it's a fixed ID.
      ChatScreen(
        userId:
            'some_other_user_id', // Placeholder: Replace with actual chat partner ID
        currentUserId: _loggedInUser?.id ??
            'default_current_user_id', // Your logged-in user's ID
      ),
      // Index 3: Store Screen (Placeholder)
      const Center(
          child: Text('Store Screen Content',
              style: TextStyle(color: Colors.white, fontSize: 24))),
    ];
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // --- NEW METHOD FOR BOTTOM NAV ITEM TAP ---
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
  }
  // ----------------------------------------

  // --- Existing Methods (unchanged for their logic) ---
  Future<void> _fetchLoggedInUser() async {
    setState(() {
      _isLoggedInUserLoading = true;
      _loggedInUserErrorMessage = '';
    });
    try {
      final String? userId = await SecureStorageService.getUserId();
      if (userId == null) {
        setState(() {
          _loggedInUserErrorMessage = 'User not logged in.';
          _isLoggedInUserLoading = false;
        });
        return;
      }
      final user = await ApiService.getUserProfile(userId);
      setState(() {
        _loggedInUser = user;
        _isLoggedInUserLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoggedInUserLoading = false;
        _loggedInUserErrorMessage =
            'Failed to load logged-in user: ${e.toString()}';
        print(_loggedInUserErrorMessage);
      });
    }
  }

  void _onScroll() {
    if (!_isLoading &&
        _hasMore &&
        _scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
      _loadMoreUsers();
    }
  }

  Future<void> _fetchUsers({bool isLoadMore = false}) async {
    if (!_hasMore && isLoadMore) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      if (!isLoadMore) {
        _errorMessage = '';
      }
    });

    try {
      final fetchedUsers = await ApiService.getPeople(
        pageNumber: _currentPage,
        pageSize: _pageSize,
      );

      setState(() {
        if (isLoadMore) {
          _users.addAll(fetchedUsers);
        } else {
          _users = fetchedUsers;
        }
        _isLoading = false;
        _hasMore = fetchedUsers.length == _pageSize;
        _currentPage++;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load users: ${e.toString()}';
        print(_errorMessage);
      });
    }
  }

  Future<void> _loadMoreUsers() async {
    if (_isLoading) return;
    await _fetchUsers(isLoadMore: true);
  }

  Future<void> _refreshUsers() async {
    setState(() {
      _users = [];
      _currentPage = 1;
      _hasMore = true;
      _errorMessage = '';
    });
    await _fetchUsers();
    await _fetchLoggedInUser();
  }

  // --- New method to encapsulate the original Browse Screen's body content ---
  Widget _buildBrowseContent() {
    // Determine the image provider for the logged-in user's avatar
    ImageProvider userAvatarImage;
    if (_loggedInUser != null && _loggedInUser!.imageUrls.isNotEmpty) {
      userAvatarImage = NetworkImage(_loggedInUser!.imageUrls[0]);
    } else {
      userAvatarImage = const AssetImage(
          'assets/placeholder_user.jpg'); // Make sure you have this asset
    }

    return Container(
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
                        builder: (context) => const EditProfileScreen(),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 20.0,
                    backgroundImage: userAvatarImage,
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 30.0),
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Explore more profiles',
                        hintStyle:
                            TextStyle(color: Colors.white.withAlpha(178)),
                        prefixIcon: Icon(Icons.search,
                            color: Colors.white.withAlpha(229)),
                        filled: true,
                        fillColor: Colors.white.withAlpha(25),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 1.0, horizontal: 5.0),
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
              child: _errorMessage.isNotEmpty
                  ? Center(
                      child: Text(_errorMessage,
                          style: const TextStyle(color: Colors.red)))
                  : (_isLoading && _users.isEmpty)
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white))
                      : RefreshIndicator(
                          onRefresh: _refreshUsers,
                          color: Colors.white,
                          backgroundColor: Colors.grey[900],
                          child: GridView.builder(
                            controller: _scrollController,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 2.0,
                              mainAxisSpacing: 2.0,
                              childAspectRatio: 1,
                            ),
                            itemCount: _users.length +
                                (_hasMore
                                    ? 1
                                    : 0), // Add 1 for loading indicator at end
                            itemBuilder: (context, index) {
                              if (index == _users.length) {
                                return _isLoading
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                            color: Colors.white))
                                    : const SizedBox.shrink();
                              }
                              final user = _users[index];
                              final imageUrl = user.imageUrls.isNotEmpty
                                  ? user.imageUrls[0]
                                  : 'https://via.placeholder.com/150';

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProfileScreen(
                                        userId: user.id,
                                      ),
                                    ),
                                  );
                                },
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(2.0),
                                      child: Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Image.asset(
                                            'assets/placeholder_error.jpg',
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                          );
                                        },
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                              color: Colors.grey,
                                            ),
                                          );
                                        },
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
                                          if (user.status
                                              .toLowerCase()
                                              .contains('online')) ...[
                                            Container(
                                              width: 10.0,
                                              height: 10.0,
                                              decoration: const BoxDecoration(
                                                color: Colors.green,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ],
                                          const SizedBox(width: 4.0),
                                          Text(
                                            user.userName,
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
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Conditional AppBar: Show it only for the 'Browse' tab
      appBar: _selectedIndex == 0
          ? AppBar(toolbarHeight: 0) // Your original app bar for browse
          : null, // Hide AppBar for other screens (ChatScreen has its own)
      body: _pages[_selectedIndex], // Display the currently selected page
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.apps), label: 'Browse'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Interest'), // Changed icon for 'Interest'
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Inbox'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Store'),
        ],
        currentIndex: _selectedIndex, // Connects to the current selected tab
        onTap: _onItemTapped, // Handles tab selection
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Widget _buildPillButton(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(25),
          borderRadius: BorderRadius.circular(25.0),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 12.0),
            const SizedBox(width: 4.0),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 10.0),
            ),
          ],
        ),
      ),
    );
  }
}
