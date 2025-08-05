import 'package:connect/main.dart';
import 'package:connect/models/user_model.dart';
import 'package:connect/screens/chat_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:connect/services/api_service.dart';
import 'package:connect/services/secure_storage_service.dart';
import 'package:connect/screens/edit_profile_screen.dart';
import 'package:connect/screens/photo_detail_screen.dart'; // Import the photo detail screen
import 'package:connect/screens/report_screen.dart';
import 'package:signalr_netcore/http_connection_options.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:connect/screens/chat_Inbox_Screen.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';
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
  late HubConnection hubConnection;

  UserModel? _userProfile;
  UserModel? _currentUser;
  bool _isLoading = true;
  String? _errorMessage;
  String? _currentLoggedInUserId;
  String? _displayUsername;
  int _currentPageIndex = 0;
  bool _isFlameTapped = false;
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
    _pageController.addListener(() {
      setState(() {
        _currentPageIndex = _pageController.page?.round() ?? 0;
      });
    });

    // The fix: Call a synchronous method that contains the async logic
    _initializeProfileAndHub();

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

  Future<void> _initializeProfileAndHub() async {
    // This is the new, separate async method.
    // It is called synchronously from initState but runs asynchronously.
    await _loadProfileData();
    await _setupSignalR();
  }

  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      _currentLoggedInUserId = await SecureStorageService.getUserId();
      final UserModel fetchedProfile =
      await ApiService.getUserProfileById(widget.userId);
      final UserModel myProfile =
      await ApiService.getUserProfileById(_currentLoggedInUserId);
      if (mounted) {
        // Check if the widget is still in the tree before calling setState
        setState(() {
          _currentUser = myProfile;
          _userProfile = fetchedProfile;
          _displayUsername = fetchedProfile.userName;
          _currentPageIndex = 0;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load profile: ${e.toString()}';
        });
      }
      print('Error loading profile: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _setupSignalR() async {
    final String? APIkey = await SecureStorageService.getApiKey();
    hubConnection = HubConnectionBuilder()
        .withUrl(
      kServerUrl,
      options: HttpConnectionOptions(
        accessTokenFactory: () async => Future.value(APIkey),
      ),
    )
        .build();
    // It's a good practice to start the connection here if needed.
    await hubConnection.start()?.then((_) {
      print('SignalR: Connection started successfully!');
      // Now you can safely navigate to the VideoChatScreen or perform other actions.
    }).catchError((error) {
      print('SignalR: Failed to start connection: $error');
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _sheetController.dispose();
    hubConnection.stop(); // Stop the hub connection
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

  /// A helper widget to get the appropriate icon for a given position.
  IconData? _getIconForPosition(String position) {
    switch (position) {
      case 'Top':
        return Icons.arrow_upward;
      case 'Versatile':
        return Icons.swap_horiz;
      case 'Bottom':
        return Icons.arrow_downward;
      case 'Side':
        return Icons.horizontal_rule;
      case 'Ver Bottom':
        return Icons.arrow_downward; // Can be more specific if needed
      case 'Vers Top':
        return Icons.arrow_upward; // Can be more specific if needed
      case 'Rather Not Say':
        return Icons.do_not_disturb_alt;
      default:
        return null;
    }
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

  void _navigateToTap() {
    setState(() {
      _isFlameTapped = !_isFlameTapped; // Toggle the state
      final userProfile = _userProfile;
      if (userProfile != null) {
        ApiService.sendTap(userProfile.id);
      }
    });
  }

  void _navigateToChatScreen() async {
    if (_userProfile != null) {
      UserModel _currentUser = await ApiService.getUserProfileById("");
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChatScreen(
              hubConnection: hubConnection,
              currentUserId: _currentUser.id,
              currentUserImgUrl: _currentUser!.imageUrls.first,
              currentUserName: _currentUser.userName,
              chatHubUrl: kServerUrl,
              otherUserId: _userProfile!.id.toString(),
              otherUserName: _userProfile!.userName.toString(),
              otherUserImgUrl: _userProfile!.imageUrls.first,
            )),
      );
    }
  }

  // --- New Navigation Function for Report Screen ---
  void _navigateToReportScreen() {
    if (_userProfile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReportScreen(
            reportedUserId: _userProfile!.id,
            reportedUsername: _userProfile!.userName,
          ),
        ),
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
        backgroundColor: Colors.black
            .withOpacity(_sheetScrollOpacity), // Corrected: Use withOpacity
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
            // Changed from Icons.person_outline to CupertinoIcons.flag_fill
            IconButton(
              icon: const Icon(CupertinoIcons.flag, color: Colors.white),
              onPressed: _navigateToReportScreen, // Call the new function
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
                      // Display Position under username
                      if (_userProfile!.position != null &&
                          _userProfile!.position!.isNotEmpty &&
                          !_userProfile!.position!.contains('Rather Not Say')) // Updated condition
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Row(
                            children: [
                              // Display icon for each selected position
                              ..._userProfile!.position!.map((pos) =>
                              _getIconForPosition(pos) != null
                                  ? Padding(
                                padding: const EdgeInsets.only(right: 5.0),
                                child: Icon(
                                  _getIconForPosition(pos),
                                  size: 18,
                                  color: Colors.grey[400],
                                ),
                              )
                                  : const SizedBox.shrink()),
                              Text(
                                _userProfile!.position!.join(', '),
                                style: TextStyle(color: Colors.grey[400], fontSize: 16),
                              ),
                            ],
                          ),
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
                              '${_userProfile!.height} | ${_userProfile!.weight}' +
                                  (_userProfile!.bodyType != 'Rather Not Say' && _userProfile!.bodyType!.isNotEmpty
                                      ? ' | ${_userProfile!.bodyType}'
                                      : ''),
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
                      // Display Gender

                      // Display Pronouns
                      if (_userProfile!.pronouns != 'Rather Not Say' && _userProfile!.pronouns!.isNotEmpty)
                        _buildStatRow(
                          Icons.male,
                          _userProfile!.gender != 'Rather Not Say' && _userProfile!.gender!.isNotEmpty
                              ? '${_userProfile!.gender} | ${_userProfile!.pronouns}'
                              : _userProfile!.pronouns!,
                          showInfo: true,
                        ),
                      // Display Race
                      if (_userProfile!.race != 'Rather Not Say')
                        _buildStatRow(
                            Icons.public, _userProfile!.race.toString()), // Changed icon for race/ethnicity
                      // Display Sexual Orientation
                      if (_userProfile!.sexualOrientation != 'Rather Not Say')
                        _buildStatRow(Icons.favorite, // Icon for sexual orientation
                            _userProfile!.sexualOrientation.toString()), // Display sexual orientation
                      // Display Tribes
                      if (_userProfile!.tribes != null && _userProfile!.tribes!.isNotEmpty && !_userProfile!.tribes!.contains('Rather Not Say'))
                        _buildStatRow(Icons.people_alt, // Changed icon for tribes
                            _userProfile!.tribes?.join(', ') ?? 'N/A'), // Display tribes, joined by comma
                      // Display Relationship Status
                      if (_userProfile!.relationshipStatus != 'Rather Not Say')
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
                      // Display Looking For
                      if (_userProfile!.lookingFor != 'Rather Not Say')
                        _buildExpectationRow(Icons.people, 'Looking For',
                            _userProfile!.lookingFor.toString()),
                      // Display Meet At
                      if (_userProfile!.meetAt != 'Rather Not Say')
                        _buildExpectationRow(Icons.home, 'Meet At',
                            _userProfile!.meetAt.toString()),
                      // Display Accepts NSFW pics?
                      if (_userProfile!.acceptsNsfwPics != 'Rather Not Say')
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
                        GestureDetector(
                          onTap: _navigateToTap,
                          child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[850],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                // Conditionally choose the icon based on _isFlameTapped
                                _isFlameTapped
                                    ? CupertinoIcons.flame
                                    : CupertinoIcons.flame_fill,
                                color: Colors.orange,
                                size: 28,
                              )),
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
                              child: const Icon(CupertinoIcons.chat_bubble_2,
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
