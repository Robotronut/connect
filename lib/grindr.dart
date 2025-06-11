import 'package:connect/models/user_model.dart';
import 'package:connect/screens/edit_profile_screen.dart';
import 'package:connect/services/secure_storage_service.dart';
import 'package:flutter/material.dart';

import 'package:connect/screens/profile_screen.dart'; // Ensure this path is correct
import 'package:connect/services/api_service.dart'; // Import your API service

class MainBrowseScreen extends StatefulWidget {
  const MainBrowseScreen({super.key});

  @override
  State<MainBrowseScreen> createState() => _MainBrowseScreenState();
}

class _MainBrowseScreenState extends State<MainBrowseScreen> {
  List<UserModel> _users = []; // List to hold fetched UserProfile objects
  bool _isLoading = true;
  String _errorMessage = '';
  int _currentPage = 1;
  final int _pageSize = 15; // Number of users to fetch per page
  bool _hasMore = true; // To know if there are more users to load
  final ScrollController _scrollController =
      ScrollController(); // For infinite scrolling

  // Add a variable to store the logged-in user's data
  UserModel? _loggedInUser;
  bool _isLoggedInUserLoading = true;
  String _loggedInUserErrorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchLoggedInUser(); // Fetch logged-in user when screen initializes
    _fetchUsers(); // Fetch other users
    _scrollController
        .addListener(_onScroll); // Add scroll listener for infinite scrolling
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // --- NEW METHOD TO FETCH LOGGED-IN USER ---
  Future<void> _fetchLoggedInUser() async {
    setState(() {
      _isLoggedInUserLoading = true;
      _loggedInUserErrorMessage = '';
    });
    try {
      final String? userId = await SecureStorageService.getUserId();
      if (userId == null) {
        // Handle case where user ID is not found (e.g., user is not logged in)
        setState(() {
          _loggedInUserErrorMessage = 'User not logged in.';
          _isLoggedInUserLoading = false;
        });
        return; // Exit the function
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
        print(_loggedInUserErrorMessage); // Log the error
      });
    }
  }
  // ----------------------------------------

  void _onScroll() {
    // Only trigger load more if not currently loading and has more data
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
        _isLoading = false; // Stop loading if no more data, essential for UI
      });
      return; // Don't try to load more if no more data
    }

    setState(() {
      _isLoading = true;
      if (!isLoadMore) {
        // Clear previous error only if not loading more (or refreshing)
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
          _users.addAll(
              fetchedUsers); // Add to existing list for infinite scrolling
        } else {
          _users = fetchedUsers; // Replace list for initial fetch or refresh
        }
        _isLoading = false;
        _hasMore = fetchedUsers.length ==
            _pageSize; // If fewer than pageSize, no more data
        _currentPage++; // Increment page for next fetch
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load users: ${e.toString()}';
        print(_errorMessage); // Log the error for debugging
      });
    }
  }

  Future<void> _loadMoreUsers() async {
    if (_isLoading) return; // Prevent multiple simultaneous fetches
    await _fetchUsers(isLoadMore: true);
  }

  // --- NEW METHOD FOR PULL-TO-REFRESH ---
  Future<void> _refreshUsers() async {
    setState(() {
      _users = []; // Clear existing users
      _currentPage = 1; // Reset to the first page
      _hasMore = true; // Assume there's more data to load initially
      _errorMessage = ''; // Clear any previous error messages
    });
    // Now call _fetchUsers to get the first page again
    await _fetchUsers();
    await _fetchLoggedInUser(); // Also refresh the logged-in user's data
  }
  // ----------------------------------------

  @override
  Widget build(BuildContext context) {
    // Determine the image provider for the logged-in user's avatar
    ImageProvider userAvatarImage;
    if (_loggedInUser != null && _loggedInUser!.imageUrls.isNotEmpty) {
      userAvatarImage = NetworkImage(_loggedInUser!.imageUrls[0]);
    } else {
      // Fallback to a placeholder asset image if no user or no image URL
      userAvatarImage = const AssetImage(
          'assets/placeholder_user.jpg'); // Make sure you have this asset
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
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 20.0,
                      // Use the determined image provider
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
                          hintStyle: TextStyle(
                              color: Colors.white.withAlpha(
                                  178)), // Changed from withOpacity(0.7)
                          prefixIcon: Icon(Icons.search,
                              color: Colors.white.withAlpha(
                                  229)), // Changed from withOpacity(0.9)
                          filled: true,
                          fillColor: Colors.white
                              .withAlpha(25), // Changed from withOpacity(0.1)
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
                    : (_isLoading &&
                            _users
                                .isEmpty) // Only show loading spinner if no users are loaded yet
                        ? const Center(
                            child:
                                CircularProgressIndicator(color: Colors.white))
                        : RefreshIndicator(
                            // <--- NEW: Wrap with RefreshIndicator
                            onRefresh:
                                _refreshUsers, // <--- Assign the refresh method
                            color:
                                Colors.white, // Color of the refresh indicator
                            backgroundColor: Colors.grey[
                                900], // Background of the refresh indicator
                            child: GridView.builder(
                              controller:
                                  _scrollController, // Assign scroll controller
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
                                  // This is the loading indicator item for infinite scroll
                                  return _isLoading // Only show loading spinner if still loading more
                                      ? const Center(
                                          child: CircularProgressIndicator(
                                              color: Colors.white))
                                      : const SizedBox
                                          .shrink(); // Hide if no more to load
                                }
                                final user = _users[index];
                                // Use the first image from imageUrls or a placeholder
                                final imageUrl = user.imageUrls.isNotEmpty
                                    ? user.imageUrls[0]
                                    : 'https://via.placeholder.com/150'; // Placeholder URL

                                return GestureDetector(
                                  onTap: () {
                                    // Pass the entire UserProfile object to ProfileScreen
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
                                        borderRadius:
                                            BorderRadius.circular(2.0),
                                        // Use NetworkImage for API fetched URLs
                                        child: Image.network(
                                          imageUrl,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Image.asset(
                                              'assets/placeholder_error.jpg', // A local error placeholder
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: double.infinity,
                                            );
                                          },
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
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
                                            // Note: The API response for 'status' is a string,
                                            // but 'isOnline' in your old code was a bool.
                                            // You'll need to parse 'status' string to determine online state.
                                            // For now, let's assume 'Online now' implies online.
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
                                              // You don't have a 'name' property directly in UserProfile,
                                              // but you can generate one or fetch it if your API provides it.
                                              // For now, let's use part of the ID or a placeholder.
                                              // If your API returns a name, use that here.
                                              // user.name, // If API provides a name
                                              user.userName, // Assuming userName is available from UserModel
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
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        items: const [
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
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(25), // Changed from withOpacity(0.1)
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
