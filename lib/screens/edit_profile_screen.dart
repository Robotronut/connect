// lib/screens/profile_screen.dart (Continued)
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:connect/services/secure_storage_service.dart';
import 'package:connect/services/api_service.dart'; // Import your API service
import 'package:connect/models/user_model.dart'; // Import your user model
import 'dart:io'; // Required for File
import 'package:flutter/services.dart'; // Required for TextInputFormatter
import 'package:connect/screens/settings_screen.dart'; // Import the new SettingsScreen
import 'package:connect/screens/selected_tags_screen.dart'; // Import the NEW SelectTagsScreen

/// A screen for editing the user's profile information.
///
/// This screen allows users to update their bio, physical attributes,
/// preferences, and manage their profile images.
class EditProfileScreen extends StatefulWidget {
  final UserModel? user; // Declare the parameter

  const EditProfileScreen({Key? key, this.user}) : super(key: key);

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _errorMessage = '';

  // Controllers for editable fields
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  // Dropdown values for selection fields (populate from API if dynamic, or keep static)
  final List<String> _buildOptions = [
    'Slim',
    'Average',
    'Athletic',
    'Muscular',
    'Large',
    'Stocky',
    'Rather Not Say'
  ];
  String? _selectedBuild;

  final List<String> _lookingForOptions = [
    'Chat',
    'Friends',
    'Hookups',
    'Long-term Relationship',
    'Dating',
    'Rather Not Say',
  ];
  String? _selectedLookingFor;

  final List<String> _meetAtOptions = [
    'My Place',
    'Your Place',
    'Public Place',
    'Online',
    'Rather Not Say',
  ];
  String? _selectedMeetAt;

  final List<String> _nsfwPicsOptions = [
    'Yes',
    'No',
    'Maybe',
    'Rather Not Say'
  ];
  String? _selectedNsfwPics;

  final List<String> _genderOptions = [
    'Man',
    'Woman',
    'Non-binary',
    'Rather Not Say'
  ];
  String? _selectedGender;

  final List<String> _positionOptions = [
    'Top',
    'Versatile',
    'Bottom',
    'Side',
    'Ver Bottom',
    'Vers Top',
    'Rather Not Say'
  ];
  List<String> _selectedPositions = [];

  final List<String> _pronounsOptions = [
    'He/Him/His',
    'She/Her/Hers',
    'They/Them/Theirs',
    'Ask me',
    'Rather Not Say',
  ];
  String? _selectedPronouns;

  final List<String> _raceOptions = [
    'White',
    'Black',
    'Asian',
    'Hispanic',
    'Indigenous',
    'Mixed',
    'Rather Not Say',
  ];
  String? _selectedRace;

  final List<String> _relationshipStatusOptions = [
    'Single',
    'Dating',
    'Married',
    'Commited',
    'Engaged',
    'Exclusive',
    'Open Relationship',
    'Partnered',
    'Rather Not Say'
  ];
  String? _selectedRelationshipStatus;

  // New list for "My Tribes" options
  final List<String> _tribesOptions = [
    'Bear',
    'Clean-Cut',
    'Daddy',
    'Discreet',
    'Geek',
    'Jock',
    'Leather',
    'Otter',
    'Poz',
    'Rugged',
    'Twink',
    'Sober',
    'Rather Not Say',
  ];
  // New list to store the selected tribes
  List<String> _selectedTribes = [];

  // New list for "Sexual Orientation" options
  final List<String> _sexualOrientationOptions = [
    'Straight',
    'Gay',
    'Lesbian',
    'Bisexual',
    'Pansexual',
    'Asexual',
    'Demisexual',
    'Queer',
    'Questioning',
    'Fluid',
    'Skoliosexual',
    'Polysexual',
    'Omnisexual',
    'Androsexual',
    'Gynosexual',
    'Gray-Asexual',
    'Reciprosexual',
    'Aroace',
    'Cupio-sexual',
    'Fraysexual',
    'Lithsexual',
    'Placiosexual',
    'Quoi-sexual',
    'What Ever',
    'Rather Not Say',
  ];
  // Changed _selectedSexualOrientation to a List<String>
  List<String> _selectedSexualOrientation = [];

