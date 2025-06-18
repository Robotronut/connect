import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Keep this import even if not directly used in MainBrowseScreen
import 'package:connect/services/secure_storage_service.dart';
import 'package:connect/services/api_service.dart'; // Import your API service
import 'package:connect/models/user_model.dart'; // Import your user model

import 'package:connect/screens/edit_profile_screen.dart'; // Ensure this path is correct
import 'package:connect/screens/profile_screen.dart'; // Ensure this path is correct

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

  // Filter states for individual dialogs
  String? _selectedPosition; // Holds the selected position for filtering
  bool _isPositionFilterEnabled = false; // Controls the position filter toggle

  RangeValues _selectedAgeRange = const RangeValues(18, 99); // Default age range
  bool _isAgeFilterEnabled = false; // Controls the age filter toggle

  bool _showOnlyOnline = false; // True to filter for online users, false for all users
  bool _isOnlineFilterEnabled = false; // Controls the online filter toggle

  bool _isFreshEnabled = false; // Controls the Fresh filter toggle

  bool _showOnlyFavorites = false; // True to filter for favorites, false for all users
  bool _isFavoriteFilterEnabled = false; // Controls the favorite filter toggle

  List<String> _selectedTags = []; // Stores selected tags/tribes for individual filter
  bool _isTagsFilterEnabled = false; // Controls the tags filter toggle

  List<String> finalPositionsFromMoreFilters =  [];
  List<String> finalGenders = [];
  bool finalHasPhotos = false;
  bool finalHasFacePics = false;

  bool finalHasAlbums = false;
  String finalBodyType = '';
  String finalHeight = '';
  String finalWeight = '';
  String finalRelationshipStatus = '';
  bool finalAcceptsNsfwPics =  false;
  String finalLookingFor = '';
  String finalMeetAt = '';
  bool finalHaventChattedToday = false;


  // Filter states for MoreFiltersScreen (these will be updated by MoreFiltersScreen)
  bool _isGlobalFilterEnabled = false; // Global toggle for all filters within MoreFiltersScreen
  bool _selectedFavoritesFromMoreFilters = false; // From MoreFiltersScreen
  bool _selectedOnlineFromMoreFilters = false; // From MoreFiltersScreen
  bool _selectedRightNow = false;
  String? _selectedMinAgeFromMoreFilters; // Age from MoreFiltersScreen, as a single String
  List<String> _selectedGenders = [];
  List<String> _selectedPositionsFromMoreFilters = []; // Positions from MoreFiltersScreen
  List<String> _selectedPhotos = [];
  List<String> _selectedTribes = []; // Tribes from MoreFiltersScreen
  String? _selectedBodyType;
  String? _selectedHeight;
  String? _selectedWeight;
  String? _selectedRelationshipStatus;
  bool _acceptsNsfwPics = false;
  String? _selectedLookingFor;
  String? _selectedMeetAt;
  bool _haventChattedToday = false;


  // Filter options for dialogs/screens
  final List<String> _ageOptions = List<int>.generate(82, (i) => i + 18).map((e) => e.toString()).toList(); // Ages from 18 to 99

  final List<String> _genderOptions = ['Men', 'Women', 'Non-Binary', 'More Genders', 'Not Specified'];

  final List<Map<String, dynamic>> _positionFilterOptions = [ // Used by PositionFilterDialog and MoreFiltersScreen
    {'text': 'Top', 'icon': Icons.arrow_upward},
    {'text': 'Vers Top', 'icon': Icons.north_east},
    {'text': 'Versatile', 'icon': Icons.swap_vert},
    {'text': 'Vers Bottom', 'icon': Icons.south_east},
    {'text': 'Bottom', 'icon': Icons.arrow_downward},
    {'text': 'Side', 'icon': Icons.swap_horiz},
    {'text': 'Not Specified', 'icon': Icons.help_outline},
  ];

  final List<String> _photoOptions = ['Has photos', 'Has face pics', 'Has album(s)'];
  final List<String> _tribeOptions = ['Bear', 'Chub', 'Clean-cut', 'Daddy', 'Discreet', 'Geek', 'Jock', 'Leather', 'Masc', 'Otter', 'Poz', 'Rugged', 'Trans', 'Twink', 'Uniform'];
  final Map<String, List<String>> _allTagOptions = {
    'Kinks': ['anon', 'bator', 'bb', 'bondage', 'bubblebutt', 'carplay', 'chastity', 'commando', 'condoms', 'condomsonly', 'cruising', 'cut', 'dirty', 'discreet', 'dl', 'dom', 'dtf', 'edging', 'feet', 'ff', 'flexible', 'furries', 'fwb', 'gear', 'gh', 'gooner', 'group', 'hands', 'hosting', 'hung', 'jo', 'kink', 'kissing', 'latex', 'leather', 'limits', 'lingerie', 'looking', 'muscle', 'nylon', 'otter', 'pic4pic', 'poz', 'sissy', 'smooth', 'sober', 't4t', 'trans', 'twink', 'twunk', 'uniform', 'visiting', 'watching', 'ws'],
    'Hobbies': ['anime', 'apres ski', 'art', 'beach', 'brunch', 'concerts', 'cooking', 'dancing', 'diy', 'fashion', 'gaming', 'hiking', 'karaoke', 'movies', 'music', 'naps', 'popmusic', 'reading', 'rpdr', 'tattoos', 'tennis', 'theater', 'tv', 'weightlifting', 'workingout', 'writing', 'yoga'],
    'Personality': ['adventurous', 'catperson', 'chill', 'confident', 'curious', 'direct', 'dogperson', 'fun', 'goofy', 'kind', 'loyal', 'mature', 'outgoing', 'parent', 'reliable', 'romantic', 'shy', 'unicorn'],
    'Other Tags': ['bear', 'beard', 'bi', 'chub', 'cleancut', 'college', 'couple', 'cub', 'cuddling', 'daddy', 'dating', 'drag', 'drugfree', 'femme', 'friends', 'gaymer', 'geek', 'hairy', 'jock', 'leather', 'masc', 'military', 'nosmoking', 'nylon', 'otter', 'pic4pic', 'poz', 'sissy', 'smooth', 'sober', 't4t', 'trans', 'twink', 'twunk', 'uniform'], // Combined from _tribeOptions and other possible tags
  };


  final List<String> _bodyTypeOptions = ['Slim', 'Average', 'Athletic', 'Muscular', 'A few extra pounds'];
  final List<String> _heightOptions = List<int>.generate(61, (i) => i + 150).map((e) => '${e} cm').toList(); // 150cm to 210cm
  final List<String> _weightOptions = List<int>.generate(101, (i) => i + 50).map((e) => '${e} kg').toList(); // 50kg to 150kg
  final List<String> _relationshipStatusOptions = ['Single', 'In a Relationship', 'Married', 'Complicated'];
  final List<String> _lookingForOptions = ['Chat', 'Friendship', 'Hookups', 'Long-term Relationship', 'Dating'];
  final List<String> _meetAtOptions = ['My Place', 'Your Place', 'Public Place', 'Online'];


  @override
  void initState() {
    super.initState();
    _fetchLoggedInUser();
    _fetchUsers();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Fetches the currently logged-in user's profile.
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

  /// Fetches users from the API, with optional pagination and filtering.
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
      // Logic for combining filters from individual dialogs and MoreFiltersScreen
      // Priority: MoreFiltersScreen if its global toggle is enabled.
      // Otherwise, individual dialog filters take effect.

      String? finalPosition;
      int? finalMinAge;
      int? finalMaxAge;
      bool? finalOnlineStatus;
      bool? finalIsFresh;
      bool? finalIsFavorite;
      List<String>? finalTagsToApi; // Consolidated tags parameter for API


      // If global filter is enabled from MoreFiltersScreen, override individual filters
      if (_isGlobalFilterEnabled) {
        finalIsFavorite = _selectedFavoritesFromMoreFilters;
        finalOnlineStatus = _selectedOnlineFromMoreFilters;
        finalMinAge = _selectedMinAgeFromMoreFilters != null ? int.tryParse(_selectedMinAgeFromMoreFilters!) : null;
        finalMaxAge = _selectedMinAgeFromMoreFilters != null ? 99 : null;
        finalGenders = (_selectedGenders.isNotEmpty ? _selectedGenders : null)!;
        finalPositionsFromMoreFilters = (_selectedPositionsFromMoreFilters.isNotEmpty ? _selectedPositionsFromMoreFilters : null)!;
        finalHasPhotos = _selectedPhotos.contains('Has photos');
        finalHasFacePics = _selectedPhotos.contains('Has face pics');
        finalHasAlbums = _selectedPhotos.contains('Has album(s)');
        finalBodyType = _selectedBodyType!;
        finalHeight = _selectedHeight!;
        finalWeight = _selectedWeight!;
        finalRelationshipStatus = _selectedRelationshipStatus!;
        finalAcceptsNsfwPics = _acceptsNsfwPics;
        finalLookingFor = _selectedLookingFor!;
        finalMeetAt = _selectedMeetAt!;
        finalHaventChattedToday = _haventChattedToday;
        finalIsFresh = _selectedRightNow; // Assuming "Right Now" covers "Fresh" in MoreFiltersScreen

        // When global filter is ON, use _selectedTribes for the consolidated tags parameter
        finalTagsToApi = _selectedTribes.isNotEmpty ? _selectedTribes : null;

        // Reset individual filter states if global filter is active
        _isPositionFilterEnabled = false;
        _isAgeFilterEnabled = false;
        _isOnlineFilterEnabled = false;
        _isFreshEnabled = false;
        _isFavoriteFilterEnabled = false;
        _isTagsFilterEnabled = false; // Important: turn off individual tags filter
        _selectedTags.clear(); // Clear individual tags selection to avoid stale data
      } else {
        // Apply filters from individual dialogs if global filter is OFF
        if (_isPositionFilterEnabled) {
          finalPosition = _selectedPosition;
        }
        if (_isAgeFilterEnabled) {
          finalMinAge = _selectedAgeRange.start.round();
          finalMaxAge = _selectedAgeRange.end.round();
        }
        if (_isOnlineFilterEnabled) {
          finalOnlineStatus = _showOnlyOnline;
        }
        if (_isFreshEnabled) {
          finalIsFresh = true;
        }
        if (_isFavoriteFilterEnabled) {
          finalIsFavorite = _showOnlyFavorites;
        }
        // When global filter is OFF, use _selectedTags for the consolidated tags parameter if enabled
        if (_isTagsFilterEnabled) {
          finalTagsToApi = _selectedTags.isNotEmpty ? _selectedTags : null;
        }
      }

      final fetchedUsers = await ApiService.getPeople(
        pageNumber: _currentPage,
        pageSize: _pageSize,
        position: finalPosition,
        minAge: finalMinAge,
        maxAge: finalMaxAge,
        onlineStatus: finalOnlineStatus,
        isFresh: finalIsFresh,
        isFavorite: finalIsFavorite,
        tags: finalTagsToApi, // Pass consolidated tags parameter
        // The 'tribes' parameter is removed from here to avoid redundancy and potential conflicts
        // if your API considers 'tags' and 'tribes' as different facets of the same filtering concept.

        // Remaining MoreFiltersScreen specific filters (will be null if _isGlobalFilterEnabled is false)
        isRightNow: _isGlobalFilterEnabled ? _selectedRightNow : null,
        genders: _isGlobalFilterEnabled ? finalGenders : null,
        moreFilterPositions: _isGlobalFilterEnabled ? finalPositionsFromMoreFilters : null,
        hasPhotos: _isGlobalFilterEnabled ? finalHasPhotos : null,
        hasFacePics: _isGlobalFilterEnabled ? finalHasFacePics : null,
        hasAlbums: _isGlobalFilterEnabled ? finalHasAlbums : null,
        bodyType: _isGlobalFilterEnabled ? finalBodyType : null,
        height: _isGlobalFilterEnabled ? finalHeight : null,
        weight: _isGlobalFilterEnabled ? finalWeight : null,
        relationshipStatus: _isGlobalFilterEnabled ? finalRelationshipStatus : null,
        acceptsNsfwPics: _isGlobalFilterEnabled ? finalAcceptsNsfwPics : null,
        lookingFor: _isGlobalFilterEnabled ? finalLookingFor : null,
        meetAt: _isGlobalFilterEnabled ? finalMeetAt : null,
        haventChattedToday: _isGlobalFilterEnabled ? finalHaventChattedToday : null,
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

  /// Handles scroll events for infinite scrolling.
  void _onScroll() {
    if (!_isLoading &&
        _hasMore &&
        _scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
      _loadMoreUsers();
    }
  }

  /// Loads more users by incrementing the page number.
  Future<void> _loadMoreUsers() async {
    if (_isLoading) return;
    await _fetchUsers(isLoadMore: true);
  }

  /// Refreshes all user data and logged-in user data.
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

  /// Shows the Position filter dialog as a bottom sheet.
  Future<void> _showPositionFilterDialog() async {
    final result = await showModalBottomSheet<Map<String, dynamic>?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext dialogContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(dialogContext).viewInsets.bottom,
          ),
          child: PositionFilterDialog(
            initialSelectedPosition: _selectedPosition,
            initialFilterEnabled: _isPositionFilterEnabled,
            positionOptions: _positionFilterOptions,
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedPosition = result['selectedPosition'];
        _isPositionFilterEnabled = result['filterEnabled'];
        _currentPage = 1;
        _hasMore = true;
        _users.clear();
      });
      _fetchUsers();
    }
  }

  /// Shows the Age filter dialog as a bottom sheet.
  Future<void> _showAgeFilterDialog() async {
    final result = await showModalBottomSheet<Map<String, dynamic>?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext dialogContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(dialogContext).viewInsets.bottom,
          ),
          child: AgeFilterDialog(
            initialAgeRange: _selectedAgeRange,
            initialFilterEnabled: _isAgeFilterEnabled,
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedAgeRange = result['selectedAgeRange'];
        _isAgeFilterEnabled = result['filterEnabled'];
        _currentPage = 1;
        _hasMore = true;
        _users.clear();
      });
      _fetchUsers(); // Refetch users with new age filter
    }
  }

  /// Shows the Online filter dialog as a bottom sheet.
  Future<void> _showOnlineFilterDialog() async {
    final result = await showModalBottomSheet<Map<String, dynamic>?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext dialogContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(dialogContext).viewInsets.bottom,
          ),
          child: OnlineFilterDialog(
            initialShowOnlyOnline: _showOnlyOnline,
            initialFilterEnabled: _isOnlineFilterEnabled,
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        _showOnlyOnline = result['showOnlyOnline'];
        _isOnlineFilterEnabled = result['filterEnabled'];
        _currentPage = 1;
        _hasMore = true;
        _users.clear();
      });
      _fetchUsers(); // Refetch users with new online filter
    }
  }

  /// Shows the Fresh filter dialog as a bottom sheet.
  Future<void> _showFreshFilterDialog() async {
    final result = await showModalBottomSheet<Map<String, dynamic>?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext dialogContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(dialogContext).viewInsets.bottom,
          ),
          child: FreshFilterDialog(
            initialIsFreshEnabled: _isFreshEnabled,
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        _isFreshEnabled = result['isFreshEnabled'] ?? false;
        _currentPage = 1;
        _hasMore = true;
        _users.clear();
      });
      _fetchUsers(); // Refetch users with new fresh filter
    }
  }

  /// Shows the Favorite filter dialog as a bottom sheet.
  Future<void> _showFavoriteFilterDialog() async {
    final result = await showModalBottomSheet<Map<String, dynamic>?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext dialogContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(dialogContext).viewInsets.bottom,
          ),
          child: FavoriteFilterDialog(
            initialShowOnlyFavorites: _showOnlyFavorites,
            initialFilterEnabled: _isFavoriteFilterEnabled,
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        _showOnlyFavorites = result['showOnlyFavorites'] ?? false;
        _isFavoriteFilterEnabled = result['filterEnabled'] ?? false;
        _currentPage = 1;
        _hasMore = true;
        _users.clear();
      });
      _fetchUsers(); // Refetch users with new favorite filter
    }
  }

  /// Shows the Tags filter page.
  Future<void> _showTagsFilterScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TagsScreen(
          initialSelectedTags: _selectedTags,
          allTagOptions: _allTagOptions,
          initialIsFilterEnabled: _isTagsFilterEnabled,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedTags = List<String>.from(result['selectedTags'] ?? []);
        _isTagsFilterEnabled = result['filterEnabled'] ?? false;
        _currentPage = 1;
        _hasMore = true;
        _users.clear();
      });
      _fetchUsers(); // Refetch users with new tags filter
    }
  }

  /// Shows the More Filters screen.
  Future<void> _showMoreFiltersScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MoreFiltersScreen(
          initialIsGlobalFilterEnabled: _isGlobalFilterEnabled,
          initialSelectedFavorites: _selectedFavoritesFromMoreFilters,
          initialSelectedOnline: _selectedOnlineFromMoreFilters,
          initialSelectedRightNow: _selectedRightNow,
          initialSelectedMinAge: _selectedMinAgeFromMoreFilters,
          initialSelectedGenders: _selectedGenders,
          initialSelectedPositions: _selectedPositionsFromMoreFilters,
          initialSelectedPhotos: _selectedPhotos,
          initialSelectedTribes: _selectedTribes,
          initialSelectedBodyType: _selectedBodyType,
          initialSelectedHeight: _selectedHeight,
          initialSelectedWeight: _selectedWeight,
          initialSelectedRelationshipStatus: _selectedRelationshipStatus,
          initialAcceptsNsfwPics: _acceptsNsfwPics,
          initialSelectedLookingFor: _selectedLookingFor,
          initialSelectedMeetAt: _selectedMeetAt,
          initialHaventChattedToday: _haventChattedToday,

          ageOptions: _ageOptions,
          genderOptions: _genderOptions,
          positionOptions: _positionFilterOptions,
          photoOptions: _photoOptions,
          tribeOptions: _tribeOptions,
          lookingForOptions: _lookingForOptions,
          meetAtOptions: _meetAtOptions,
          bodyTypeOptions: _bodyTypeOptions,
          heightOptions: _heightOptions,
          weightOptions: _weightOptions,
          relationshipStatusOptions: _relationshipStatusOptions,
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _isGlobalFilterEnabled = result['isGlobalFilterEnabled'] ?? false;
        _selectedFavoritesFromMoreFilters = result['selectedFavorites'] ?? false;
        _selectedOnlineFromMoreFilters = result['selectedOnline'] ?? false;
        _selectedRightNow = result['selectedRightNow'] ?? false;
        _selectedMinAgeFromMoreFilters = result['selectedMinAge'];
        _selectedGenders = List<String>.from(result['selectedGenders'] ?? []);
        _selectedPositionsFromMoreFilters = List<String>.from(result['selectedPositions'] ?? []);
        _selectedPhotos = List<String>.from(result['selectedPhotos'] ?? []);
        _selectedTribes = List<String>.from(result['selectedTribes'] ?? []);
        _selectedBodyType = result['selectedBodyType'];
        _selectedHeight = result['selectedHeight'];
        _selectedWeight = result['selectedWeight'];
        _selectedRelationshipStatus = result['selectedRelationshipStatus'];
        _acceptsNsfwPics = result['acceptsNsfwPics'] ?? false;
        _selectedLookingFor = result['selectedLookingFor'];
        _selectedMeetAt = result['selectedMeetAt'];
        _haventChattedToday = result['haventChattedToday'] ?? false;

        _currentPage = 1; // Reset page to 1 when filters change
        _hasMore = true; // Assume new data exists
        _users.clear(); // Clear current users to show new filtered results
      });
      _fetchUsers(); // Refetch users with new filters
    }
  }


  @override
  Widget build(BuildContext context) {
    ImageProvider userAvatarImage;
    if (_loggedInUser != null && _loggedInUser!.imageUrls.isNotEmpty) {
      userAvatarImage = NetworkImage(_loggedInUser!.imageUrls[0]);
    } else {
      userAvatarImage = const AssetImage(
          'assets/placeholder_user.jpg'); // Ensure you have this asset
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
                              color: Colors.white.withAlpha(178)),
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
                  _buildPillButton(Icons.star_outline, "Favorite", onTap: _showFavoriteFilterDialog), // Favorite filter
                  _buildPillButton(Icons.cake, "Age", onTap: _showAgeFilterDialog), // Age filter
                  _buildPillButton(Icons.wifi, "Online", onTap: _showOnlineFilterDialog), // Online filter
                  _buildPillButton(Icons.location_on, "Position", onTap: _showPositionFilterDialog),
                  _buildPillButton(Icons.fiber_new, "Fresh", onTap: _showFreshFilterDialog), // Fresh filter
                  _buildPillButton(Icons.tag, "Tags", onTap: _showTagsFilterScreen), // Tags filter now goes to TagsScreen
                  _buildPillButton(Icons.filter_list, "More Filters", onTap: _showMoreFiltersScreen),
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
                    itemCount: _users.length + (_hasMore ? 1 : 0),
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

  Widget _buildPillButton(IconData icon, String label, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: GestureDetector( // Added GestureDetector to make the button tappable
        onTap: onTap,
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
      ),
    );
  }
}

