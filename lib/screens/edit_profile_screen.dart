// lib/screens/profile_screen.dart (Continued)
import 'package:flutter/material.dart';
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
  const EditProfileScreen({super.key});

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
    'Friendship', // Corrected from 'Friends'
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
  final List<String> _nsfwPicsOptions = [
    'Yes',
    'No',
    'Not At First',
    'Maybe'
  ]; // Added 'Maybe'
  String? _selectedNsfwPics;

// Corrected _genderOptions
  final List<String> _genderOptions = [
    'Man',
    'Woman',
    'Non-binary' // Corrected from 'Non-Binary', removed 'Transgender', 'Prefer not to say'
  ];
  String? _selectedGender;

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
    _loadUserProfile();
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
      final String? loggedInUserId = await SecureStorageService.getUserId();
      if (loggedInUserId == null) {
        throw Exception(
            "Authentication error: No logged-in user ID found. Please log in again.");
      }

      final UserModel fetchedProfile =
          (await ApiService.getUserProfile(loggedInUserId)) as UserModel;
      _currentUserProfile = fetchedProfile;

      _bioController.text = fetchedProfile.aboutMe;
      // Populate username and email from secure storage,
      // as they might not be part of the general user profile API response.
      _usernameController.text = await SecureStorageService.getUserName() ??
          fetchedProfile.userName; // Fallback to fetched profile username
      _emailController.text = await SecureStorageService.getEmail() ??
          'myemail@example.com'; // Placeholder if email not in secure storage

      // Remove units for editing
      _heightController.text = fetchedProfile.height.replaceAll(' cm', '');
      _weightController.text = fetchedProfile.weight.replaceAll(' kg', '');

      _selectedBuild = fetchedProfile.build;
      _selectedLookingFor = fetchedProfile.lookingFor;
      _selectedMeetAt = fetchedProfile.meetAt;
      _selectedNsfwPics = fetchedProfile.nsfwPics;
      _selectedGender = fetchedProfile.gender;
      _selectedPronouns = fetchedProfile.pronouns;
      _selectedRace = fetchedProfile.race;
      _selectedRelationshipStatus = fetchedProfile.relationshipStatus;

      _imageUrls.clear();
      _imageUrls.addAll(fetchedProfile.imageUrls);
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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_currentUserProfile == null) {
      if (!mounted) return; // Add mounted check before using context
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot save: User profile not loaded.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final updatedProfile = UserModel(
        id: _currentUserProfile!.id,
        aboutMe: _bioController.text,
        // Ensure height and weight are numbers before adding units
        height: _heightController.text.isNotEmpty &&
                int.tryParse(_heightController.text) != null
            ? '${_heightController.text} cm'
            : _currentUserProfile!.height, // Keep existing if invalid
        weight: _weightController.text.isNotEmpty &&
                int.tryParse(_weightController.text) != null
            ? '${_weightController.text} kg'
            : _currentUserProfile!.weight, // Keep existing if invalid
        build: _selectedBuild ?? _currentUserProfile!.build,
        lookingFor: _selectedLookingFor ?? _currentUserProfile!.lookingFor,
        meetAt: _selectedMeetAt ?? _currentUserProfile!.meetAt,
        nsfwPics: _selectedNsfwPics ?? _currentUserProfile!.nsfwPics,
        gender: _selectedGender ?? _currentUserProfile!.gender,
        pronouns: _selectedPronouns ?? _currentUserProfile!.pronouns,
        race: _selectedRace ?? _currentUserProfile!.race,
        relationshipStatus: _selectedRelationshipStatus ??
            _currentUserProfile!.relationshipStatus,
        imageUrls: _imageUrls, // Pass the current list of image URLs
        status: _currentUserProfile!.status,
        age: _currentUserProfile!.age,
        distance: _currentUserProfile!.distance,
        userName: _usernameController
            .text, // Use the updated username from the controller
      );

      await ApiService.updateUserProfile(updatedProfile);

      // Also update username and email locally if they are part of profile
      await SecureStorageService.saveUserName(_usernameController.text);
      await SecureStorageService.saveEmail(_emailController.text);

      if (!mounted) return; // Add mounted check before using context
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      if (mounted) {
        Navigator.of(context).pop(); // Go back after successful save
      }
    } catch (e) {
      _errorMessage =
          'Failed to save profile: ${e.toString().split(':').last.trim()}';

      if (!mounted) return; // Add mounted check before using context
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage)),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
          fontSize: 16.0,
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
        title:
            const Text('Edit Profile', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: (_isLoading ||
                    _isImageProcessing) // Disable save button while any operation is loading
                ? null
                : _saveProfile,
          ),
        ],
      ),
      body: _isLoading &&
              _currentUserProfile ==
                  null // Show loading indicator only on initial profile load
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Text(_errorMessage,
                      style: const TextStyle(color: Colors.red)))
              : Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _usernameController
                                .text, // Display username from controller
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Main profile image
                          GestureDetector(
                            onTap: _isImageProcessing
                                ? null
                                : _pickImage, // Allow picking a new main image, disable if image processing
                            child: CircleAvatar(
                              radius: 50.0,
                              backgroundColor:
                                  Colors.grey[800], // Background for avatar
                              backgroundImage: _imageUrls.isNotEmpty
                                  ? NetworkImage(_imageUrls[0])
                                  : null, // Use NetworkImage, null if no image
                              child: _imageUrls.isEmpty
                                  ? ClipOval(
                                      child: Image.asset(
                                        'assets/placeholder_error.jpg', // Use asset for placeholder
                                        fit: BoxFit.cover,
                                        width:
                                            100, // Ensure it fills the circle
                                        height: 100,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildSectionTitle('Bio'),
                          _buildTextField(_bioController, 'Enter your bio',
                              maxLines: 3),
                          const SizedBox(height: 20),
                          _buildSectionTitle('Height (cm)'),
                          _buildTextField(_heightController, 'e.g., 175',
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ]), // Only allow digits
                          const SizedBox(height: 20),
                          _buildSectionTitle('Weight (kg)'),
                          _buildTextField(_weightController, 'e.g., 70',
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ]), // Only allow digits
                          const SizedBox(height: 20),
                          _buildSectionTitle('Build'),
                          _buildDropdown(_buildOptions, _selectedBuild,
                              (newValue) {
                            setState(() {
                              _selectedBuild = newValue;
                            });
                          }),
                          const SizedBox(height: 20),
                          _buildSectionTitle('Looking For'),
                          _buildDropdown(
                              _lookingForOptions, _selectedLookingFor,
                              (newValue) {
                            setState(() {
                              _selectedLookingFor = newValue;
                            });
                          }),
                          const SizedBox(height: 20),
                          _buildSectionTitle('Meet At'),
                          _buildDropdown(_meetAtOptions, _selectedMeetAt,
                              (newValue) {
                            setState(() {
                              _selectedMeetAt = newValue;
                            });
                          }),
                          const SizedBox(height: 20),
                          _buildSectionTitle('NSFW Pics'),
                          _buildDropdown(_nsfwPicsOptions, _selectedNsfwPics,
                              (newValue) {
                            setState(() {
                              _selectedNsfwPics = newValue;
                            });
                          }),
                          const SizedBox(height: 20),
                          _buildSectionTitle('Gender'),
                          _buildDropdown(_genderOptions, _selectedGender,
                              (newValue) {
                            setState(() {
                              _selectedGender = newValue;
                            });
                          }),
                          const SizedBox(height: 20),
                          _buildSectionTitle('Pronouns'),
                          _buildDropdown(_pronounsOptions, _selectedPronouns,
                              (newValue) {
                            setState(() {
                              _selectedPronouns = newValue;
                            });
                          }),
                          const SizedBox(height: 20),
                          _buildSectionTitle('Race'),
                          _buildDropdown(_raceOptions, _selectedRace,
                              (newValue) {
                            setState(() {
                              _selectedRace = newValue;
                            });
                          }),
                          const SizedBox(height: 20),
                          _buildSectionTitle('Relationship Status'),
                          _buildDropdown(_relationshipStatusOptions,
                              _selectedRelationshipStatus, (newValue) {
                            setState(() {
                              _selectedRelationshipStatus = newValue;
                            });
                          }),
                          const SizedBox(height: 20),
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
                                    onTap: _isImageProcessing
                                        ? null
                                        : _pickImage, // Disable while uploading/deleting an image
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withAlpha(
                                            25), // Corrected from withValues(alpha: 25)
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        border: Border.all(
                                            color: Colors.white.withAlpha(
                                                13)), // Corrected from withValues(alpha: 13)
                                      ),
                                      child:
                                          _isImageProcessing // Show small loader if an image operation is in progress
                                              ? const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                          color: Colors.white))
                                              : const Icon(Icons.add_a_photo,
                                                  color: Colors.white54,
                                                  size: 40),
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
                                          // Removed redundant DecorationImage to rely on Image.network error/loading builders
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
                                                  color: Colors.grey,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: GestureDetector(
                                          onTap: _isImageProcessing
                                              ? null
                                              : () => _removeImage(
                                                  imageUrl), // Disable while loading
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
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
                                  : _performLogout, // Disable while any operation is loading
                              icon:
                                  const Icon(Icons.logout, color: Colors.white),
                              label: const Text('Log Out'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
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

  /// Helper widget for consistent text form fields.
  Widget _buildTextField(TextEditingController controller, String hintText,
      {int maxLines = 1,
      TextInputType keyboardType = TextInputType.text,
      List<TextInputFormatter>? inputFormatters}) {
    return TextFormField(
      controller: controller,
      // --- START TEXTFORMFIELD COLOR CHANGES ---
      style: const TextStyle(
          color: Colors
              .lightGreenAccent), // <--- CHANGE THIS for the text the user types
      // --- END TEXTFORMFIELD COLOR CHANGES ---
      keyboardType: keyboardType,
      inputFormatters: inputFormatters, // Apply formatters
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
            color: Colors.cyan), // <--- CHANGE THIS for the hint text color
        // --- START INPUTDECORATION COLOR CHANGES ---
        filled: true, // MUST be true for fillColor to work
        fillColor: Colors.deepPurple.withAlpha(
            76), // <--- CHANGED THIS from withOpacity(0.3) for the background color of the input field
        // --- END INPUTDECORATION COLOR CHANGES ---
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(
              color: Colors
                  .orange), // <--- CHANGE THIS for the default border color
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(
              color: Colors
                  .orange), // <--- CHANGE THIS for the border color when enabled
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(
              color: Colors
                  .red), // <--- CHANGE THIS for the border color when focused
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
  Widget _buildDropdown(List<String> items, String? selectedValue,
      ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      // 1. Background color for the dropdown *menu* itself (when it's open)
      dropdownColor:
          Colors.deepPurple.shade800, // <--- CHANGE THIS (Example: dark purple)

      // 2. Text color for the *selected item* displayed in the closed dropdown field
      style: const TextStyle(
          color:
              Colors.lightBlueAccent), // <--- CHANGE THIS (Example: light blue)

      decoration: InputDecoration(
        filled: true,
        // 3. Background color for the dropdown *field* itself (the visible box)
        fillColor: Colors.blueGrey.shade800.withOpacity(
            0.5), // <--- CHANGE THIS (Example: semi-transparent dark blue-grey)

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide:
              BorderSide.none, // You currently have no border here, keeping it
        ),
        // Optionally, define borders for enabled and focused states for more control
        enabledBorder: OutlineInputBorder(
          // <<< FIXED SYNTAX HERE
          borderRadius: BorderRadius.circular(10.0),
          borderSide:
              BorderSide.none, // Corrected missing parenthesis/completion
        ),
        // Add focusedBorder if needed for consistency with TextField
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide:
              const BorderSide(color: Colors.red), // Example focused border
        ),
      ),
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select an option';
        }
        return null;
      },
    );
  }
}
