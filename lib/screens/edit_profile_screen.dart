// lib/screens/profile_screen.dart (Continued)
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:connect/services/secure_storage_service.dart';
import 'package:connect/services/api_service.dart'; // Import your API service
import 'package:connect/models/user_model.dart'; // Import your user model
import 'dart:io'; // Required for File
import 'package:flutter/services.dart'; // Required for TextInputFormatter

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

// Corrected _buildOptions
  final List<String> _buildOptions = [
    'Slim',
    'Average',
    'Athletic',
    'Muscular',
    'A few extra pounds' // Corrected from 'Heavy', removed 'Other'
  ];
  String? _selectedBuild;

// Corrected _lookingForOptions
  final List<String> _lookingForOptions = [
    'Chat',
    'Friends', // Corrected from 'Friends'
    'Hookups',
    'Long-term Relationship', // Added this option
    'Dating'
    // Removed 'Anything' as it's not in backend defaults
  ];
  String? _selectedLookingFor;

// Corrected _meetAtOptions
  final List<String> _meetAtOptions = [
    'My Place',
    'Your Place',
    'Public Place',
    'Online'
    // Removed 'Cafe' as it's not in backend defaults
  ];
  String? _selectedMeetAt;

// Corrected _nsfwPicsOptions
  final List<String> _nsfwPicsOptions = ['Yes', 'No'];

  // Added 'Maybe'
  String? _selectedNsfwPics;

// Corrected _genderOptions
  final List<String> _genderOptions = [
    'Man',
    'Woman',
    'Non-binary' // Corrected from 'Non-Binary', removed 'Transgender', 'Prefer not to say'
  ];
  String? _selectedGender;
  final List<String> _positionOptions = [
    'Top',
    'Versatile',
    'Bottom',
    'Side',
    'Not Applicable'
  ];
  List<String> _selectedPositions = [];
// Corrected _pronounsOptions
// Note: Frontend typically shows all available pronouns, and backend logic handles which are valid for a selected gender.
// Based on your backend, 'He/Him/His', 'She/Her/Hers', 'They/Them/Theirs' are the main options.
// 'Ask me' is a common frontend addition for user preference.
// I will keep 'Ask me' for user flexibility, but ensure the core ones match.
  final List<String> _pronounsOptions = [
    'He/Him/His',
    'She/Her/Hers',
    'They/Them/Theirs',
    'Ask me' // Keeping this for frontend flexibility unless backend strictly disallows it
  ];
  String? _selectedPronouns;

// Corrected _raceOptions
  final List<String> _raceOptions = [
    'White',
    'Black',
    'Asian',
    'Hispanic',
    'Indigenous', // Added 'Indigenous'
    'Mixed'
    // Removed 'Other'
  ];
  String? _selectedRace;

