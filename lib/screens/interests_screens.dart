// lib/screens/interests_screen.dart

import 'package:connect/screens/store_screen.dart';
import 'package:flutter/material.dart';
import 'package:connect/screens/profile_screen.dart'; // Import the ProfileScreen
import 'package:connect/models/user_model.dart'; // Import UserModel
import 'package:connect/services/api_service.dart'; // Import your API service
import 'package:connect/services/secure_storage_service.dart'; // For fetching logged-in user ID
import 'package:connect/screens/store_screen.dart'; // Import the new subscription store screen
import 'dart:ui'; // For the BackdropFilter blur effect

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

  // New state variable to check for subscription status
  bool _hasSubscription = false;

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

    // Simulate checking subscription status
    await _checkSubscriptionStatus();

    // Fetch 'Taps' Users
    _fetchUsersWhoTappedMe();

    // Fetch 'Views' Users
    _fetchUsersWhoViewedMe();
  }

  // Placeholder method to simulate checking subscription status
  Future<void> _checkSubscriptionStatus() async {
    // In a real app, you would make an API call here to check the user's
    // subscription status from your backend.
    // For now, we'll just set it to false to demonstrate the blur effect.
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _hasSubscription = false; // Set to true to see the un-blurred view
    });
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
      final List<UserModel> fetchedUsers = await ApiService.getWhoTappedMe(
        pageNumber: _currentPageTapped,
        pageSize: _pageSizeTapped,
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
      final List<UserModel> fetchedUsers = await ApiService.getWhoViewMe(
          pageNumber: _currentPageViews, pageSize: _pageSizeViews);

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
        // Added leading back arrow button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
          // Tab 1: Views
          _buildTabContent(
            context: context,
            users: _viewedMeUsers,
            isLoading: _isLoadingViewedMe,
            errorMessage: _errorMessageViewedMe,
            hasMore: _hasMoreViews,
            scrollController: _viewsScrollController,
            isGrid: true, // Views tab uses a grid layout
            onRefresh: () => _fetchUsersWhoViewedMe(isLoadMore: false),
            hasSubscription: _hasSubscription,
          ),
          // Tab 2: Taps
          _buildTabContent(
            context: context,
            users: _tappedMeUsers,
            isLoading: _isLoadingTapped,
            errorMessage: _errorMessageTapped,
            hasMore: _hasMoreTapped,
            scrollController: _tappedScrollController,
            isGrid: false, // Taps tab uses a list layout
            onRefresh: () => _fetchUsersWhoTappedMe(isLoadMore: false),
            hasSubscription: _hasSubscription,
          ),
        ],
      ),
      // This bottom navigation bar is only visible when the user does NOT have a subscription
      bottomNavigationBar: _hasSubscription
          ? null
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to the subscription store page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SubscriptionPage(),
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

  // Helper method to build the content for each tab, with a subscription check
  Widget _buildTabContent({
    required BuildContext context,
    required List<UserModel> users,
    required bool isLoading,
    required String? errorMessage,
    required bool hasMore,
    required ScrollController scrollController,
    required bool isGrid,
    required Future<void> Function() onRefresh,
    required bool hasSubscription,
  }) {
    if (isLoading && users.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
    if (errorMessage != null) {
      return Center(
          child: Text(errorMessage, style: const TextStyle(color: Colors.red)));
    }
    if (users.isEmpty) {
      return const Center(
        child: Text(
          'No one has viewed your profile yet.',
          style: TextStyle(color: Colors.white70, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }

    // The actual list or grid view
    Widget content;
    if (isGrid) {
      content = GridView.builder(
        controller: scrollController,
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Two users per row
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 0.75, // Adjust as needed
        ),
        itemCount: users.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == users.length) {
            return isLoading
                ? const Center(
                child: CircularProgressIndicator(color: Colors.white))
                : const SizedBox.shrink();
          }
          final user = users[index];
          // Use the modified grid item builder that checks for subscription
          return _buildUserGridItem(context, user, hasSubscription);
        },
      );
    } else {
      content = ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.all(8.0),
        itemCount: users.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == users.length) {
            return isLoading
                ? const Center(
                child: CircularProgressIndicator(color: Colors.white))
                : const SizedBox.shrink();
          }
          final user = users[index];
          // Use the modified list item builder that checks for subscription
          return _buildUserListItem(context, user, hasSubscription);
        },
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: Colors.white,
      backgroundColor: Colors.grey[900],
      child: content,
    );
  }

  // Modified _buildUserGridItem with subscription check
  Widget _buildUserGridItem(
      BuildContext context, UserModel user, bool hasSubscription) {
    final imageUrl = user.imageUrls.isNotEmpty
        ? user.imageUrls[0]
        : 'https://placehold.co/400x600/000000/FFFFFF?text=No+Image';

    return GestureDetector(
      onTap: () {
        // Only navigate if the user has a subscription
        if (hasSubscription) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileScreen(userId: user.id.toString()),
            ),
          );
        } else {
          // Take them to the store page if they click on a blurred profile
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SubscriptionPage(),
            ),
          );
        }
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
          // Blur only if user doesn't have a subscription
          if (!hasSubscription)
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                child: Container(
                  color: Colors.black.withOpacity(0.4),
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
                Text(_formatDistance(double.tryParse(user.distance.toString()) ?? 0.0),
                    style: TextStyle(color: Colors.grey[400])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Modified _buildUserListItem with subscription check
  Widget _buildUserListItem(
      BuildContext context, UserModel user, bool hasSubscription) {
    final imageUrl = user.imageUrls.isNotEmpty
        ? user.imageUrls[0]
        : 'https://placehold.co/400x400/000000/FFFFFF?text=No+Image';

    return GestureDetector(
      onTap: () {
        // Only navigate if the user has a subscription
        if (hasSubscription) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileScreen(userId: user.id.toString()),
            ),
          );
        } else {
          // Take them to the store page if they click on a blurred profile
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SubscriptionPage(),
            ),
          );
        }
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
            Stack(
              alignment: Alignment.center,
              children: [
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
                          child: Icon(Icons.person,
                              color: Colors.white54, size: 40),
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
                // Blur only if user doesn't have a subscription
                if (!hasSubscription)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                      child: Container(
                        width: 80,
                        height: 80,
                        color: Colors.black.withOpacity(0.4),
                      ),
                    ),
                  ),
              ],
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
                    _formatDistance(double.tryParse(user.distance.toString()) ?? 0.0), // Use formatted distance
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
