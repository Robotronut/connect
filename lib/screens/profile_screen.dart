// lib/screens/profile_screen.dart

import 'package:connect/models/user_model.dart';
import 'package:connect/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:connect/services/api_service.dart';
import 'package:connect/services/secure_storage_service.dart';
import 'package:connect/screens/edit_profile_screen.dart';
import 'package:connect/screens/photo_detail_screen.dart'; // Import the photo detail screen
import 'package:connect/screens/messaging_screen.dart'; // Import the MessageScreen

// Assuming UserModel and ImageUrl are defined as they were in the previous example
// and have the necessary fields (age, status, distance, height, weight, bodytype,
// aboutMe, gender, pronouns, race, relationshipStatus, lookingFor, meetAt, acceptsNsfwPics)
// IMPORTANT: This version assumes imageUrls is List<String>, NOT List<ImageUrl>
// If you have a custom ImageUrl object, you'll need to re-add the .url access.

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
  int _currentPageIndex = 0;

  final double _initialChildSize =
      1; // Starts showing most of the content including photo
  final double _minChildSize =
      1; // Sheet can shrink to 15% (showing just header)
  final double _maxSheetExtent =
      1; // Max height the sheet can expand to (almost full screen)

  double _sheetScrollOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _pageController.addListener(() {
      setState(() {
        _currentPageIndex = _pageController.page?.round() ?? 0;
      });
    });

    _sheetController.addListener(() {
      final double currentExtent = _sheetController.size;
      double normalizedOpacity = 0.0;

      if (currentExtent > _minChildSize) {
        normalizedOpacity = ((currentExtent - _minChildSize) /
                (_maxSheetExtent - _minChildSize))
            .clamp(0.0, 1.0);
      }

      setState(() {
        _sheetScrollOpacity = normalizedOpacity;
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
      final UserModel? fetchedProfile =
          await ApiService.getUserProfile(widget.userId);

      setState(() {
        _userProfile = fetchedProfile;

        _displayUsername = fetchedProfile!.userName;

        _currentPageIndex = 0;
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

  Widget _buildPageIndicator() {
    if (_userProfile == null ||
        _userProfile!.imageUrls == null ||
        _userProfile!.imageUrls.length <= 1) {
      return const SizedBox.shrink();
    }
    return Positioned(
      bottom: 10,
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
                  ? Colors.white
                  : Colors.white.withOpacity(0.4),
            ),
          );
        }),
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

  void _navigateToChatScreen() {
    if (_userProfile != null) {
      final String url = 'https://peek.thegwd.ca/chathub';
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChatScreen(
                  username: _userProfile!.userName.toString(),
                  currentUserId: _currentLoggedInUserId.toString(),
                  chatHubUrl: url,
                  otherUserId: _userProfile!.id.toString()
                )),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double photoHeightInSheet = screenHeight * 0.50;

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
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: _sheetScrollOpacity),
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
                _loadProfileData();
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
      body: DraggableScrollableSheet(
        controller: _sheetController,
        initialChildSize: _initialChildSize,
        minChildSize: _minChildSize,
        maxChildSize: _maxSheetExtent,
        expand: true,
        snap: false,
        shouldCloseOnMinExtent: true,
        builder: (BuildContext context, ScrollController scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(top: 10, bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                SizedBox(
                  height: photoHeightInSheet,
                  width: double.infinity,
                  child: _userProfile!.imageUrls.isEmpty
                      ? Container(
                          color: Colors.grey[800],
                          child: const Center(
                            child: Icon(Icons.person,
                                size: 100, color: Colors.grey),
                          ),
                        )
                      : Stack(
                          children: [
                            PageView.builder(
                              controller: _pageController,
                              itemCount: _userProfile!.imageUrls.length,
                              itemBuilder: (context, index) {
                                // CORRECTED: Direct access to the URL string
                                final String imageUrl =
                                    _userProfile!.imageUrls[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PhotoDetailScreen(
                                          // CORRECTED: Pass the URL string directly
                                          imageUrl:
                                              _userProfile!.imageUrls[index],
                                          heroTag: 'profilePhoto$index',
                                        ),
                                      ),
                                    );
                                  },
                                  child: Hero(
                                    tag: 'profilePhoto$index',
                                    child: Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                      errorBuilder: (context, error,
                                              stackTrace) =>
                                          Image.asset(
                                              'assets/placeholder_error.jpg',
                                              fit: BoxFit.cover),
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
                                            color: Colors.white,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                            _buildPageIndicator(),
                          ],
                        ),
                ),
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
                          Text(_userProfile!.status.toString(),
                              style: TextStyle(color: Colors.grey[400])),
                          const SizedBox(width: 5),
                          Icon(Icons.near_me,
                              size: 16, color: Colors.grey[400]),
                          const SizedBox(width: 2),
                          Text(_userProfile!.distance.toString(),
                              style: TextStyle(color: Colors.grey[400])),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.monitor_weight,
                              size: 16, color: Colors.grey[400]),
                          const SizedBox(width: 5),
                          Text(
                              '${_userProfile!.height} | ${_userProfile!.weight} | ${_userProfile!.bodyType}',
                              style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: _isOwnProfile ? null : _navigateToChatScreen,
                        child: Container(
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
                          _userProfile!.aboutMe.toString(),
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
                      _buildStatRow(
                          Icons.person, _userProfile!.race.toString()),
                      _buildStatRow(Icons.person,
                          _userProfile!.relationshipStatus.toString()),
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
                          _userProfile!.lookingFor.toString()),
                      _buildExpectationRow(Icons.home, 'Meet At',
                          _userProfile!.meetAt.toString()),
                      _buildExpectationRow(Icons.camera_alt, 'NSFW pics?',
                          _userProfile!.acceptsNsfwPics.toString()),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
                if (!_isOwnProfile)
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 20.0, right: 20.0, bottom: 50.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _navigateToChatScreen,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.grey[850],
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                'Say something...',
                                style: TextStyle(color: Colors.grey[500]),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
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
                        GestureDetector(
                          onTap: _navigateToChatScreen,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[850],
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.chat_bubble_outline,
                                color: Colors.yellow, size: 28),
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
    );
  }
}