// Corrected _relationshipStatusOptions
  final List<String> _relationshipStatusOptions = [
    'Single',
    'In a Relationship', // Corrected from 'Taken', added 'Married'
    'Married',
    'Complicated'
    // Removed 'Open'
  ];
  String? _selectedRelationshipStatus;
  // Store the UserProfile that we are editing
  UserModel? _currentUserProfile;

  // List of image URLs (can be local paths or network URLs)
  // Initially, this will hold the fetched network URLs
  final List<String> _imageUrls = [];
  final picker = ImagePicker();

  // Track if an image upload/deletion is in progress
  bool _isImageProcessing = false;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _currentUserProfile = widget.user;
      _loadUserProfile();
      // Example: _userNameController.text = widget.user!.userName ?? '';
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
      //final UserModel? _currentUserProfile;
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
      _selectedNsfwPics = _currentUserProfile!.acceptsNsfwPics ? 'Yes' : 'No';
      _selectedGender = _currentUserProfile!.gender;
      _selectedPronouns = _currentUserProfile!.pronouns;
      _selectedRace = _currentUserProfile!.race;
      _selectedRelationshipStatus = _currentUserProfile!.relationshipStatus;
      _selectedPositions = _currentUserProfile!.position ??
          []; // Initialize with an empty list if null
      _imageUrls.clear();
      _imageUrls.addAll(_currentUserProfile!.imageUrls as Iterable<String>);
    } catch (e) {
      // More user-friendly error messages
      if (e.toString().contains("401")) {
        _errorMessage = 'Session expired. Please log in again.';
      } else {
        _errorMessage =
            'Failed to load profile: ${e.toString().split(':').last.trim()}';
      }

      // >>>>>> ADDED THIS MOUNTED CHECK HERE <<<<<<
      if (!mounted) {
        // If the widget is no longer in the widget tree, we cannot show a SnackBar.
        // Optionally, log the error here if you need to track it even if no UI feedback is given.
        return; // Exit the catch block early as we can't proceed with context
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
      imageUrls: _imageUrls,
      acceptsNsfwPics: true,
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
      userName: _currentUserProfile!.userName,
      id: _currentUserProfile!.id,
      gender: _selectedGender,
      lookingFor: _selectedLookingFor,
      joined: _currentUserProfile!.joined,
      position: _selectedPositions,
    );
    try {
      await ApiService.updateExistingUserProfile(updatedProfile);
      // ... (your existing validation and API call to save the profile)

      if (!mounted) return; // Always check mounted after async operations

      setState(() {
        _isLoading = false;
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
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _isImageProcessing = true; // Show specific loader for image processing
        _errorMessage = ''; // Clear previous image errors
      });
      try {
        File imageFile = File(pickedFile.path);
        final imageUrl =
            await ApiService.uploadImage(imageFile); // Upload to API
        setState(() {
          // If this is the first image, or if we want it to be the main profile image,
          // insert it at the beginning. Otherwise, add to the end.
          if (_imageUrls.isEmpty) {
            _imageUrls.add(imageUrl);
          } else {
            _imageUrls.insert(
                0, imageUrl); // Make new image the main profile image
          }
        });

        if (!mounted) return; // Add mounted check before using context
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploaded successfully!')),
        );
      } catch (e) {
        _errorMessage =
            'Failed to upload image: ${e.toString().split(':').last.trim()}';

        if (!mounted) return; // Add mounted check before using context
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
      _isImageProcessing = true; // Show specific loader for image processing
      _errorMessage = ''; // Clear previous image errors
    });
    try {
      await ApiService.deleteImage(imageUrlToRemove); // Delete from API
      setState(() {
        _imageUrls.remove(imageUrlToRemove); // Remove from local list
      });

      if (!mounted) return; // Add mounted check before using context
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image removed successfully!')),
      );
    } catch (e) {
      _errorMessage =
          'Failed to remove image: ${e.toString().split(':').last.trim()}';

      if (!mounted) return; // Add mounted check before using context
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage)),
      );
    } finally {
      setState(() {
        _isImageProcessing = false;
      });
    }
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
      padding: const EdgeInsets.only(bottom: 8.0),
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
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- Profile Photo and Username Row ---
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Main profile image (Square with radius)
                              GestureDetector(
                                onTap: _isImageProcessing ? null : _pickImage,
                                child: Container(
                                  width: 100.0,
                                  height: 100.0,
                                  decoration: BoxDecoration(
                                    color: Colors
                                        .grey[800], // Background for avatar
                                    borderRadius: BorderRadius.circular(
                                        5.0), // Apply radius
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12.0),
                                    child: _imageUrls.isNotEmpty
                                        ? Image.network(
                                            _imageUrls[
                                                0], // First image in the list
                                            fit: BoxFit.cover,
                                            width: 100,
                                            height: 100,
                                            errorBuilder: (context, error,
                                                    stackTrace) =>
                                                Image.asset(
                                                    'assets/placeholder_error.jpg',
                                                    fit: BoxFit.cover),
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
                                                  color: Colors.white54,
                                                ),
                                              );
                                            },
                                          )
                                        : Image.asset(
                                            'assets/placeholder_error.jpg', // Use asset for placeholder
                                            fit: BoxFit.cover,
                                            width: 100,
                                            height: 100,
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                  width:
                                      16), // Space between photo and username
                              Expanded(
                                child: Text(
                                  _usernameController
                                      .text, // Display username from controller
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        12.0, // Increased font size for prominence
                                    fontWeight: FontWeight.normal,
                                  ),
                                  overflow: TextOverflow
                                      .ellipsis, // Handle long usernames
                                ),
                              ),
                            ],
                          ),
                          // --- End Profile Photo and Username Row ---

                          const SizedBox(height: 30), //Increasedspacing
                          _buildSectionTitle('Tell about you'),
                          _buildTextField(
                            _bioController,
                            'Enteryourbio',
                            maxLines: 3,
                          ),
                          const SizedBox(height: 20),
                          //---StartofRowforHeightandWeight---
                          Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start, //Aligntitlesatthetop
                            children: [
                              Expanded(
                                //AllowsHeightsectiontotakeavailablespace
                                child: Column(
                                  //Keeptitleandtextfieldstacked
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSectionTitle('Height(cm)'),
                                    _buildTextField(_heightController, '',
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly
                                        ]),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                  width: 16), //SpacebetweenHeightandWeight
                              Expanded(
                                //AllowsWeightsectiontotakeavailablespace
                                child: Column(
                                  //Keeptitleandtextfieldstacked
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSectionTitle('Weight(kg)'),
                                    _buildTextField(_weightController, '',
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly
                                        ]),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            // Wrap "Build" and "Looking For" in a Row
                            crossAxisAlignment: CrossAxisAlignment
                                .start, // Align titles at the top
                            children: [
                              Expanded(
                                // "Build" section
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSectionTitle('Build'),
                                    _buildDropdown(
                                        _buildOptions, _selectedBuild,
                                        (newValue) {
                                      setState(() {
                                        _selectedBuild = newValue;
                                      });
                                    }),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                  width: 16), // Space between the two dropdowns
                              Expanded(
                                // "Looking For" section
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSectionTitle('Looking For'),
                                    _buildDropdown(
                                        _lookingForOptions, _selectedLookingFor,
                                        (newValue) {
                                      setState(() {
                                        _selectedLookingFor = newValue;
                                      });
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),// Meet At & NSFW Pics Row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSectionTitle('Meet At'),
                                    _buildDropdown(
                                        _meetAtOptions, _selectedMeetAt,
                                        (newValue) {
                                      setState(() {
                                        _selectedMeetAt = newValue;
                                      });
                                    }),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                  width: 16), // Space between dropdowns
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSectionTitle('NSFW Pics'),
                                    _buildDropdown(
                                        _nsfwPicsOptions, _selectedNsfwPics,
                                        (newValue) {
                                      setState(() {
                                        _selectedNsfwPics = newValue;
                                      });
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20), // Spacing after this row

                          // Gender & Pronouns Row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSectionTitle('Gender'),
                                    _buildDropdown(
                                        _genderOptions, _selectedGender,
                                        (newValue) {
                                      setState(() {
                                        _selectedGender = newValue;
                                      });
                                    }),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                  width: 16), // Space between dropdowns
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSectionTitle('Pronouns'),
                                    _buildDropdown(
                                        _pronounsOptions, _selectedPronouns,
                                        (newValue) {
                                      setState(() {
                                        _selectedPronouns = newValue;
                                      });
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20), // Spacing after this row

                          // Race & Relationship Status Row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSectionTitle('Race'),
                                    _buildDropdown(_raceOptions, _selectedRace,
                                        (newValue) {
                                      setState(() {
                                        _selectedRace = newValue;
                                      });
                                    }),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                  width: 16), // Space between dropdowns
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSectionTitle('Relationship Status'),
                                    _buildDropdown(_relationshipStatusOptions,
                                        _selectedRelationshipStatus,
                                        (newValue) {
                                      setState(() {
                                        _selectedRelationshipStatus = newValue;
                                      });
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          _buildSectionTitle(
                              'Positions'), // Section title for multiple positions
                          Wrap(
                            // Use Wrap for flowing layout
                            spacing: 8.0, // Horizontal space between buttons
                            runSpacing:
                                8.0, // Vertical space between rows of buttons
                            children: _positionOptions.map((position) {
                              final isSelected =
                                  _selectedPositions.contains(position);
                              return InkWell(
                                // Use InkWell for custom tap effects
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      _selectedPositions.remove(position);
                                    } else {
                                      _selectedPositions.add(position);
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 8.0),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.yellow
                                        : Colors
                                            .grey[800], // Highlight if selected
                                    borderRadius: BorderRadius.circular(
                                        20.0), // Rounded corners for button look
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.yellow
                                          : Colors.grey[700]!, // Border color
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Text(
                                    position,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.black
                                          : Colors
                                              .white, // Text color changes with selection
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(
                              height:
                                  20), // Spacing after positions// Spacing after positions
                          _buildSectionTitle('Other Images'),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _imageUrls.length +
                                  1, // +1 for the "Add Image" button
                              itemBuilder: (context, index) {
                                if (index == _imageUrls.length) {
                                  // This is the "Add Image" button
                                  return GestureDetector(
                                    onTap:
                                        _isImageProcessing ? null : _pickImage,
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      margin: const EdgeInsets.only(
                                          right: 10.0), // Margin for add button
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(
                                            0.05), // Lighter grey for background
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        border: Border.all(
                                            color: Colors.grey[800]!),
                                      ),
                                      child: _isImageProcessing
                                          ? const Center(
                                              child: CircularProgressIndicator(
                                                  color: Colors.white54))
                                          : const Icon(Icons.add_a_photo,
                                              color: Colors.white54, size: 40),
                                    ),
                                  );
                                }
                                final imageUrl = _imageUrls[index];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 10.0),
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          color: Colors.grey[
                                              800], // Background while loading/error
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          child: Image.network(
                                            imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error,
                                                    stackTrace) =>
                                                Image.asset(
                                                    'assets/placeholder_error.jpg',
                                                    fit: BoxFit.cover),
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
                                                  color: Colors.white54,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 5,
                                        right: 5,
                                        child: GestureDetector(
                                          onTap: _isImageProcessing
                                              ? null
                                              : () => _removeImage(imageUrl),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.red[
                                                  600], // Slightly darker red for visibility
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 40),
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: (_isLoading || _isImageProcessing)
                                  ? null
                                  : _performLogout,
                              icon:
                                  const Icon(Icons.logout, color: Colors.white),
                              label: const Text('Log Out',
                                  style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.transparent, // Darker red for logout
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}

/// Helper widget for consistent text form fields.
Widget _buildTextField(TextEditingController controller, String hintText,
    {int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters}) {
  return TextFormField(
    controller: controller,
    // --- START TEXTFORMFIELD COLOR CHANGES ---
    style: const TextStyle(
        color: Colors.yellow), // <--- CHANGE THIS for the text the user types
    // --- END TEXTFORMFIELD COLOR CHANGES ---
    keyboardType: keyboardType,
    inputFormatters: inputFormatters, // Apply formatters
    decoration: InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
          color: Colors.red), // <--- CHANGE THIS for the hint text color
      // --- START INPUTDECORATION COLOR CHANGES ---
      filled: true, // MUST be true for fillColor to work
      fillColor: Colors.white70.withAlpha(
          10), // <--- CHANGED THIS from withOpacity(0.3) for the background color of the input field
      // --- END INPUTDECORATION COLOR CHANGES ---
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(
            color: Colors
                .blueGrey), // <--- CHANGE THIS for the default border color
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(
            color: Colors
                .blueGrey), // <--- CHANGE THIS for the border color when enabled
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(
            color: Colors
                .yellow), // <--- CHANGE THIS for the border color when focused
      ),
    ),
    maxLines: maxLines,
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'This field cannot be empty';
      }
      // Specific validation for height and weight
      if (keyboardType == TextInputType.number) {
        if (int.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        // Add range validation if desired (e.g., height > 0, weight > 0)
        if (int.parse(value) <= 0) {
          return 'Value must be greater than 0';
        }
      }
      return null;
    },
  );
}

/// Helper widget for consistent dropdown form fields.
Widget _buildDropdown<T>(
    List<T> options, T? selectedValue, ValueChanged<T?> onChanged) {
  return DropdownButtonFormField<T>(
    value: selectedValue,
    items: options.map((T value) {
      return DropdownMenuItem<T>(
        value: value,
        child: Text(
          value.toString(),
          style: const TextStyle(color: Colors.yellow),
          overflow: TextOverflow
              .ellipsis, // Add this line to prevent text overflow in items
        ),
      );
    }).toList(),
    onChanged: onChanged,
    isExpanded: true, // <--- ADD THIS LINE
    decoration: InputDecoration(
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    dropdownColor: Colors.grey[850], // Background for dropdown menu
    iconEnabledColor: Colors.white,
    style: const TextStyle(color: Colors.yellow, fontSize: 16),
  );
}