/// A dialog widget for selecting a position filter.
class PositionFilterDialog extends StatefulWidget {
  final String? initialSelectedPosition;
  final bool initialFilterEnabled;
  final List<Map<String, dynamic>> positionOptions;

  const PositionFilterDialog({
    super.key,
    this.initialSelectedPosition,
    required this.initialFilterEnabled,
    required this.positionOptions,
  });

  @override
  _PositionFilterDialogState createState() => _PositionFilterDialogState();
}

class _PositionFilterDialogState extends State<PositionFilterDialog> {
  String? _tempSelectedPosition;
  late bool _tempIsFilterEnabled;

  @override
  void initState() {
    super.initState();
    _tempSelectedPosition = widget.initialSelectedPosition;
    _tempIsFilterEnabled = widget.initialFilterEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Container( // Changed Dialog to Container
      decoration: BoxDecoration(
        color: Colors.black, // Dark background for the sheet
        borderRadius: BorderRadius.only( // Rounded corners only at the top
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Use minimum space required
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _tempSelectedPosition = null; // Reset selection
                    _tempIsFilterEnabled = false; // Turn off filter
                  });
                },
                child: const Text('Reset', style: TextStyle(color: Colors.yellow)),
              ),
              const Text(
                'Position',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Switch(
                value: _tempIsFilterEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _tempIsFilterEnabled = value;
                  });
                },
                activeColor: Colors.yellow,
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.grey.withOpacity(0.5),
              ),
            ],
          ),
          const SizedBox(height: 20),
          AbsorbPointer( // Disable interaction when filter is off
            absorbing: !_tempIsFilterEnabled,
            child: Opacity( // Visually dim when filter is off
              opacity: _tempIsFilterEnabled ? 1.0 : 0.5,
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.5,
                ),
                itemCount: widget.positionOptions.length,
                itemBuilder: (context, index) {
                  final option = widget.positionOptions[index];
                  final isSelected = _tempSelectedPosition == option['text'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _tempSelectedPosition = isSelected ? null : option['text'];
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.yellow : Colors.grey[800],
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: isSelected ? Colors.yellow.shade700 : Colors.grey.shade700,
                          width: 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                          BoxShadow(
                            color: Colors.yellow.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ]
                            : [],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            option['icon'],
                            color: isSelected ? Colors.black : Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            option['text'],
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop({
                  'selectedPosition': _tempSelectedPosition,
                  'filterEnabled': _tempIsFilterEnabled,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow, // Grindr's accent color
                foregroundColor: Colors.black, // Text color for the button
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Apply',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A dialog widget for selecting an age range filter.
class AgeFilterDialog extends StatefulWidget {
  final RangeValues initialAgeRange;
  final bool initialFilterEnabled;

  const AgeFilterDialog({
    super.key,
    required this.initialAgeRange,
    required this.initialFilterEnabled,
  });

  @override
  _AgeFilterDialogState createState() => _AgeFilterDialogState();
}

class _AgeFilterDialogState extends State<AgeFilterDialog> {
  late RangeValues _tempAgeRange;
  late bool _tempIsFilterEnabled;

  @override
  void initState() {
    super.initState();
    _tempAgeRange = widget.initialAgeRange;
    _tempIsFilterEnabled = widget.initialFilterEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _tempAgeRange = const RangeValues(18, 99); // Reset to default
                    _tempIsFilterEnabled = false; // Turn off filter
                  });
                },
                child: const Text('Reset', style: TextStyle(color: Colors.yellow)),
              ),
              const Text(
                'Age',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Switch(
                value: _tempIsFilterEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _tempIsFilterEnabled = value;
                  });
                },
                activeColor: Colors.yellow,
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.grey.withOpacity(0.5),
              ),
            ],
          ),
          const SizedBox(height: 20),
          AbsorbPointer( // Disable interaction when filter is off
            absorbing: !_tempIsFilterEnabled,
            child: Opacity( // Visually dim when filter is off
              opacity: _tempIsFilterEnabled ? 1.0 : 0.5,
              child: Column(
                children: [
                  Text(
                    '${_tempAgeRange.start.round()} - ${_tempAgeRange.end.round()}',
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  RangeSlider(
                    values: _tempAgeRange,
                    min: 18,
                    max: 99,
                    divisions: 81, // (99 - 18)
                    labels: RangeLabels(
                      _tempAgeRange.start.round().toString(),
                      _tempAgeRange.end.round().toString(),
                    ),
                    activeColor: Colors.yellow,
                    inactiveColor: Colors.grey.withOpacity(0.7),
                    onChanged: (RangeValues newValues) {
                      setState(() {
                        _tempAgeRange = newValues;
                      });
                    },
                  ),
                  const Text(
                    'Drag to adjust range',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop({
                  'selectedAgeRange': _tempAgeRange,
                  'filterEnabled': _tempIsFilterEnabled,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Apply',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A dialog widget for selecting online status filter.
class OnlineFilterDialog extends StatefulWidget {
  final bool initialShowOnlyOnline;
  final bool initialFilterEnabled;

  const OnlineFilterDialog({
    super.key,
    required this.initialShowOnlyOnline,
    required this.initialFilterEnabled,
  });

  @override
  _OnlineFilterDialogState createState() => _OnlineFilterDialogState();
}

class _OnlineFilterDialogState extends State<OnlineFilterDialog> {
  late bool _tempShowOnlyOnline;
  late bool _tempIsFilterEnabled;

  @override
  void initState() {
    super.initState();
    _tempShowOnlyOnline = widget.initialShowOnlyOnline;
    _tempIsFilterEnabled = widget.initialFilterEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _tempShowOnlyOnline = false; // Reset to show all
                    _tempIsFilterEnabled = false; // Turn off filter
                  });
                },
                child: const Text('Reset', style: TextStyle(color: Colors.yellow)),
              ),
              const Text(
                'Online',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Switch(
                value: _tempIsFilterEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _tempIsFilterEnabled = value;
                  });
                },
                activeColor: Colors.yellow,
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.grey.withOpacity(0.5),
              ),
            ],
          ),
          const SizedBox(height: 20),
          AbsorbPointer( // Disable interaction when filter is off
            absorbing: !_tempIsFilterEnabled,
            child: Opacity( // Visually dim when filter is off
              opacity: _tempIsFilterEnabled ? 1.0 : 0.5,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _tempShowOnlyOnline ? 'Show Online Only' : 'Show All Users',
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      const SizedBox(width: 10),
                      Switch(
                        value: _tempShowOnlyOnline,
                        onChanged: (bool value) {
                          setState(() {
                            _tempShowOnlyOnline = value;
                          });
                        },
                        activeColor: Colors.green, // Green for online toggle
                        inactiveThumbColor: Colors.red, // Red for offline/all toggle
                        inactiveTrackColor: Colors.red.withOpacity(0.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Toggle to filter for online users',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop({
                  'showOnlyOnline': _tempShowOnlyOnline,
                  'filterEnabled': _tempIsFilterEnabled,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Apply',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A dialog widget for selecting fresh filter.
class FreshFilterDialog extends StatefulWidget {
  final bool initialIsFreshEnabled;

  const FreshFilterDialog({
    super.key,
    required this.initialIsFreshEnabled,
  });

  @override
  _FreshFilterDialogState createState() => _FreshFilterDialogState();
}

class _FreshFilterDialogState extends State<FreshFilterDialog> {
  late bool _tempIsFreshEnabled;

  @override
  void initState() {
    super.initState();
    _tempIsFreshEnabled = widget.initialIsFreshEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _tempIsFreshEnabled = false; // Reset to false
                  });
                },
                child: const Text('Reset', style: TextStyle(color: Colors.yellow)),
              ),
              const Text(
                'Fresh',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Switch(
                value: _tempIsFreshEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _tempIsFreshEnabled = value;
                  });
                },
                activeColor: Colors.yellow,
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.grey.withOpacity(0.5),
              ),
            ],
          ),
          const SizedBox(height: 20),
          AbsorbPointer( // Disable interaction when filter is off
            absorbing: !_tempIsFreshEnabled,
            child: Opacity( // Visually dim when filter is off
              opacity: _tempIsFreshEnabled ? 1.0 : 0.5,
              child: Column(
                children: [
                  Text(
                    _tempIsFreshEnabled ? 'Show Fresh Profiles' : 'Show All Profiles',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Toggle to filter for fresh profiles',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop({
                  'isFreshEnabled': _tempIsFreshEnabled,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Apply',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A dialog widget for selecting favorite filter.
class FavoriteFilterDialog extends StatefulWidget {
  final bool initialShowOnlyFavorites;
  final bool initialFilterEnabled;

  const FavoriteFilterDialog({
    super.key,
    required this.initialShowOnlyFavorites,
    required this.initialFilterEnabled,
  });

  @override
  _FavoriteFilterDialogState createState() => _FavoriteFilterDialogState();
}

class _FavoriteFilterDialogState extends State<FavoriteFilterDialog> {
  late bool _tempShowOnlyFavorites;
  late bool _tempIsFilterEnabled;

  @override
  void initState() {
    super.initState();
    _tempShowOnlyFavorites = widget.initialShowOnlyFavorites;
    _tempIsFilterEnabled = widget.initialFilterEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _tempShowOnlyFavorites = false; // Reset to show all
                    _tempIsFilterEnabled = false; // Turn off filter
                  });
                },
                child: const Text('Reset', style: TextStyle(color: Colors.yellow)),
              ),
              const Text(
                'Favorites',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Switch(
                value: _tempIsFilterEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _tempIsFilterEnabled = value;
                  });
                },
                activeColor: Colors.yellow,
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.grey.withOpacity(0.5),
              ),
            ],
          ),
          const SizedBox(height: 20),
          AbsorbPointer( // Disable interaction when filter is off
            absorbing: !_tempIsFilterEnabled,
            child: Opacity( // Visually dim when filter is off
              opacity: _tempIsFilterEnabled ? 1.0 : 0.5,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _tempShowOnlyFavorites ? 'Show Favorites Only' : 'Show All Users',
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      const SizedBox(width: 10),
                      Switch(
                        value: _tempShowOnlyFavorites,
                        onChanged: (bool value) {
                          setState(() {
                            _tempShowOnlyFavorites = value;
                          });
                        },
                        activeColor: Colors.green, // Green for favorite toggle
                        inactiveThumbColor: Colors.red, // Red for non-favorite/all toggle
                        inactiveTrackColor: Colors.red.withOpacity(0.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Toggle to filter for favorite users',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop({
                  'showOnlyFavorites': _tempShowOnlyFavorites,
                  'filterEnabled': _tempIsFilterEnabled,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Apply',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A screen for selecting and applying tags.
class TagsScreen extends StatefulWidget {
  final List<String> initialSelectedTags;
  final Map<String, List<String>> allTagOptions;
  final bool initialIsFilterEnabled;

  const TagsScreen({
    super.key,
    required this.initialSelectedTags,
    required this.allTagOptions,
    required this.initialIsFilterEnabled,
  });

  @override
  State<TagsScreen> createState() => _TagsScreenState();
}

class _TagsScreenState extends State<TagsScreen> {
  late List<String> _tempSelectedTags;
  late bool _tempIsFilterEnabled;
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredTags = [];

  // Variables for managing "See More/Less" functionality for each category
  final Map<String, int> _initialDisplayCount = {
    'Kinks': 6, // Show initial 6 kinks
    'Hobbies': 6, // Show initial 6 hobbies
    'Personality': 6, // Show initial 6 personality tags
    'Other Tags': 6, // Show initial 6 other tags
  };
  final Map<String, bool> _showAll = {};


  @override
  void initState() {
    super.initState();
    _tempSelectedTags = List.from(widget.initialSelectedTags);
    _tempIsFilterEnabled = widget.initialIsFilterEnabled;
    _searchController.addListener(_filterTags);
    widget.allTagOptions.keys.forEach((category) {
      _showAll[category] = false; // Initially show less for all categories
    });
    _filterTags(); // Initial filtering
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterTags() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredTags = []; // Reset filtered tags if search is empty
      } else {
        _filteredTags = widget.allTagOptions.values
            .expand((list) => list)
            .where((tag) => tag.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  void _onToggleTag(String tag) {
    setState(() {
      if (_tempSelectedTags.contains(tag)) {
        _tempSelectedTags.remove(tag);
      } else {
        if (_tempSelectedTags.length < 3) { // Limit to 3 tags
          _tempSelectedTags.add(tag);
        } else {
          // Optionally, show a message to the user that only 3 tags can be selected
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You can only select up to 3 tags.')),
          );
        }
      }
    });
  }

  void _resetTags() {
    setState(() {
      _tempSelectedTags.clear();
      _tempIsFilterEnabled = false;
      _searchController.clear();
      widget.allTagOptions.keys.forEach((category) {
        _showAll[category] = false; // Reset "See More/Less" state
      });
    });
  }

  void _applyTags() {
    Navigator.pop(context, {
      'selectedTags': _tempSelectedTags,
      'filterEnabled': _tempIsFilterEnabled,
    });
  }

  Widget _buildTagCategory(String category, List<String> tags) {
    final int displayCount = _initialDisplayCount[category] ?? 6;
    final bool currentShowAll = _showAll[category] ?? false;
    final List<String> tagsToDisplay = currentShowAll ? tags : tags.take(displayCount).toList();
    final bool hasMore = tags.length > displayCount;

    if (tags.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            children: [
              Icon(
                _getCategoryIcon(category), // Get icon for the category
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                category,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: tagsToDisplay.map((tag) {
            final bool isSelected = _tempSelectedTags.contains(tag);
            return GestureDetector(
              onTap: _tempIsFilterEnabled ? () => _onToggleTag(tag) : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                decoration: BoxDecoration(
                  color: isSelected && _tempIsFilterEnabled ? Colors.yellow : Colors.white.withAlpha(25),
                  borderRadius: BorderRadius.circular(25.0),
                  border: Border.all(
                    color: isSelected && _tempIsFilterEnabled ? Colors.yellow : Colors.white.withAlpha(50),
                    width: 1.0,
                  ),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: isSelected && _tempIsFilterEnabled ? Colors.black : Colors.white,
                    fontSize: 14.0,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (hasMore)
          GestureDetector(
            onTap: () {
              setState(() {
                _showAll[category] = !currentShowAll;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Text(
                currentShowAll ? '- See Less' : '+ See ${tags.length - displayCount} More',
                style: const TextStyle(color: Colors.yellow, fontSize: 14),
              ),
            ),
          ),
        const SizedBox(height: 20),
        const Divider(color: Colors.grey, height: 1),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Kinks':
        return Icons.bookmark;
      case 'Hobbies':
        return Icons.sports_esports;
      case 'Personality':
        return Icons.psychology;
      default:
        return Icons.tag;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Tags [${_tempSelectedTags.length}/3]', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              // Show info about tags
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(color: Colors.white.withAlpha(178)),
                prefixIcon: Icon(Icons.search, color: Colors.white.withAlpha(229)),
                filled: true,
                fillColor: Colors.white.withAlpha(25),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _resetTags,
                  child: const Text('Reset', style: TextStyle(color: Colors.yellow)),
                ),
                Switch(
                  value: _tempIsFilterEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      _tempIsFilterEnabled = value;
                    });
                  },
                  activeColor: Colors.yellow,
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.grey.withOpacity(0.5),
                ),
              ],
            ),
          ),
          Expanded(
            child: AbsorbPointer(
              absorbing: !_tempIsFilterEnabled,
              child: Opacity(
                opacity: _tempIsFilterEnabled ? 1.0 : 0.5,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_searchController.text.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12.0),
                              child: Text(
                                'Search Results',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (_filteredTags.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20.0),
                                child: Center(
                                  child: Text(
                                    'No tags found.',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              )
                            else
                              Wrap(
                                spacing: 8.0,
                                runSpacing: 8.0,
                                children: _filteredTags.map((tag) {
                                  final bool isSelected = _tempSelectedTags.contains(tag);
                                  return GestureDetector(
                                    onTap: () => _onToggleTag(tag),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                                      decoration: BoxDecoration(
                                        color: isSelected ? Colors.yellow : Colors.white.withAlpha(25),
                                        borderRadius: BorderRadius.circular(25.0),
                                        border: Border.all(
                                          color: isSelected ? Colors.yellow : Colors.white.withAlpha(50),
                                          width: 1.0,
                                        ),
                                      ),
                                      child: Text(
                                        tag,
                                        style: TextStyle(
                                          color: isSelected ? Colors.black : Colors.white,
                                          fontSize: 14.0,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            const SizedBox(height: 20),
                            const Divider(color: Colors.grey, height: 1),
                          ],
                        )
                      else
                        ..._allTagOptions.entries.map((entry) {
                          return _buildTagCategory(entry.key, entry.value);
                        }).toList(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _tempIsFilterEnabled ? _applyTags : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Done [${_tempSelectedTags.length}/3]',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _allTagOptions {
  static var entries;
}

/// A screen for applying various filters to user browsing.
class MoreFiltersScreen extends StatefulWidget {
  final bool initialIsGlobalFilterEnabled;
  final bool initialSelectedFavorites;
  final bool initialSelectedOnline;
  final bool initialSelectedRightNow;
  final String? initialSelectedMinAge;
  final List<String> initialSelectedGenders;
  final List<String> initialSelectedPositions;
  final List<String> initialSelectedPhotos;
  final List<String> initialSelectedTribes;
  final String? initialSelectedBodyType;
  final String? initialSelectedHeight;
  final String? initialSelectedWeight;
  final String? initialSelectedRelationshipStatus;
  final bool initialAcceptsNsfwPics;
  final String? initialSelectedLookingFor;
  final String? initialSelectedMeetAt;
  final bool initialHaventChattedToday;

  // Options lists
  final List<String> ageOptions;
  final List<String> genderOptions;
  final List<Map<String, dynamic>> positionOptions;
  final List<String> photoOptions;
  final List<String> tribeOptions;
  final List<String> bodyTypeOptions;
  final List<String> heightOptions;
  final List<String> weightOptions;
  final List<String> relationshipStatusOptions;
  final List<String> lookingForOptions;
  final List<String> meetAtOptions;


  const MoreFiltersScreen({
    super.key,
    required this.initialIsGlobalFilterEnabled,
    required this.initialSelectedFavorites,
    required this.initialSelectedOnline,
    required this.initialSelectedRightNow,
    this.initialSelectedMinAge,
    required this.initialSelectedGenders,
    required this.initialSelectedPositions,
    required this.initialSelectedPhotos,
    required this.initialSelectedTribes,
    this.initialSelectedBodyType,
    this.initialSelectedHeight,
    this.initialSelectedWeight,
    this.initialSelectedRelationshipStatus,
    required this.initialAcceptsNsfwPics,
    this.initialSelectedLookingFor,
    this.initialSelectedMeetAt,
    required this.initialHaventChattedToday,

    required this.ageOptions,
    required this.genderOptions,
    required this.positionOptions,
    required this.photoOptions,
    required this.tribeOptions,
    required this.bodyTypeOptions,
    required this.heightOptions,
    required this.weightOptions,
    required this.relationshipStatusOptions,
    required this.lookingForOptions,
    required this.meetAtOptions,
  });

  @override
  State<MoreFiltersScreen> createState() => _MoreFiltersScreenState();
}

class _MoreFiltersScreenState extends State<MoreFiltersScreen> {
  late bool _tempIsGlobalFilterEnabled;
  late bool _tempSelectedFavorites;
  late bool _tempSelectedOnline;
  late bool _tempSelectedRightNow;
  String? _tempSelectedMinAge;
  late List<String> _tempSelectedGenders;
  late List<String> _tempSelectedPositions;
  late List<String> _tempSelectedPhotos;
  late List<String> _tempSelectedTribes;
  String? _tempSelectedBodyType;
  String? _tempSelectedHeight;
  String? _tempSelectedWeight;
  String? _tempSelectedRelationshipStatus;
  late bool _tempAcceptsNsfwPics;
  String? _tempSelectedLookingFor;
  String? _tempSelectedMeetAt;
  late bool _tempHaventChattedToday;


  @override
  void initState() {
    super.initState();
    _tempIsGlobalFilterEnabled = widget.initialIsGlobalFilterEnabled;
    _tempSelectedFavorites = widget.initialSelectedFavorites;
    _tempSelectedOnline = widget.initialSelectedOnline;
    _tempSelectedRightNow = widget.initialSelectedRightNow;
    _tempSelectedMinAge = widget.initialSelectedMinAge;
    _tempSelectedGenders = List.from(widget.initialSelectedGenders);
    _tempSelectedPositions = List.from(widget.initialSelectedPositions);
    _tempSelectedPhotos = List.from(widget.initialSelectedPhotos);
    _tempSelectedTribes = List.from(widget.initialSelectedTribes);
    _tempSelectedBodyType = widget.initialSelectedBodyType;
    _tempSelectedHeight = widget.initialSelectedHeight;
    _tempSelectedWeight = widget.initialSelectedWeight;
    _tempSelectedRelationshipStatus = widget.initialSelectedRelationshipStatus;
    _tempAcceptsNsfwPics = widget.initialAcceptsNsfwPics;
    _tempSelectedLookingFor = widget.initialSelectedLookingFor;
    _tempSelectedMeetAt = widget.initialSelectedMeetAt;
    _tempHaventChattedToday = widget.initialHaventChattedToday;
  }

  void _resetFilters() {
    setState(() {
      _tempIsGlobalFilterEnabled = false;
      _tempSelectedFavorites = false;
      _tempSelectedOnline = false;
      _tempSelectedRightNow = false;
      _tempSelectedMinAge = null;
      _tempSelectedGenders = [];
      _tempSelectedPositions = [];
      _tempSelectedPhotos = [];
      _tempSelectedTribes = [];
      _tempSelectedBodyType = null;
      _tempSelectedHeight = null;
      _tempSelectedWeight = null;
      _tempSelectedRelationshipStatus = null;
      _tempAcceptsNsfwPics = false;
      _tempSelectedLookingFor = null;
      _tempSelectedMeetAt = null;
      _tempHaventChattedToday = false;
    });
  }

  void _applyFilters() {
    Navigator.pop(context, {
      'isGlobalFilterEnabled': _tempIsGlobalFilterEnabled,
      'selectedFavorites': _tempSelectedFavorites,
      'selectedOnline': _tempSelectedOnline,
      'selectedRightNow': _tempSelectedRightNow,
      'selectedMinAge': _tempSelectedMinAge,
      'selectedGenders': _tempSelectedGenders,
      'selectedPositions': _tempSelectedPositions,
      'selectedPhotos': _tempSelectedPhotos,
      'selectedTribes': _tempSelectedTribes,
      'selectedBodyType': _tempSelectedBodyType,
      'selectedHeight': _tempSelectedHeight,
      'selectedWeight': _tempSelectedWeight,
      'selectedRelationshipStatus': _tempSelectedRelationshipStatus,
      'acceptsNsfwPics': _tempAcceptsNsfwPics,
      'selectedLookingFor': _tempSelectedLookingFor,
      'selectedMeetAt': _tempSelectedMeetAt,
      'haventChattedToday': _tempHaventChattedToday,
    });
  }

  Widget _buildFilterSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildRadioListTile({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
    required bool isEnabled,
  }) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: RadioListTile<bool>(
        value: true,
        groupValue: value,
        onChanged: isEnabled ? onChanged : null,
        title: Text(title, style: TextStyle(color: isEnabled ? Colors.white : Colors.white.withOpacity(0.5))),
        activeColor: Colors.yellow,
        controlAffinity: ListTileControlAffinity.leading, // Checkbox on the left
        contentPadding: EdgeInsets.zero, // Remove default padding
      ),
    );
  }

  Widget _buildDropdownFilter({
    required String hintText,
    required String? selectedValue,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    required bool isEnabled,
  }) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        dropdownColor: Colors.grey[900],
        style: TextStyle(color: isEnabled ? Colors.white : Colors.white.withOpacity(0.5)), // Text for selected value in closed dropdown
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: isEnabled ? Colors.white.withOpacity(0.7) : Colors.white.withOpacity(0.3)), // Hint text color
          filled: true,
          fillColor: Colors.white.withAlpha(25),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: isEnabled ? Colors.white.withAlpha(50) : Colors.white.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: isEnabled ? Colors.yellow : Colors.white.withOpacity(0.3)),
          ),
        ),
        icon: Icon(Icons.arrow_drop_down, color: isEnabled ? Colors.white : Colors.white.withOpacity(0.5)), // Dropdown arrow color
        onChanged: isEnabled ? onChanged : null,
        items: options.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, style: TextStyle(color: isEnabled ? Colors.white : Colors.white.withOpacity(0.5))), // Text for options in the dropdown menu
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMultiSelectFilter({
    required List<String> options,
    required List<String> selectedValues,
    required ValueChanged<String> onToggle,
    required bool isEnabled,
    Map<String, IconData>? icons, // Optional icons for buttons like position
  }) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: Wrap(
        spacing: 8.0, // horizontal space between buttons
        runSpacing: 8.0, // vertical space between rows of buttons
        children: options.map((option) {
          final bool isSelected = selectedValues.contains(option);
          final IconData? icon = icons != null ? icons[option] : null;

          return GestureDetector(
            onTap: isEnabled ? () => onToggle(option) : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: isSelected && isEnabled ? Colors.yellow : Colors.white.withAlpha(25),
                borderRadius: BorderRadius.circular(25.0),
                border: Border.all(
                  color: isSelected && isEnabled ? Colors.yellow : Colors.white.withAlpha(50),
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min, // Make row only as big as its children
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: isSelected && isEnabled ? Colors.black : Colors.white, size: 16),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    option,
                    style: TextStyle(
                      color: isSelected && isEnabled ? Colors.black : Colors.white,
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine the opacity for disabled filters
    final bool filtersInteractable = _tempIsGlobalFilterEnabled;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Filters', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _resetFilters,
            child: const Text('Reset', style: TextStyle(color: Colors.yellow)),
          ),
          Switch(
            value: _tempIsGlobalFilterEnabled,
            onChanged: (value) {
              setState(() {
                _tempIsGlobalFilterEnabled = value;
              });
            },
            activeColor: Colors.yellow,
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.withOpacity(0.5),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Favorites
            _buildRadioListTile(
              title: 'Favorites',
              value: _tempSelectedFavorites,
              onChanged: (bool? value) {
                setState(() {
                  _tempSelectedFavorites = value ?? false;
                });
              },
              isEnabled: filtersInteractable,
            ),
            const Divider(color: Colors.grey, height: 1),

            // Online
            _buildRadioListTile(
              title: 'Online',
              value: _tempSelectedOnline,
              onChanged: (bool? value) {
                setState(() {
                  _tempSelectedOnline = value ?? false;
                });
              },
              isEnabled: filtersInteractable,
            ),
            const Divider(color: Colors.grey, height: 1),

            // Right Now
            _buildRadioListTile(
              title: 'Right Now',
              value: _tempSelectedRightNow,
              onChanged: (bool? value) {
                setState(() {
                  _tempSelectedRightNow = value ?? false;
                });
              },
              isEnabled: filtersInteractable,
            ),
            const Divider(color: Colors.grey, height: 1),

            // Age
            _buildFilterSectionTitle('Age'),
            _buildDropdownFilter(
              hintText: '18 yrs and over',
              selectedValue: _tempSelectedMinAge,
              options: widget.ageOptions.map((e) => '$e yrs and over').toList(), // Format age options
              onChanged: (newValue) {
                setState(() {
                  _tempSelectedMinAge = newValue?.replaceAll(' yrs and over', ''); // Store only the number
                });
              },
              isEnabled: filtersInteractable,
            ),
            const SizedBox(height: 16.0),
            const Divider(color: Colors.grey, height: 1),

            // Gender
            _buildFilterSectionTitle('Gender'),
            _buildMultiSelectFilter(
              options: widget.genderOptions,
              selectedValues: _tempSelectedGenders,
              onToggle: (gender) {
                setState(() {
                  if (_tempSelectedGenders.contains(gender)) {
                    _tempSelectedGenders.remove(gender);
                  } else {
                    _tempSelectedGenders.add(gender);
                  }
                });
              },
              isEnabled: filtersInteractable,
            ),
            const SizedBox(height: 16.0),
            const Divider(color: Colors.grey, height: 1),

            // Position
            _buildFilterSectionTitle('Position'),
            _buildMultiSelectFilter(
              options: widget.positionOptions.map((e) => e['text'] as String).toList(),
              selectedValues: _tempSelectedPositions,
              onToggle: (position) {
                setState(() {
                  if (_tempSelectedPositions.contains(position)) {
                    _tempSelectedPositions.remove(position);
                  } else {
                    _tempSelectedPositions.add(position);
                  }
                });
              },
              isEnabled: filtersInteractable,
              icons: { for (var item in widget.positionOptions) item['text'] as String : item['icon'] as IconData },
            ),
            const SizedBox(height: 16.0),
            const Divider(color: Colors.grey, height: 1),

            // Photos
            _buildFilterSectionTitle('Photos'),
            _buildMultiSelectFilter(
              options: widget.photoOptions,
              selectedValues: _tempSelectedPhotos,
              onToggle: (photoOption) {
                setState(() {
                  if (_tempSelectedPhotos.contains(photoOption)) {
                    _tempSelectedPhotos.remove(photoOption);
                  } else {
                    _tempSelectedPhotos.add(photoOption);
                  }
                });
              },
              isEnabled: filtersInteractable,
            ),
            const SizedBox(height: 16.0),
            const Divider(color: Colors.grey, height: 1),

            // More Filters Title
            _buildFilterSectionTitle('MORE FILTERS'),

            // Tribes
            _buildFilterSectionTitle('Tribes'), // Re-add as a separate filter type
            _buildMultiSelectFilter(
              options: widget.tribeOptions,
              selectedValues: _tempSelectedTribes,
              onToggle: (tribe) {
                setState(() {
                  if (_tempSelectedTribes.contains(tribe)) {
                    _tempSelectedTribes.remove(tribe);
                  } else {
                    _tempSelectedTribes.add(tribe);
                  }
                });
              },
              isEnabled: filtersInteractable,
            ),
            const SizedBox(height: 16.0),
            const Divider(color: Colors.grey, height: 1),

            // Body Type
            _buildDropdownFilter(
              hintText: 'Select Body Type',
              selectedValue: _tempSelectedBodyType,
              options: widget.bodyTypeOptions,
              onChanged: (newValue) {
                setState(() {
                  _tempSelectedBodyType = newValue;
                });
              },
              isEnabled: filtersInteractable,
            ),
            const SizedBox(height: 16.0),
            const Divider(color: Colors.grey, height: 1),

            // Height
            _buildFilterSectionTitle('Height'),
            _buildDropdownFilter(
              hintText: 'Select Height',
              selectedValue: _tempSelectedHeight,
              options: widget.heightOptions,
              onChanged: (newValue) {
                setState(() {
                  _tempSelectedHeight = newValue;
                });
              },
              isEnabled: filtersInteractable,
            ),
            const SizedBox(height: 16.0),
            const Divider(color: Colors.grey, height: 1),

            // Weight
            _buildFilterSectionTitle('Weight'),
            _buildDropdownFilter(
              hintText: 'Select Weight',
              selectedValue: _tempSelectedWeight,
              options: widget.weightOptions,
              onChanged: (newValue) {
                setState(() {
                  _tempSelectedWeight = newValue;
                });
              },
              isEnabled: filtersInteractable,
            ),
            const SizedBox(height: 16.0),
            const Divider(color: Colors.grey, height: 1),

            // Relationship Status
            _buildFilterSectionTitle('Relationship Status'),
            _buildDropdownFilter(
              hintText: 'Select Status',
              selectedValue: _tempSelectedRelationshipStatus,
              options: widget.relationshipStatusOptions,
              onChanged: (newValue) {
                setState(() {
                  _tempSelectedRelationshipStatus = newValue;
                });
              },
              isEnabled: filtersInteractable,
            ),
            const SizedBox(height: 16.0),
            const Divider(color: Colors.grey, height: 1),

            // Accepts NSFW Pics
            _buildRadioListTile(
              title: 'Accepts NSFW Pics',
              value: _tempAcceptsNsfwPics,
              onChanged: (bool? value) {
                setState(() {
                  _tempAcceptsNsfwPics = value ?? false;
                });
              },
              isEnabled: filtersInteractable,
            ),
            const Divider(color: Colors.grey, height: 1),

            // Looking For
            _buildFilterSectionTitle('Looking For'),
            _buildDropdownFilter(
              hintText: 'Select Looking For',
              selectedValue: _tempSelectedLookingFor,
              options: widget.lookingForOptions,
              onChanged: (newValue) {
                setState(() {
                  _tempSelectedLookingFor = newValue;
                });
              },
              isEnabled: filtersInteractable,
            ),
            const SizedBox(height: 16.0),
            const Divider(color: Colors.grey, height: 1),

            // Meet At
            _buildFilterSectionTitle('Meet At'),
            _buildDropdownFilter(
              hintText: 'Select Meet At',
              selectedValue: _tempSelectedMeetAt,
              options: widget.meetAtOptions,
              onChanged: (newValue) {
                setState(() {
                  _tempSelectedMeetAt = newValue;
                });
              },
              isEnabled: filtersInteractable,
            ),
            const SizedBox(height: 16.0),
            const Divider(color: Colors.grey, height: 1),

            // Haven't Chatted Today
            _buildRadioListTile(
              title: 'Haven\'t Chatted Today',
              value: _tempHaventChattedToday,
              onChanged: (bool? value) {
                setState(() {
                  _tempHaventChattedToday = value ?? false;
                });
              },
              isEnabled: filtersInteractable,
            ),
            const SizedBox(height: 40),

            // Apply Button
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: filtersInteractable ? _applyFilters : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Apply',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