  // Store the UserProfile that we are editing
  UserModel? _currentUserProfile;

  // List of image URLs (can be local paths or network URLs)
  // Initially, this will hold the fetched network URLs
  final List<String> _imageUrls = [];
  final picker = ImagePicker();

  // Track if an image upload/deletion is in progress
  bool _isImageProcessing = false;

  // --- New state for general tags ---
  // This map holds all available tags categorized
  final Map<String, List<String>> _allAvailableTags = {
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
  // This list will hold the tags selected by the user for their profile
  List<String> _userSelectedTags = [];
  // --- End new state for general tags ---

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _currentUserProfile = widget.user;
      _loadUserProfile();
    } else {
      _loadUserProfile();
    }
  }

  @override
  void dispose() {
    _bioController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  /// Loads the user's profile data from the API and populates the form fields.
  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      if (_currentUserProfile == null) {
        throw Exception(
            "Profile error: No logged-in user ID found. Please log in again.");
      }

      _bioController.text = _currentUserProfile!.aboutMe!;
      _usernameController.text = _currentUserProfile!.userName!;
      _emailController.text = await SecureStorageService.getEmail() ??
          'myemail@example.com'; // Placeholder if email not in secure storage

      // Remove units for editing
      _heightController.text =
          _currentUserProfile!.height!.replaceAll(' cm', '');
      _weightController.text =
          _currentUserProfile!.weight!.replaceAll(' kg', '');
      _selectedBuild = _currentUserProfile!.bodyType;
      _selectedLookingFor = _currentUserProfile!.lookingFor;
      _selectedMeetAt = _currentUserProfile!.meetAt;
      _selectedNsfwPics =
      _currentUserProfile!.acceptsNsfwPics != null ? 'Yes' : 'No';
      _selectedGender = _currentUserProfile!.gender;
      _selectedPronouns = _currentUserProfile!.pronouns;
      _selectedRace = _currentUserProfile!.race;
      _selectedRelationshipStatus = _currentUserProfile!.relationshipStatus;
      _selectedPositions = _currentUserProfile!.position ??
          []; // Initialize with an empty list if null
      _selectedTribes = _currentUserProfile!.tribes ??
          []; // Initialize with an empty list if null

      // Handle loading sexual orientation: convert string to list
      if (_currentUserProfile!.sexualOrientation != null &&
          _currentUserProfile!.sexualOrientation!.isNotEmpty) {
        _selectedSexualOrientation = _currentUserProfile!.sexualOrientation!
            .split(',')
            .map((e) => e.trim())
            .toList();
      } else {
        _selectedSexualOrientation = [];
      }

      // Load user selected tags (assuming your UserModel has a 'tags' field)
      _userSelectedTags = _currentUserProfile!.tags ?? [];


      _imageUrls.clear();
      _imageUrls.addAll(_currentUserProfile!.imageUrls as Iterable<String>);
    } catch (e) {
      if (e.toString().contains("401")) {
        _errorMessage = 'Session expired. Please log in again.';
      } else {
        _errorMessage =
        'Failed to load profile: ${e.toString().split(':').last.trim()}';
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage)),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Saves the updated user profile to the API.
  Future<void> _saveProfile() async {
    final updatedProfile = UserModel(
      bodyType: _selectedBuild,
      imageUrls: _imageUrls, // This is the list from the state, which is updated on reorder
      // Map 'Yes' to true, 'No' to false, otherwise null for other options.
      acceptsNsfwPics: _selectedNsfwPics,
      aboutMe: _bioController.text,
      age: _currentUserProfile!.age,
      meetAt: _selectedMeetAt,
      height: _heightController.text,
      weight: _weightController.text,
      pronouns: _selectedPronouns,
      race: _selectedRace,
      relationshipStatus: _selectedRelationshipStatus,
      isFresh: _currentUserProfile!.isFresh,
      status: _currentUserProfile!.status,
      userName: _usernameController.text, // Use the controller value
      id: _currentUserProfile!.id,
      gender: _selectedGender,
      lookingFor: _selectedLookingFor,
      joined: _currentUserProfile!.joined,
      position: _selectedPositions,
      tribes: _selectedTribes, // Add the new tribes field
      // Convert the list of sexual orientations back to a comma-separated string for saving
      sexualOrientation: _selectedSexualOrientation.join(', '),
      tags: _userSelectedTags, // Save the selected tags
    );
    try {
      await ApiService.updateExistingUserProfile(updatedProfile);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        // Update the local _currentUserProfile to reflect the saved changes
        // This ensures the UI remains consistent if the screen is revisited
        // without a full reload from the API.
        _currentUserProfile = updatedProfile;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      });

      // Pop the current page and pass 'true' to indicate a successful update
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    }
  }

  /// Allows the user to pick an image from the gallery and uploads it.
  Future<void> _pickImage() async {
    // Limit to 9 images
    if (_imageUrls.length >= 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can upload a maximum of 9 pictures.')),
      );
      return;
    }

    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _isImageProcessing = true;
        _errorMessage = '';
      });
      try {
        File imageFile = File(pickedFile.path);
        final imageUrl = await ApiService.uploadImage(imageFile);
        setState(() {
          if (_imageUrls.isEmpty) {
            _imageUrls.add(imageUrl);
          } else {
            _imageUrls.insert(0, imageUrl); // Insert at the beginning to make it the main photo
          }
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploaded successfully!')),
        );
      } catch (e) {
        _errorMessage =
        'Failed to upload image: ${e.toString().split(':').last.trim()}';

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMessage)),
        );
      } finally {
        setState(() {
          _isImageProcessing = false;
        });
      }
    } else {}
  }

  /// Removes an image from the user's profile via API.
  void _removeImage(String imageUrlToRemove) async {
    setState(() {
      _isImageProcessing = true;
      _errorMessage = '';
    });
    try {
      await ApiService.deleteImage(imageUrlToRemove);
      setState(() {
        _imageUrls.remove(imageUrlToRemove);
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image removed successfully!')),
      );
    } catch (e) {
      _errorMessage =
      'Failed to remove image: ${e.toString().split(':').last.trim()}';

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage)),
      );
    } finally {
      setState(() {
        _isImageProcessing = false;
      });
    }
  }

  /// Handles reordering of images in the gallery.
  void _onReorderImages(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final String item = _imageUrls.removeAt(oldIndex);
      _imageUrls.insert(newIndex, item);
    });
  }


  /// Performs user logout by clearing authentication data and navigating to login.
  Future<void> _performLogout() async {
    await SecureStorageService.deleteAllAuthData();

    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
            (Route<dynamic> route) => false,
      );
    }
  }

  // Helper method for consistent section titles
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16.0, left: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// A helper widget to create a full-width, tappable row for single-select options.
  /// It uses a modal bottom sheet to display the options, providing a consistent
  /// and mobile-friendly pop-up experience regardless of the number of options.
  Widget _buildSelectableRow({
    required String title,
    required String? selectedValue,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              color: Colors.grey[900],
              height: 300,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Scrollbar(
                      thickness: 4.0, // Made the scrollbar thinner
                      thumbVisibility:
                      true, // Made the scrollbar always visible
                      child: ListView.builder(
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          final option = options[index];
                          return ListTile(
                            title: Text(
                              option,
                              style: TextStyle(
                                color: selectedValue == option
                                    ? Colors.yellow
                                    : Colors.white,
                              ),
                            ),
                            trailing: selectedValue == option
                                ? const Icon(Icons.check, color: Colors.yellow)
                                : null,
                            onTap: () {
                              onChanged(option);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1.0),
          ),
          color: Colors.white.withOpacity(0.1), // Lighter background
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: const EdgeInsets.only(
            left: 16.0, right: 16.0, top: 4.0, bottom: 4.0),
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            Row(
              children: [
                Text(
                  selectedValue ?? 'Select',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios,
                    color: Colors.grey, size: 16),
              ],
            ),
          ],
        ),
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

  /// A helper widget to create a full-width, tappable row for multi-select options.
  /// It uses a modal bottom sheet with a list of checkboxes for the options.
  Widget _buildMultiSelectableRow({
    required String title,
    required List<String> selectedValues,
    required List<String> options,
    required ValueChanged<List<String>> onChanged,
    int? maxSelections,
    String? exclusiveOption,
  }) {
    return GestureDetector(
      onTap: () {
        // Use a temporary list to manage selections within the modal
        List<String> tempSelected = List.from(selectedValues);
        showModalBottomSheet(
          context: context,
          builder: (context) {
            // Use StatefulBuilder to update the UI of the modal sheet dynamically
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter modalSetState) {
                int selectionsCount = tempSelected.length;
                if (exclusiveOption != null &&
                    tempSelected.contains(exclusiveOption)) {
                  selectionsCount = 0; // If exclusive is selected, count as 0 for other options
                } else if (maxSelections != null) {
                  selectionsCount = tempSelected.length;
                }
                return Container(
                  color: Colors.grey[900],
                  height: 300,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            if (maxSelections != null &&
                                (exclusiveOption == null ||
                                    (exclusiveOption != null &&
                                        !tempSelected.contains(exclusiveOption))))
                              Text(
                                '${selectionsCount}/$maxSelections',
                                style: const TextStyle(
                                    color: Colors.yellow,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Scrollbar(
                          thickness: 4.0,
                          thumbVisibility: true,
                          child: ListView.builder(
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final option = options[index];
                              final isSelected = tempSelected.contains(option);
                              bool isEnabled = true;

                              if (exclusiveOption != null && option == exclusiveOption) {
                                // If the current option is the exclusive one
                                isEnabled = !tempSelected.any((element) => element != exclusiveOption) || isSelected;
                              } else if (exclusiveOption != null && tempSelected.contains(exclusiveOption)) {
                                // If exclusive option is already selected, other options are disabled
                                isEnabled = false;
                              } else if (maxSelections != null) {
                                // Standard multi-select logic with max limit
                                isEnabled = isSelected || tempSelected.length < maxSelections;
                              }

                              return CheckboxListTile(
                                title: Row( // Use Row to include text and icon
                                  children: [
                                    Text(
                                      option,
                                      style: TextStyle(
                                          color: isEnabled
                                              ? Colors.white
                                              : Colors.grey),
                                    ),
                                    if (isSelected && _getIconForPosition(option) != null && title == 'Positions') // Only show icon for 'Positions'
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
                                        child: Icon(
                                          _getIconForPosition(option),
                                          color: Colors.yellow,
                                          size: 18,
                                        ),
                                      ),
                                  ],
                                ),
                                value: isSelected,
                                onChanged: isEnabled
                                    ? (bool? newValue) {
                                  modalSetState(() {
                                    if (newValue == true) {
                                      if (exclusiveOption != null &&
                                          option == exclusiveOption) {
                                        // Select exclusive option, clear others
                                        tempSelected.clear();
                                        tempSelected.add(option);
                                      } else {
                                        // Select a normal option, remove exclusive if present
                                        tempSelected
                                            .remove(exclusiveOption);
                                        if (maxSelections == null ||
                                            tempSelected.length <
                                                maxSelections) {
                                          tempSelected.add(option);
                                        }
                                      }
                                    } else {
                                      tempSelected.remove(option);
                                    }
                                  });
                                  // Update the parent state immediately, but only if the change is valid
                                  // This `onChanged` is called from within the modal's setState
                                  // which ensures the UI updates correctly.
                                  onChanged(tempSelected);
                                }
                                    : null,
                                activeColor: Colors.yellow,
                                checkColor: Colors.black,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1.0),
          ),
          color: Colors.white.withOpacity(0.1), // Lighter background
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: const EdgeInsets.only(
            left: 16.0, right: 16.0, top: 4.0, bottom: 4.0),
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            Row(
              children: [
                Text(
                  selectedValues.isEmpty ? 'Select' : selectedValues.join(', '),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios,
                    color: Colors.grey, size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// A helper widget to create a full-width, tappable row for displaying selected tags
  /// and navigating to the tag selection screen.
  Widget _buildSelectableTagsRow({
    required String title,
    required List<String> selectedValues,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1.0),
          ),
          color: Colors.white.withOpacity(0.1), // Lighter background
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: const EdgeInsets.only(
            left: 16.0, right: 16.0, top: 4.0, bottom: 4.0),
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            Expanded( // Use Expanded to allow text to take available space
              child: Align(
                alignment: Alignment.centerRight,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    selectedValues.isEmpty ? 'Select' : selectedValues.join(', '),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis, // Handle overflow
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }

  // --- New function to navigate to TagsScreen ---
  Future<void> _navigateToTagsScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectTagsScreen( // Changed to SelectTagsScreen
          initialSelectedTags: _userSelectedTags,
          allTagOptions: _allAvailableTags,
          maxSelections: 5, // Set the maximum number of tags the user can select
        ),
      ),
    );

    if (result != null && result['selectedTags'] is List<String>) {
      setState(() {
        _userSelectedTags = List.from(result['selectedTags']);
        // If TagsScreen also controls a filterEnabled state, you can update it here:
        // _tempIsFilterEnabled = result['filterEnabled'];
      });
    }
  }
  // --- End new function ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'This is You',
          style: TextStyle(
              color: Colors.yellow,
              fontWeight: FontWeight.bold), // Changed to white
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Settings Icon Button
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          // Save Icon Button
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: (_isLoading || _isImageProcessing)
                ? null // Disable save button while any operation is loading
                : _saveProfile,
          ),
        ],
      ),
      body: _isLoading && _currentUserProfile == null
          ? const Center(child: CircularProgressIndicator(color: Colors.yellow))
          : _errorMessage.isNotEmpty
          ? Center(
        child: Text(
          _errorMessage,
          style: const TextStyle(
              color: Colors.red), // Red for error messages
        ),
      )
          : Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Removed Username and Email Section ---
              // The Padding widget that contained the username and email TextFormFields has been removed.

              // --- Image Gallery Section ---
              _buildSectionTitle('PHOTOS'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Wrap( // Changed to Wrap for multi-row layout
                  spacing: 8.0, // Horizontal spacing between cards
                  runSpacing: 8.0, // Vertical spacing between rows
                  children: List.generate(_imageUrls.length + 1, (index) {
                    // Only show add photo button if less than 9 images
                    if (index == _imageUrls.length && _imageUrls.length < 9) {
                      // Add photo button
                      return ReorderableDragStartListener(
                        key: const ValueKey('add_photo_button_reorderable'),
                        index: index,
                        child: GestureDetector(
                          onTap: _isImageProcessing ? null : _pickImage,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: _isImageProcessing
                                  ? const Center(
                                  child: CircularProgressIndicator(color: Colors.white))
                                  : const Icon(Icons.add_a_photo,
                                  color: Colors.white, size: 40),
                            ),
                          ),
                        ),
                      );
                    } else if (index == _imageUrls.length && _imageUrls.length >= 9) {
                      return const SizedBox.shrink(); // Hide button if 9 images uploaded
                    }
                    final imageUrl = _imageUrls[index];
                    return ReorderableDragStartListener(
                      key: ValueKey(imageUrl),
                      index: index,
                      child: Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                                errorBuilder: (context, error, stackTrace) => Image.asset(
                                  'assets/placeholder_error.jpg',
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 100,
                                ),
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
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: _isImageProcessing
                                  ? null
                                  : () => _removeImage(imageUrl),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.7),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close,
                                    size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                          // Indicator for the main photo (first in the list)
                          if (index == 0)
                            Positioned(
                              bottom: 4,
                              left: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.yellow.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: const Text(
                                  'Main',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              // --- About Me Section ---
              _buildSectionTitle('ABOUT ME'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextFormField(
                  controller: _bioController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Tell us a bit about yourself...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // --- STATS Section ---
              _buildSectionTitle('STATS'),
              _buildSelectableRow(
                  title: 'Gender',
                  selectedValue: _selectedGender,
                  options: _genderOptions,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedGender = newValue;
                    });
                  }),
              _buildSelectableRow(
                  title: 'Pronouns',
                  selectedValue: _selectedPronouns,
                  options: _pronounsOptions,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedPronouns = newValue;
                    });
                  }),
              // Changed to _buildMultiSelectableRow for Sexual Orientation
              _buildMultiSelectableRow(
                title: 'Sexual Orientation',
                selectedValues: _selectedSexualOrientation,
                options: _sexualOrientationOptions,
                onChanged: (newValues) {
                  setState(() {
                    _selectedSexualOrientation = newValues;
                  });
                },
                maxSelections: 3, // Max 3 selections
                exclusiveOption: 'Rather Not Say', // Exclusive option
              ),
              _buildSelectableRow(
                  title: 'Race',
                  selectedValue: _selectedRace,
                  options: _raceOptions,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedRace = newValue;
                    });
                  }),
              _buildSelectableRow(
                  title: 'Relationship Status',
                  selectedValue: _selectedRelationshipStatus,
                  options: _relationshipStatusOptions,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedRelationshipStatus = newValue;
                    });
                  }),

              // --- PHYSICAL ATTRIBUTES Section ---
              _buildSectionTitle('PHYSICAL ATTRIBUTES'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _heightController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Height (cm)',
                          hintStyle:
                          const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Weight (kg)',
                          hintStyle:
                          const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _buildSelectableRow(
                  title: 'Body Type',
                  selectedValue: _selectedBuild,
                  options: _buildOptions,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedBuild = newValue;
                    });
                  }),

              // --- LOOKING FOR Section ---
              _buildSectionTitle('LOOKING FOR'),
              _buildSelectableRow(
                  title: 'Looking For',
                  selectedValue: _selectedLookingFor,
                  options: _lookingForOptions,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedLookingFor = newValue;
                    });
                  }),
              _buildSelectableRow(
                  title: 'Meet At',
                  selectedValue: _selectedMeetAt,
                  options: _meetAtOptions,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedMeetAt = newValue;
                    });
                  }),
              _buildSelectableRow(
                  title: 'Accepts NSFW pics?',
                  selectedValue: _selectedNsfwPics,
                  options: _nsfwPicsOptions,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedNsfwPics = newValue;
                    });
                  }),

              // --- POSITIONS & TRIBES Section ---
              _buildSectionTitle('POSITIONS'),
              _buildMultiSelectableRow(
                  title: 'Positions',
                  selectedValues: _selectedPositions,
                  options: _positionOptions,
                  onChanged: (newValues) {
                    setState(() {
                      _selectedPositions = newValues;
                    });
                  },
                  exclusiveOption: 'Rather Not Say',
                  maxSelections: 1
              ),

              _buildSectionTitle('TRIBES'),
              _buildMultiSelectableRow(
                title: 'Tribes',
                selectedValues: _selectedTribes,
                options: _tribesOptions,
                onChanged: (newValues) {
                  setState(() {
                    _selectedTribes = newValues;
                  });
                },
                exclusiveOption: 'Rather Not Say',
                maxSelections: 5,
              ),

              // --- MY INTERESTS/TAGS Section (now using _buildSelectableTagsRow) ---
              _buildSectionTitle('MY INTERESTS/TAGS'),
              _buildSelectableTagsRow(
                title: 'Tags',
                selectedValues: _userSelectedTags,
                onTap: _navigateToTagsScreen,
              ),

              const SizedBox(height: 50.0),
              // --- Logout Button ---
              Center(
                child: ElevatedButton(
                  onPressed: _performLogout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[800],
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 50.0),
            ],
          ),
        ),
      ),
    );
  }
}

// A helper widget to create text form fields with consistent styling.
Widget _buildTextField(TextEditingController controller, String hintText,
    {int maxLines = 1,
      TextInputType keyboardType = TextInputType.text,
      List<TextInputFormatter>? inputFormatters}) {
  return TextFormField(
    controller: controller,
    style: const TextStyle(color: Colors.yellow),
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    decoration: InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.red),
      filled: true,
      fillColor: Colors.white70.withAlpha(10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: Colors.blueGrey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: Colors.blueGrey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: Colors.yellow),
      ),
    ),
    maxLines: maxLines,
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'This field cannot be empty';
      }
      if (keyboardType == TextInputType.number) {
        if (int.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        return null;
      }
      return null;
    },
  );
}
