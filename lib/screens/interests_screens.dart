// lib/screens/interests_screen.dart

import 'package:flutter/material.dart';
import 'package:connect/screens/profile_screen.dart'; // Import the ProfileScreen
import 'package:connect/models/user_model.dart'; // Import UserModel
import 'package:connect/services/api_service.dart'; // Import your API service
import 'package:connect/services/secure_storage_service.dart'; // For fetching logged-in user ID

class InterestScreen extends StatefulWidget {
  const InterestScreen({super.key});

  @override
  State<InterestScreen> createState() => _InterestScreenState();
}

class _InterestScreenState extends State<InterestScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<UserModel> _tappedMeUsers =
      []; // For 'Taps' tab (formerly 'Interested In Me')
  List<UserModel> _viewedMeUsers = []; // For 'Views' tab
  bool _isLoadingTapped = true; // Loading state for 'Taps'
  bool _isLoadingViewedMe = true;
  String? _errorMessageTapped; // Error message for 'Taps'
  String? _errorMessageViewedMe;
  String? _currentLoggedInUserId;
  UserModel? _userProfile;

  // Pagination for 'Views' tab
  int _currentPageViews = 1;
  final int _pageSizeViews = 10; // Number of users to fetch per page for views
  bool _hasMoreViews = true;
  final ScrollController _viewsScrollController = ScrollController();

  // Pagination for 'Taps' tab
  int _currentPageTapped = 1;
  final int _pageSizeTapped = 10; // Number of users to fetch per page for taps
  bool _hasMoreTapped = true;
  final ScrollController _tappedScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInitialData();
    _viewsScrollController.addListener(_onViewsScroll);
    _tappedScrollController.addListener(_onTappedScroll);
  }

  Future<void> _loadInitialData() async {
    _currentLoggedInUserId = await SecureStorageService.getUserId();
    if (_currentLoggedInUserId == null) {
      setState(() {
        _errorMessageTapped = 'User not logged in.';
        _errorMessageViewedMe = 'User not logged in.';
        _isLoadingTapped = false;
        _isLoadingViewedMe = false;
      });
      return;
    }

    // --- Fetch 'Taps' Users ---
    // This part assumes you have an API endpoint or logic to fetch users
    // who have 'tapped' (liked/fired) the currently logged-in user.
    // For now, it will remain as a placeholder or use a similar API call if available.
    _fetchUsersWhoTappedMe();

    // --- Fetch 'Views' Users ---
    _fetchUsersWhoViewedMe();
  }

  Future<void> _fetchUsersWhoTappedMe({bool isLoadMore = false}) async {
    if (!isLoadMore) {
      setState(() {
        _isLoadingTapped = true;
        _errorMessageTapped = null;
        _currentPageTapped = 1; // Reset page for fresh fetch
        _tappedMeUsers.clear(); // Clear existing users
        _hasMoreTapped = true;
      });
    } else {
      if (!_hasMoreTapped || _isLoadingTapped)
        return; // Prevent multiple simultaneous loads
      setState(() {
        _isLoadingTapped = true;
      });
    }

    try {
      // IMPORTANT: This is a placeholder. Your backend needs an API that
      // returns users who have 'tapped' the logged-in user's profile.
      // You might need to extend ApiService.getPeople to include a 'tappedBy' filter
      // or create a new method like ApiService.getUsersWhoTappedMe.
      final List<UserModel> fetchedUsers = await ApiService.getWhoTappedMe(
        pageNumber: _currentPageTapped,
        pageSize: _pageSizeTapped,
        // Assuming your API can filter by a 'tapper's' ID or a specific 'tapped_me' endpoint
        // You might need to pass _currentLoggedInUserId here if your API supports it:
        // id: _currentLoggedInUserId, // This is a conceptual parameter for your backend
      );

      setState(() {
        if (isLoadMore) {
          _tappedMeUsers.addAll(fetchedUsers);
        } else {
          _tappedMeUsers = fetchedUsers;
        }
        _hasMoreTapped = fetchedUsers.length == _pageSizeTapped;
        _currentPageTapped++;
      });
    } catch (e) {
      setState(() {
        _errorMessageTapped = 'Failed to load tapped users: ${e.toString()}';
        print('Error loading tapped users: $e');
      });
    } finally {
      setState(() {
        _isLoadingTapped = false;
      });
    }
  }

  void _onTappedScroll() {
    if (_tappedScrollController.position.pixels ==
            _tappedScrollController.position.maxScrollExtent &&
        _hasMoreTapped &&
        !_isLoadingTapped) {
      _fetchUsersWhoTappedMe(isLoadMore: true);
    }
  }

  Future<void> _fetchUsersWhoViewedMe({bool isLoadMore = false}) async {
    if (!isLoadMore) {
      setState(() {
        _isLoadingViewedMe = true;
        _errorMessageViewedMe = null;
        _currentPageViews = 1; // Reset page for fresh fetch
        _viewedMeUsers.clear(); // Clear existing users
        _hasMoreViews = true;
      });
    } else {
      if (!_hasMoreViews || _isLoadingViewedMe)
        return; // Prevent multiple simultaneous loads
      setState(() {
        _isLoadingViewedMe = true;
      });
    }

    try {
      // IMPORTANT: This is a placeholder. Your backend needs an API that
      // returns users who have viewed the logged-in user's profile.
      // You might need to extend ApiService.getPeople to include a 'viewedBy' filter
      // or create a new method like ApiService.getUsersWhoViewedMe.
      final List<UserModel> fetchedUsers = await ApiService.getWhoViewMe(
          pageNumber: _currentPageViews, pageSize: _pageSizeViews
          // Assuming your API can filter by a viewer's ID or a specific 'viewed_me' endpoint
          // You might need to pass _currentLoggedInUserId here if your API supports it:
          // id: _currentLoggedInUserId, // This is a conceptual parameter for your backend
          // Example filter, adjust as needed
          );

      setState(() {
        if (isLoadMore) {
          _viewedMeUsers.addAll(fetchedUsers);
        } else {
          _viewedMeUsers = fetchedUsers;
        }
        _hasMoreViews = fetchedUsers.length == _pageSizeViews;
        _currentPageViews++;
      });
    } catch (e) {
      setState(() {
        _errorMessageViewedMe = 'Failed to load viewers: ${e.toString()}';
        print('Error loading viewers: $e');
      });
    } finally {
      setState(() {
        _isLoadingViewedMe = false;
      });
    }
  }

  void _onViewsScroll() {
    if (_viewsScrollController.position.pixels ==
            _viewsScrollController.position.maxScrollExtent &&
        _hasMoreViews &&
        !_isLoadingViewedMe) {
      _fetchUsersWhoViewedMe(isLoadMore: true);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _viewsScrollController.dispose();
    _tappedScrollController.dispose(); // Dispose the new scroll controller
    super.dispose();
  }

  // Helper to format time difference (copied from grindr.txt for consistency)
  String _formatTimeAgo(DateTime dateTime) {
    final Duration diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'now';
    }
  }

  // Helper to format distance (copied from grindr.txt for consistency)
  String _formatDistance(double distanceKm) {
    if (distanceKm < 1.0) {
      return '${(distanceKm * 1000).round()} m away';
    } else {
      return '${distanceKm.toStringAsFixed(0)} km away';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Interest',
          style: TextStyle(
              color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.yellow,
          labelColor: Colors.yellow,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Views'), // Swapped order: Views on left
            Tab(text: 'Taps'), // Taps on right
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Views (Loads users who viewed the logged-in user) - now first tab
          _isLoadingViewedMe && _viewedMeUsers.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white))
              : _errorMessageViewedMe != null
                  ? Center(
                      child: Text(_errorMessageViewedMe!,
                          style: const TextStyle(color: Colors.red)))
                  : _viewedMeUsers.isEmpty
                      ? const Center(
                          child: Text(
                            'No one has viewed your profile yet.',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () =>
                              _fetchUsersWhoViewedMe(isLoadMore: false),
                          color: Colors.white,
                          backgroundColor: Colors.grey[900],
                          child: GridView.builder(
                            controller: _viewsScrollController,
                            padding: const EdgeInsets.all(8.0),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, // Two users per row
                              crossAxisSpacing: 8.0,
                              mainAxisSpacing: 8.0,
                              childAspectRatio: 0.75, // Adjust as needed
                            ),
                            itemCount:
                                _viewedMeUsers.length + (_hasMoreViews ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == _viewedMeUsers.length) {
                                return _isLoadingViewedMe
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                            color: Colors.white))
                                    : const SizedBox.shrink();
                              }
                              final user = _viewedMeUsers[index];
                              return _buildUserGridItem(context, user);
                            },
                          ),
                        ),
          // Tab 2: Taps (Loads users who 'tapped' the logged-in user) - now second tab
          _isLoadingTapped && _tappedMeUsers.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white))
              : _errorMessageTapped != null
                  ? Center(
                      child: Text(_errorMessageTapped!,
                          style: const TextStyle(color: Colors.red)))
                  : _tappedMeUsers.isEmpty
                      ? const Center(
                          child: Text(
                            'No one has tapped your profile yet.',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () =>
                              _fetchUsersWhoTappedMe(isLoadMore: false),
                          color: Colors.white,
                          backgroundColor: Colors.grey[900],
                          child: ListView.builder(
                            // Changed to ListView.builder
                            controller: _tappedScrollController,
                            padding: const EdgeInsets.all(8.0),
                            itemCount: _tappedMeUsers.length +
                                (_hasMoreTapped ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == _tappedMeUsers.length) {
                                return _isLoadingTapped
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                            color: Colors.white))
                                    : const SizedBox.shrink();
                              }
                              final user = _tappedMeUsers[index];
                              return _buildUserListItem(
                                  context, user); // Using new list item builder
                            },
                          ),
                        ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 50),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Unlocking all profiles!'),
                      backgroundColor: Colors.yellow,
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: const Text(
                  'Unlock To See All',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Unified _buildUserGridItem for UserModel (used by both tabs)
  Widget _buildUserGridItem(BuildContext context, UserModel user) {
    final imageUrl = user.imageUrls.isNotEmpty
        ? user.imageUrls[0]
        : '/assets/placeholder_user.jpg'; // Placeholder if no image

    return GestureDetector(
      onTap: () {
        // Navigate to the ProfileScreen using the user's ID
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileScreen(userId: user.id.toString()),
          ),
        );
      },
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[800],
                  child: const Center(
                    child: Icon(Icons.person, color: Colors.white54, size: 50),
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 8.0,
            left: 8.0,
            right: 8.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${user.userName}, ${user.age}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                Text(user.distance.toString(),
                    style: TextStyle(color: Colors.grey[400])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // New _buildUserListItem for UserModel (used by Taps tab)
  Widget _buildUserListItem(BuildContext context, UserModel user) {
    final imageUrl = user.imageUrls.isNotEmpty
        ? user.imageUrls[0]
        : 'assets/placeholder_user.jpg'; // Placeholder if no image

    return GestureDetector(
      onTap: () {
        // Navigate to the ProfileScreen using the user's ID
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileScreen(userId: user.id.toString()),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        margin: const EdgeInsets.only(bottom: 8.0),
        decoration: BoxDecoration(
          color: Colors.grey[900], // Darker background for list items
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          children: [
            // User Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: 80, // Smaller image for list view
                height: 80,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[800],
                    child: const Center(
                      child:
                          Icon(Icons.person, color: Colors.white54, size: 40),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[800],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16.0),
            // User Name, Age, Distance
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${user.userName}, ${user.age}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    (user.distance.toString()), // Use formatted distance
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                ],
              ),
            ),
            // "Yesterday" and Flame Icon
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Placeholder for 'Yesterday' as UserModel doesn't have last active time
                Text(
                  'Yesterday', // This would ideally be dynamic based on user.lastActive
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
                const SizedBox(height: 4.0),
                const Icon(Icons.whatshot, color: Colors.orange, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
