// lib/screens/profile_screen.dart

import 'package:connect/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:connect/services/api_service.dart';
import 'package:connect/services/secure_storage_service.dart';
import 'package:connect/screens/edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  // Pass the userId (String) directly to the ProfileScreen
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final PageController _pageController = PageController();
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  int _currentPageIndex = 0;
  UserModel? _userProfile;
  bool _isLoading = true;
  String? _errorMessage;
  String? _currentLoggedInUserId; // To store the logged-in user's ID
  String? _displayUsername; // To hold the username for display

  bool _isProfileSheetExpanded = false;

  final double _maxSheetExtent = 0.95;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _pageController.addListener(() {
      setState(() {
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
      // Get the ID of the currently logged-in user from secure storage
      _currentLoggedInUserId = await SecureStorageService.getUserId();

      // Fetch the profile data using the userId passed into the widget
      final UserModel fetchedProfile =
          await ApiService.getUserProfile(widget.userId);

      String? storedUsername;
      // If the fetched profile belongs to the current logged-in user
      if (widget.userId == _currentLoggedInUserId) {
        // Prefer the username from secure storage for the *current user's* own profile
        storedUsername = await SecureStorageService.getUserName();
      }

      setState(() {
        _userProfile = fetchedProfile;
        // Determine the username to display
        if (_isOwnProfile) {
          // If it's the current user's profile, prefer the username from secure storage
          _displayUsername = storedUsername ??
              fetchedProfile.userName; // Fallback to userName from model
        } else {
          // Otherwise, use the userName from the fetched profile
          _displayUsername = fetchedProfile.userName;
        }
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

  // Helper getter to check if the displayed profile is the logged-in user's own profile
  bool get _isOwnProfile {
    return _userProfile != null && widget.userId == _currentLoggedInUserId;
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

    final bool isLastPhoto =
        _currentPageIndex == (_userProfile!.imageUrls.length - 1);

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
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragUpdate: (details) {
                if (!_isProfileSheetExpanded) {
                  if (details.primaryDelta! < 0 && isLastPhoto) {
                    _sheetController.animateTo(
                      _maxSheetExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  } else if (details.primaryDelta! < 0 && !isLastPhoto) {
                    _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut);
                  } else if (details.primaryDelta! > 0 &&
                      _currentPageIndex > 0) {
                    _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut);
                  }
                }
              },
              child: PageView.builder(
                controller: _pageController,
                itemCount: _userProfile!.imageUrls.length,
                itemBuilder: (context, index) {
                  final imageUrl = _userProfile!.imageUrls[index];
                  return Image.network(
                    imageUrl,
                    fit: BoxFit.fitHeight,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                        'assets/placeholder_error.jpg',
                        fit: BoxFit.fitHeight),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          color: Colors.grey,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          // NotificationListener to update _isProfileSheetExpanded
          NotificationListener<DraggableScrollableNotification>(
            onNotification: (notification) {
              setState(() {
                _isProfileSheetExpanded = notification.extent > 0.8;
              });
              return true; // Allow the notification to continue bubbling
            },
            child: DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: 0.25,
              minChildSize: 0.25,
              maxChildSize: _maxSheetExtent,
              expand: true,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Username on the left
                              Text(
                                _displayUsername ?? 'N/A', // Null-safe display
                                style: const TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),

                              // Spacer to push the age to the right
                              const Spacer(),

                              // Age on the right
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
                                  style: TextStyle(color: Colors.grey[400])),
                              const SizedBox(width: 5),
                              Icon(Icons.near_me,
                                  size: 16, color: Colors.grey[400]),
                              const SizedBox(width: 2),
                              Text(_userProfile!.distance,
                                  style: TextStyle(color: Colors.grey[400])),
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
                                  style: const TextStyle(color: Colors.white)),
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
                          _buildStatRow(
                              Icons.person, _userProfile!.relationshipStatus),
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
                          _buildExpectationRow(Icons.camera_alt, 'NSFW pics?',
                              _userProfile!.nsfwPics),
                          const SizedBox(height: 50),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
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
}
