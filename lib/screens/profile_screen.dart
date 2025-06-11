// lib/screens/profile_screen.dart

import 'package:connect/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:connect/services/api_service.dart';
import 'package:connect/services/secure_storage_service.dart';
import 'package:connect/screens/edit_profile_screen.dart';
import 'package:connect/screens/photo_detail_screen.dart'; // Import the photo detail screen

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final PageController _pageController = PageController();
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  UserModel? _userProfile;
  bool _isLoading = true;
  String? _errorMessage;
  String? _currentLoggedInUserId;
  String? _displayUsername;
  int _currentPageIndex = 0; // << NEW: To track current image index

  final double _maxSheetExtent = 0.90; // Max height the sheet can expand to
  final double _initialChildSize =
      0.90; // Example: sheet starts at 65% of screen height
  final double _minChildSize =
      0.15; // Example: sheet can shrink to 15% (showing just header)

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _pageController.addListener(() {
      setState(() {
        // Update the current page index when the PageView scrolls
        _currentPageIndex = _pageController.page?.round() ?? 0;
      });
    });
  }

  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      _currentLoggedInUserId = await SecureStorageService.getUserId();
      final UserModel fetchedProfile =
          await ApiService.getUserProfile(widget.userId);

      String? storedUsername;
      if (widget.userId == _currentLoggedInUserId) {
        storedUsername = await SecureStorageService.getUserName();
      }

      setState(() {
        _userProfile = fetchedProfile;
        if (_isOwnProfile) {
          _displayUsername = storedUsername ?? fetchedProfile.userName;
        } else {
          _displayUsername = fetchedProfile.userName;
        }
        _currentPageIndex = 0; // Reset index when new profile is loaded
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load profile: ${e.toString()}';
      });
      print('Error loading profile: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  bool get _isOwnProfile {
    return _userProfile != null && widget.userId == _currentLoggedInUserId;
  }

  // << NEW: Helper method to build the page indicator dots >>
  Widget _buildPageIndicator() {
    if (_userProfile == null || _userProfile!.imageUrls.length <= 1) {
      return const SizedBox.shrink(); // Hide if only one or no images
    }
    return Positioned(
      bottom:
          10, // Position slightly above the bottom edge of the image container
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_userProfile!.imageUrls.length, (index) {
          return Container(
            width: 8.0,
            height: 8.0,
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentPageIndex == index
                  ? Colors.white // Active dot
                  : Colors.white.withOpacity(0.4), // Inactive dot
            ),
          );
        }),
      ),
    );
  }

  // Helper method for consistent stat rows
  Widget _buildStatRow(IconData icon, String text, {bool showInfo = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.white70),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(color: Colors.white)),
          if (showInfo) ...[
            const SizedBox(width: 5),
            const Icon(Icons.info_outline, size: 16, color: Colors.white70),
          ],
        ],
      ),
    );
  }

  // Helper method for consistent expectation rows
  Widget _buildExpectationRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.white70),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: Colors.white70)),
          const SizedBox(width: 5),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

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

    if (_userProfile == null) {
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
          ),
        ),
      );
    }

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
        actions: [
          if (_isOwnProfile)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () async {
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
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // The DraggableScrollableSheet now contains the photo and all profile details
          NotificationListener<DraggableScrollableNotification>(
            onNotification: (notification) {
              setState(() {
                // Adjust threshold as needed, e.g., 0.8 means 80% expanded
              });
              return true; // Allow the notification to continue bubbling
            },
            child: DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: _initialChildSize, // Set initial size
              minChildSize: _minChildSize, // Set minimum size
              maxChildSize: _maxSheetExtent,
              expand: true, // Allows the sheet to take up available space
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    // Add border radius to the top of the sheet
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: SingleChildScrollView(
                    controller:
                        scrollController, // Pass the sheet's scroll controller to its content
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- PHOTO SECTION (now inside the scrollable sheet) ---
                        // Give the PageView a fixed height or an AspectRatio to control its size
                        SizedBox(
                          height: MediaQuery.of(context).size.height *
                              0.70, // Example: photo takes 70% of screen height
                          // Adjust this height to control how much of the photo is seen
                          // and how far you have to scroll to see the rest of the profile.
                          child: Stack(
                            // << NEW: Use Stack to overlay dots on PageView
                            children: [
                              PageView.builder(
                                controller: _pageController,
                                itemCount: _userProfile!.imageUrls.length,
                                itemBuilder: (context, index) {
                                  final imageUrl =
                                      _userProfile!.imageUrls[index];
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PhotoDetailScreen(
                                            imageUrl: imageUrl,
                                            heroTag:
                                                'profilePhoto$index', // Unique tag for Hero animation
                                          ),
                                        ),
                                      );
                                    },
                                    child: Hero(
                                      tag:
                                          'profilePhoto$index', // Matches the tag in PhotoDetailScreen
                                      child: Image.network(
                                        imageUrl,
                                        fit: BoxFit
                                            .cover, // Fills the container, cropping if necessary
                                        errorBuilder: (context, error,
                                                stackTrace) =>
                                            Image.asset(
                                                'assets/placeholder_error.jpg',
                                                fit: BoxFit.cover),
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
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
                                  );
                                },
                              ),
                              _buildPageIndicator(), // << NEW: Call the page indicator helper
                            ],
                          ),
                        ),
                        // --- END PHOTO SECTION ---

                        // --- PROFILE DETAILS SECTION (now below the photo) ---
                        // Wrap the rest of your content in a Padding to control spacing
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    _displayUsername ?? 'N/A',
                                    style: const TextStyle(
                                      fontSize: 34,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    _userProfile!.age.toString(),
                                    style: const TextStyle(
                                      fontSize: 28,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Text(_userProfile!.status,
                                      style:
                                          TextStyle(color: Colors.grey[400])),
                                  const SizedBox(width: 5),
                                  Icon(Icons.near_me,
                                      size: 16, color: Colors.grey[400]),
                                  const SizedBox(width: 2),
                                  Text(_userProfile!.distance,
                                      style:
                                          TextStyle(color: Colors.grey[400])),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(Icons.edit,
                                      size: 16, color: Colors.grey[400]),
                                  const SizedBox(width: 5),
                                  Text(
                                      '${_userProfile!.height} | ${_userProfile!.weight} | ${_userProfile!.build}',
                                      style:
                                          const TextStyle(color: Colors.white)),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[850],
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  _isOwnProfile
                                      ? 'This is your profile.'
                                      : 'Say something...',
                                  style: TextStyle(color: Colors.grey[500]),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'ABOUT ME',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[400]),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Colors.grey[850],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  _userProfile!.aboutMe,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'STATS',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[400]),
                              ),
                              const SizedBox(height: 10),
                              _buildStatRow(Icons.male,
                                  '${_userProfile!.gender} | ${_userProfile!.pronouns}',
                                  showInfo: true),
                              _buildStatRow(Icons.person, _userProfile!.race),
                              _buildStatRow(Icons.person,
                                  _userProfile!.relationshipStatus),
                              const SizedBox(height: 20),
                              Text(
                                'EXPECTATIONS',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[400]),
                              ),
                              const SizedBox(height: 10),
                              _buildExpectationRow(Icons.people, 'Looking For',
                                  _userProfile!.lookingFor),
                              _buildExpectationRow(
                                  Icons.home, 'Meet At', _userProfile!.meetAt),
                              _buildExpectationRow(Icons.camera_alt,
                                  'NSFW pics?', _userProfile!.nsfwPics),
                              const SizedBox(height: 50),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Action buttons remain positioned at the bottom, on top of the sheet
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      _isOwnProfile ? 'Your profile' : 'Say something...',
                      style: TextStyle(color: Colors.grey[500]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                if (!_isOwnProfile) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.local_fire_department,
                        color: Colors.orange, size: 28),
                  ),
                  const SizedBox(width: 15),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chat_bubble_outline,
                        color: Colors.yellow, size: 28),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
