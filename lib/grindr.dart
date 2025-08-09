import 'package:connect/main.dart';
import 'package:connect/screens/chat_Inbox_Screen.dart';
import 'package:connect/screens/interests_screens.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Keep this import even if not directly used in MainBrowseScreen
import 'package:connect/services/secure_storage_service.dart';
import 'package:connect/services/api_service.dart'; // Import your API service
import 'package:connect/models/user_model.dart'; // Import your user model

import 'package:connect/screens/edit_profile_screen.dart'
    hide UserModel; // Ensure this path is correct
import 'package:connect/screens/profile_screen.dart' hide EditProfileScreen; // Ensure this path is correct
import 'package:connect/screens/store_screen.dart'; // Import the new store screen (SubscriptionPage)
// Import the new filter dialogs/screens
import 'package:connect/filters/position_filter_dialog.dart';
import 'package:connect/filters/age_filter_dialog.dart';
import 'package:connect/filters/online_filter_dialog.dart';
import 'package:connect/filters/fresh_filter_dialog.dart';
import 'package:connect/filters/favorite_filter_dialog.dart';
import 'package:connect/screens/tags_filter_screen.dart';
import 'package:connect/screens/more_filters_screen.dart';

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
  List<String>? _selectedPosition; // Holds the selected position for filtering
  bool _isPositionFilterEnabled = false; // Controls the position filter toggle

  RangeValues _selectedAgeRange =
  const RangeValues(18, 99); // Default age range
  bool _isAgeFilterEnabled = false; // Controls the age filter toggle

  bool _showOnlyOnline =
  false; // True to filter for online users, false for all users
  bool _isOnlineFilterEnabled = false; // Controls the online filter toggle

  bool _isFreshEnabled = false; // Controls the Fresh filter toggle

  bool _showOnlyFavorites =
  false; // True to filter for favorites, false for all users
  bool _isFavoriteFilterEnabled = false; // Controls the favorite filter toggle

  List<String> _selectedTags =
  []; // Stores selected tags/tribes for individual filter
  bool _isTagsFilterEnabled = false; // Controls the tags filter toggle

  List<String> finalPositionsFromMoreFilters = [];
  List<String> finalGenders = [];
  bool finalHasPhotos = false;
  bool finalHasFacePics = false;

  bool finalHasAlbums = false;
  String finalBodyType = '';
  String finalHeight = '';
  String finalWeight = '';
  String finalRelationshipStatus = "";
  List<String> finalAcceptsNsfwPics = [];
  String finalLookingFor = '';
  String finalMeetAt = '';
  bool finalHaventChattedToday = false;
  String? _selectedMinAgeFromMoreFilters;
  String? _selectedMaxAgeFromMoreFilters;
  String? _selectedMinHeight;
  String? _selectedMaxHeight;
  String? _selectedMinWeight;
  String? _selectedMaxWeight;

  // Filter states for MoreFiltersScreen (these will be updated by MoreFiltersScreen)
  bool _isGlobalFilterEnabled =
  false; // Global toggle for all filters within MoreFiltersScreen
  bool _selectedFavoritesFromMoreFilters = false; // From MoreFiltersScreen
  bool _selectedOnlineFromMoreFilters = false; // From MoreFiltersScreen
  bool _selectedRightNow = false;

  List<String> _selectedGenders = [];
  List<String> _selectedPositionsFromMoreFilters =
  []; // Positions from MoreFiltersScreen
  List<String> _selectedPhotos = [];
  List<String> _selectedTribes = []; // Tribes from MoreFiltersScreen
  List<String> _selectedBodyType = [];
  String? _selectedHeight;
  String? _selectedWeight;
  List<String> _selectedRelationshipStatus = [];
  List<String> _acceptsNsfwPics = [];
  List<String> _selectedLookingFor = [];
  String? _selectedMeetAt;
  bool _haventChattedToday = false; // Filter options for dialogs/screens
  final List<String> _ageOptions = List<int>.generate(82, (i) => i + 18)
      .map((e) => e.toString())
      .toList(); // Ages from 18 to 99
  static final List<Widget> _widgetOptions = <Widget>[
    Text('Browse Screen Content'), // Placeholder for Browse
    Text('Interest Screen Content'), // Placeholder for Interest
    // The InboxScreen will be pushed onto the navigator, not directly placed here
    Text(
        'Inbox Placeholder - Should navigate to InboxScreen'), // Placeholder for Inbox
    Text('Store Screen Content'), // Placeholder for Store
  ];

  final List<String> _genderOptions = [
    'Men',
    'Women',
    'Non-Binary',
    'More Genders',
    'Not Specified'
  ];
  final List<Map<String, dynamic>> _positionFilterOptions = [
    // Used by PositionFilterDialog and MoreFiltersScreen
    {'text': 'Top', 'icon': Icons.arrow_upward},
    {'text': 'Vers Top', 'icon': Icons.north_east},
    {'text': 'Versatile', 'icon': Icons.swap_vert},
    {'text': 'Vers Bottom', 'icon': Icons.south_east},
    {'text': 'Bottom', 'icon': Icons.arrow_downward},
    {'text': 'Side', 'icon': Icons.swap_horiz},
    {'text': 'Not Specified', 'icon': Icons.help_outline},
  ];
  final List<String> _photoOptions = [
    'Has photos',
    'Has face pics',
    'Has album(s)'
  ];
  final List<String> _tribeOptions = [
    'Bear',
    'Chub',
    'Clean-cut',
    'Daddy',
    'Discreet',
    'Geek',
    'Jock',
    'Leather',
    'Masc',
    'Otter',
    'Poz',
    'Rugged',
    'Trans',
    'Twink',
    'Uniform'
  ];
  final Map<String, List<String>> _allTagOptions = {
    'Kinks': [
      'anon',
      'bator',
      'bb',
      'bondage',
      'bubblebutt',
      'carplay',
      'chastity',
      'commando',
      'condoms',
      'condomsonly',
      'cruising',
      'cut',
      'dirty',
      'discreet',
      'dl',
      'dom',
      'dtf',
      'edging',
      'feet',
      'ff',
      'flexible',
      'furries',
      'fwb',
      'gear',
      'gh',
      'gooner',
      'group',
      'hands',
      'hosting',
      'hung',
      'jo',
      'kink',
      'kissing',
      'latex',
      'leather',
      'limits',
      'lingerie',
      'looking',
      'muscle',
      'nylon',
      'otter',
      'pic4pic',
      'poz',
      'sissy',
      'smooth',
      'sober',
      't4t',
      'trans',
      'twink',
      'twunk',
      'uniform',
      'visiting',
      'watching',
      'ws'
    ],
    'Hobbies': [
      'anime',
      'apres ski',
      'art',
      'beach',
      'brunch',
      'concerts',
      'cooking',
      'dancing',
      'diy',
      'fashion',
      'gaming',
      'hiking',
      'karaoke',
      'movies',
      'music',
      'naps',
      'popmusic',
      'reading',
      'rpdr',
      'tattoos',
      'tennis',
      'theater',
      'tv',
      'weightlifting',
      'workingout',
      'writing',
      'yoga'
    ],
    'Personality': [
      'adventurous',
      'catperson',
      'chill',
      'confident',
      'curious',
      'direct',
      'dogperson',
      'fun',
      'goofy',
      'kind',
      'loyal',
      'mature',
      'outgoing',
      'parent',
      'reliable',
      'romantic',
      'shy',
      'unicorn'
    ],
    'Other Tags': [
      'bear',
      'beard',
      'bi',
      'chub',
      'cleancut',
      'college',
      'couple',
      'cub',
      'cuddling',
      'daddy',
      'drag',
      'drugfree',
      'femme',
      'friends',
      'gaymer',
      'geek',
      'hairy',
      'jock',
      'leather',
      'masc',
      'military',
      'nosmoking',
      'nylon',
      'otter',
      'pic4pic',
      'poz',
      'sissy',
      'smooth',
      'sober',
      't4t',
      'trans',
      'twink',
      'twunk',
      'uniform'
    ], // Combined from _tribeOptions and other possible tags
  };
  final List<String> _bodyTypeOptions = [
    'Slim',
    'Average',
    'Toned',
    'Stocky',
    'Athletic',
    'Muscular',
    'Large',
    'Not Specified'
  ];
  final List<String> _heightOptions = List<int>.generate(61, (i) => i + 150)
      .map((e) => '${e} cm')
      .toList(); // 150cm to 210cm
  final List<String> _weightOptions = List<int>.generate(101, (i) => i + 50)
      .map((e) => '${e} kg')
      .toList(); // 50kg to 150kg
  final List<String> _relationshipStatusOptions = [
    'Single',
    'Dating',
    'Married',
    'Commited',
    'Engaged',
    'Exclusive',
    'Open Relationship',
    'Partnered',
    'Not Specified'
  ];
  final List<String> _lookingForOptions = [
    'Chat',
    'Friendship',
    'Hookups',
    'Long-term Relationship',
    'Dating'
  ];
  final List<String> _meetAtOptions = [
    'My Place',
    'Your Place',
    'Public Place',
    'Online'
  ];

  // New options list for Accepts NSFW Pics
  final List<String> _acceptsNsfwPicsOptions = [
    'Yes',
    'No',
    'Maybe',
    'Rather not say'
  ];

  // Added _selectedIndex to manage the active tab in the bottom navigation bar
  int _selectedIndex = 0;
  // PageController to manage the different views in the body
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _fetchLoggedInUser();
    _fetchUsers();
    _scrollController.addListener(_onScroll);
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _pageController.dispose(); // Dispose the PageController
    super.dispose();
  }

  /// Fetches the currently logged-in user's profile.
  Future<void> _fetchLoggedInUser() async {
    setState(() {
      _isLoggedInUserLoading = true;
      _loggedInUserErrorMessage = '';
    });
    try {
      final String? jwtToken = await SecureStorageService.getApiKey();
      if (jwtToken == null) {
        setState(() {
          _loggedInUserErrorMessage = 'User not logged in.';
          _isLoggedInUserLoading = false;
        });
        return;
      }
      final user = await ApiService.getUserProfileById(null);
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

  Future<void> _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });
    final String url = 'https://peek.thegwd.ca/chathub';
    // Check if the tapped item is 'Inbox' (index 2)

    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InboxScreen(
            currentUserId:
            _loggedInUser!.id.toString(), // Pass your current user ID
            chatHubUrl: kServerUrl,
            currentUserImgUrl: _loggedInUser!.imageUrls.first,
            currentUserUserName:
            _loggedInUser!.userName, // Pass your SignalR hub URL
          ),
        ),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InterestScreen(),
        ),
      );
    } else if (index == 3) {
      // Handle 'Store' tab (index 3)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
          const SubscriptionPage(), // Navigate to SubscriptionPage
        ),
      );
    }
    // You would add navigation logic for other tabs here if they are full screens
    // For example:
    // else if (index == 0) {
    //   // Navigate to Browse screen
    // }
  }

  /// Fetches users from the API, with optional pagination and filtering.
  Future<void> _fetchUsers({bool isLoadMore = false}) async {
    if (!_hasMore && isLoadMore) {
      final _users = await ApiService.getPeople(pageNumber: 1, pageSize: 15);
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

      List<String>? finalPosition;
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
        finalMinAge = _selectedMinAgeFromMoreFilters != null
            ? int.tryParse(_selectedMinAgeFromMoreFilters!)
            : null;
        finalMaxAge = _selectedMinAgeFromMoreFilters != null ? 99 : null;
        finalGenders = (_selectedGenders.isNotEmpty ? _selectedGenders : null)!;
        finalPositionsFromMoreFilters =
        (_selectedPositionsFromMoreFilters.isNotEmpty
            ? _selectedPositionsFromMoreFilters
            : null)!;
        finalHasPhotos = _selectedPhotos.contains('Has photos');
        finalHasFacePics = _selectedPhotos.contains('Has face pics');
        finalHasAlbums = _selectedPhotos.contains('Has album(s)');
        finalBodyType = finalBodyType;
        finalHeight = finalHeight;
        finalWeight = finalWeight;
        finalRelationshipStatus = finalRelationshipStatus;
        finalAcceptsNsfwPics = _acceptsNsfwPics;
        finalLookingFor = finalLookingFor;
        finalMeetAt = finalMeetAt;
        finalHaventChattedToday = _haventChattedToday;
        finalIsFresh =
            _selectedRightNow; // Assuming "Right Now" covers "Fresh" in MoreFiltersScreen

        // When global filter is ON, use _selectedTribes for the consolidated tags parameter
        finalTagsToApi = _selectedTribes.isNotEmpty ? _selectedTribes : null;

        // Reset individual filter states if global filter is active
        _isPositionFilterEnabled = false;
        _isAgeFilterEnabled = false;
        _isOnlineFilterEnabled = false;
        _isFreshEnabled = false;
        _isFavoriteFilterEnabled = false;

        _isTagsFilterEnabled =
        false; // Important: turn off individual tags filter
        _selectedTags
            .clear(); // Clear individual tags selection to avoid stale data
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

      // --- Debugging Print Statements for Age Filter ---
      print('--- Age Filter Debugging ---');
      print('isAgeFilterEnabled: $_isAgeFilterEnabled');
      print('Selected Age Range: $_selectedAgeRange');
      print('Final Min Age sent to API: $finalMinAge');
      print('Final Max Age sent to API: $finalMaxAge');
      print('isGlobalFilterEnabled: $_isGlobalFilterEnabled');
      if (_isGlobalFilterEnabled) {
        print(
            'Selected Min Age from More Filters (string): $_selectedMinAgeFromMoreFilters');
      }
      print('--------------------------');
      // --- End Debugging Print Statements ---

      final fetchedUsers = await ApiService.getPeople(
          pageNumber: _currentPage,
          pageSize: _pageSize,
          minAge: finalMinAge,
          maxAge: finalMaxAge,
          genders: _isGlobalFilterEnabled ? finalGenders : null,
          bodyType: _isGlobalFilterEnabled ? finalBodyType : null,
          height: _isGlobalFilterEnabled ? finalHeight : null,
          weight: _isGlobalFilterEnabled ? finalWeight : null,
          relationshipStatus:
          _isGlobalFilterEnabled ? finalRelationshipStatus : null,
          acceptsNsfwPics: _isGlobalFilterEnabled ? finalAcceptsNsfwPics : null,
          lookingFor: _isGlobalFilterEnabled ? finalLookingFor : null,
          meetAt: _isGlobalFilterEnabled ? finalMeetAt : null,
          isFresh: finalIsFresh,
          position: _isPositionFilterEnabled ? finalPosition : null);

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
    //await _fetchLoggedInUser();
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
            // CORRECTED: Pass to initialSelectedPositions
            initialSelectedPositions:
            _selectedPosition ?? [], // Pass the current state
            initialFilterEnabled: _isPositionFilterEnabled,
            positionOptions: _positionFilterOptions,
            // REMOVED: initialSelectedPosition: _selectedPosition,
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
          // Passing the range values to the screen
          initialSelectedMinAge: _selectedMinAgeFromMoreFilters,
          initialSelectedMaxAge: _selectedMaxAgeFromMoreFilters,
          initialSelectedGenders: _selectedGenders,
          initialSelectedPositions: _selectedPositionsFromMoreFilters,
          initialSelectedPhotos: _selectedPhotos,
          initialSelectedTribes: _selectedTribes,
          initialSelectedBodyTypes: _selectedBodyType,
          // Passing the height range values
          initialSelectedMinHeight: _selectedMinHeight,
          initialSelectedMaxHeight: _selectedMaxHeight,
          // Passing the weight range values
          initialSelectedMinWeight: _selectedMinWeight,
          initialSelectedMaxWeight: _selectedMaxWeight,
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
          acceptsNsfwPicsOptions: _acceptsNsfwPicsOptions, // Pass the new options list
        ),
      ),
    );
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _isGlobalFilterEnabled = result['isGlobalFilterEnabled'] ?? false;
        _selectedFavoritesFromMoreFilters =
            result['selectedFavorites'] ?? false;
        _selectedOnlineFromMoreFilters = result['selectedOnline'] ?? false;
        _selectedRightNow = result['selectedRightNow'] ?? false;
        _selectedMinAgeFromMoreFilters = result['selectedMinAge'];
        _selectedGenders = List<String>.from(result['selectedGenders'] ?? []);
        _selectedPositionsFromMoreFilters =
        List<String>.from(result['selectedPosition'] ?? []);
        _selectedPhotos = List<String>.from(result['selectedPhotos'] ?? []);
        _selectedTribes = List<String>.from(result['selectedTribes'] ?? []);
        _selectedBodyType = List<String>.from(result['selectedBodyType'] ?? []); // Ensure it's a List<String>
        _selectedHeight = result['selectedHeight'];
        _selectedWeight = result['selectedWeight'];
        _selectedRelationshipStatus = List<String>.from(result['selectedRelationshipStatus'] ?? []); // Ensure it's a List<String>

        _acceptsNsfwPics = List<String>.from(result['acceptsNsfwPics'] ?? []);
        _selectedLookingFor = List<String>.from(result['selectedLookingFor'] ?? []); // Ensure it's a List<String>
        _selectedMeetAt = result['selectedMeetAt'];
        _haventChattedToday = result['haventChattedToday'] ?? false;

        _currentPage = 1; // Reset page to 1 when filters change
        _hasMore = true; // Assume new data exists
        _users.clear(); // Clear current users to show new filtered results
      });
      _fetchUsers(); // Refetch users with new filters
    }
  }

  // Function to handle bottom navigation bar taps

  Future<void> _navigateToEditProfile() async {
    // Await the result from EditProfileScreen
    final bool? profileUpdated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(user: _loggedInUser),
      ),
    );

    // If profileUpdated is true, it means the profile was saved successfully
    if (profileUpdated == true) {
      // Reset pagination state to ensure a full refresh from the first page
      setState(() {
        _users.clear(); // Clear existing users
        _currentPage = 1; // Reset to the first page
        _hasMore = true; // Assume there are more users to load
        _errorMessage = ''; // Clear any previous error messages
      });

      // Trigger a refresh of the logged-in user's data and then all users
      await _fetchLoggedInUser();
      await _fetchUsers(); // This will now fetch from page 1 with cleared users.

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile data refreshed!')),
      );
    }
  }

  // New method to navigate to LocationPickerScreen

  @override
  Widget build(BuildContext context) {
    //_fetchLoggedInUser();
    ImageProvider userAvatarImage;
    if (_loggedInUser != null && _loggedInUser!.imageUrls.isNotEmpty) {
      userAvatarImage = NetworkImage(_loggedInUser!.imageUrls[0]);
    } else {
      userAvatarImage = const AssetImage(
          'assets/placeholder_user.jpg'); // Ensure you have this asset
    }

    return Scaffold(
      // The body of the Scaffold contains a PageView, which holds multiple screens.
      // To ensure all screens within the PageView respect the safe area,
      // each child of the PageView should be wrapped in SafeArea.
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        physics:
        const NeverScrollableScrollPhysics(), // Disable swiping between pages
        children: [
          // 0: Browse Screen
          // This screen already has SafeArea applied to its Column child.
          Container(
            color: Colors.black,
            child: SafeArea(
              // Existing SafeArea for Browse Screen
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 8.0), // Reduced vertical padding
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            _navigateToEditProfile();
                          },
                          child: CircleAvatar(
                            radius: 20.0,
                            backgroundImage: userAvatarImage,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: GestureDetector(
                            // Wrap TextField with GestureDetector
                            child: Container(
                              constraints:
                              const BoxConstraints(maxHeight: 30.0),
                              child: TextField(
                                enabled:
                                false, // Disable TextField interaction directly
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
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30.0, // This height defines the space for the pills
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        const SizedBox(width: 8.0),
                        _buildPillButton(Icons.star_outline, "Favorite",
                            onTap:
                            _showFavoriteFilterDialog), // Favorite filter
                        _buildPillButton(Icons.cake, "Age",
                            onTap: _showAgeFilterDialog), // Age filter
                        _buildPillButton(Icons.wifi, "Online",
                            onTap: _showOnlineFilterDialog), // Online filter
                        _buildPillButton(Icons.location_on, "Position",
                            onTap: _showPositionFilterDialog),
                        _buildPillButton(Icons.fiber_new, "Fresh",
                            onTap: _showFreshFilterDialog), // Fresh filter
                        _buildPillButton(Icons.tag, "Tags",
                            onTap:
                            _showTagsFilterScreen), // Tags filter now goes to TagsScreen
                        _buildPillButton(Icons.filter_list, "More Filters",
                            onTap: _showMoreFiltersScreen),
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
                          child: CircularProgressIndicator(
                              color: Colors.white))
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
                          itemCount:
                          _users.length + (_hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _users.length) {
                              return _isLoading
                                  ? const Center(
                                  child:
                                  CircularProgressIndicator(
                                      color: Colors.white))
                                  : const SizedBox.shrink();
                            }
                            final user = _users[index];
                            final imageUrl = user.imageUrls.isNotEmpty
                                ? user.imageUrls[0]
                                : 'assets/placeholder_user.jpg';
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ProfileScreen(
                                          userId: user.id.toString(),
                                        ),
                                  ),
                                );
                              },
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius:
                                    BorderRadius.circular(2.0),
                                    child: Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                      errorBuilder: (context, error,
                                          stackTrace) {
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
                                          child:
                                          CircularProgressIndicator(
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
                                          begin:
                                          Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [
                                            Colors.black
                                                .withOpacity(0.9),
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
                                        if (user.status!
                                            .toLowerCase()
                                            .contains('online')) ...[
                                          Container(
                                            width: 10.0,
                                            height: 10.0,
                                            decoration:
                                            const BoxDecoration(
                                              color: Colors.green,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ],
                                        const SizedBox(width: 4.0),
                                        Text(
                                          user.userName.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10.0,
                                            fontWeight:
                                            FontWeight.bold,
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
          ),
          // 1: Interest Screen (Placeholder) - Wrapped with SafeArea
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex, // Set the current selected index
        onTap: _onItemTapped, // Handle tap events
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
}

Widget _buildPillButton(IconData icon, String label, {VoidCallback? onTap}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4.0),
    child: GestureDetector(
      // Added GestureDetector to make the button tappable
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
