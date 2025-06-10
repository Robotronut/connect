// lib/screens/profile_screen.dart (Continued)
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:connect/services/secure_storage_service.dart';
import 'package:connect/services/api_service.dart'; // Import your API service
import 'package:connect/models/user_model.dart'; // Import your user model
import 'dart:io'; // Required for File

class EditProfileScreen extends StatefulWidget {
  // It's good practice to pass the current user's ID
  // or even the UserProfile object if you already have it.
  // For simplicity, we'll assume we fetch it using the logged-in user's credentials.
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
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
  List<String> _buildOptions = [
    'Athletic',
    'Average',
    'Muscular',
    'Slim',
    'Heavy',
    'Other'
  ];
  String? _selectedBuild;

  List<String> _lookingForOptions = [
    'Chat',
    'Hookups',
    'Dating',
    'Friends',
    'Anything'
  ];
  String? _selectedLookingFor;

  List<String> _meetAtOptions = [
    'My Place',
    'Your Place',
    'Public Place',
    'Cafe',
    'Online'
  ];
  String? _selectedMeetAt;

  List<String> _nsfwPicsOptions = ['Yes', 'No', 'Not At First'];
  String? _selectedNsfwPics;

  List<String> _genderOptions = [
    'Man',
    'Woman',
    'Non-Binary',
    'Transgender',
    'Prefer not to say'
  ];
  String? _selectedGender;

  List<String> _pronounsOptions = [
    'He/Him/His',
    'She/Her/Hers',
    'They/Them/Theirs',
    'Ask me'
  ];
  String? _selectedPronouns;

  List<String> _raceOptions = [
    'White',
    'Black',
    'Asian',
    'Hispanic',
    'Mixed',
    'Other'
  ];
  String? _selectedRace;

  List<String> _relationshipStatusOptions = [
    'Single',
    'Taken',
    'Open',
    'Complicated'
  ];
  String? _selectedRelationshipStatus;

  // Store the UserProfile that we are editing
  UserModel? _currentUserProfile;

  // List of image URLs (can be local paths or network URLs)
  // Initially, this will hold the fetched network URLs
  final List<String> _imageUrls = [];
  final picker = ImagePicker();

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

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // For simplicity, we assume the API knows which profile to fetch
      // based on the provided email/securityStamp.
      // If your API requires a specific user ID, you'd need to store/pass it.
      // For now, let's mock a user ID or assume a 'get_my_profile' endpoint.
      // If you need a user ID, you could fetch it from secure storage first.
      final String? loggedInUserId =
          await SecureStorageService.getApiKey(); // Assuming you store userId
      if (loggedInUserId == null) {
        throw Exception("No logged-in user ID found.");
      }

      final UserModel fetchedProfile =
          await ApiService.getUserProfile(loggedInUserId);
      _currentUserProfile = fetchedProfile;

      _bioController.text = fetchedProfile.aboutMe;
      // Note: your API doesn't return 'name' or 'email' for user profiles
      // on get_people. If your user management API returns these, populate them.
      // For now, we'll load them from secure storage if they exist.
      _usernameController.text =
          await SecureStorageService.getUserName() ?? 'My Username';
      _emailController.text =
          await SecureStorageService.getEmail() ?? 'myemail@example.com';

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
      _errorMessage = 'Failed to load profile: ${e.toString()}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage)),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_currentUserProfile == null) {
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
      // Create an updated UserProfile object from current state
      final updatedProfile = UserModel(
          id: _currentUserProfile!.id, // Keep the original ID
          aboutMe: _bioController.text,
          height: '${_heightController.text} cm',
          weight: '${_weightController.text} kg',
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
          status: _currentUserProfile!
              .status, // Status might be dynamically updated by backend
          age: _currentUserProfile!.age, // Age typically not edited here
          distance: _currentUserProfile!
              .distance, // Distance typically not edited here
          userName: _currentUserProfile!.userName);

      await ApiService.updateUserProfile(updatedProfile);

      // Also update username and email locally if they are part of profile
      await SecureStorageService.saveUserName(_usernameController.text);
      await SecureStorageService.saveEmail(_emailController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      if (mounted) {
        Navigator.of(context).pop(); // Go back after successful save
      }
    } catch (e) {
      _errorMessage = 'Failed to save profile: ${e.toString()}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage)),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _isLoading = true; // Show loading while uploading
      });
      try {
        File imageFile = File(pickedFile.path);
        final imageUrl =
            await ApiService.uploadImage(imageFile); // Upload to API
        setState(() {
          _imageUrls.add(imageUrl); // Add the returned URL to the list
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploaded successfully!')),
        );
      } catch (e) {
        _errorMessage = 'Failed to upload image: ${e.toString()}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMessage)),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      print('No image selected.');
    }
  }

  void _removeImage(String imageUrlToRemove) async {
    setState(() {
      _isLoading = true; // Show loading while deleting
    });
    try {
      await ApiService.deleteImage(imageUrlToRemove); // Delete from API
      setState(() {
        _imageUrls.remove(imageUrlToRemove); // Remove from local list
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image removed successfully!')),
      );
    } catch (e) {
      _errorMessage = 'Failed to remove image: ${e.toString()}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage)),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _performLogout() async {
    await SecureStorageService.deleteAllAuthData();
    print('User logged out locally.');

    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (Route<dynamic> route) => false,
      );
    }
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
            onPressed: _isLoading
                ? null
                : _saveProfile, // Disable save button while loading
          ),
        ],
      ),
      body: _isLoading && _currentUserProfile == null
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
                            onTap: _pickImage, // Allow picking a new main image
                            child: CircleAvatar(
                              radius: 50.0,
                              backgroundImage: _imageUrls.isNotEmpty
                                  ? NetworkImage(
                                      _imageUrls[0]) // Use NetworkImage
                                  : const AssetImage(
                                          'assets/placeholder_error.jpg')
                                      as ImageProvider, // Default placeholder
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildSectionTitle('Bio'),
                          _buildTextField(_bioController, 'Enter your bio',
                              maxLines: 3),
                          const SizedBox(height: 20),
                          _buildSectionTitle('Height (cm)'),
                          _buildTextField(_heightController, 'e.g., 175',
                              keyboardType: TextInputType.number),
                          const SizedBox(height: 20),
                          _buildSectionTitle('Weight (kg)'),
                          _buildTextField(_weightController, 'e.g., 70',
                              keyboardType: TextInputType.number),
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
                                    onTap: _isLoading
                                        ? null
                                        : _pickImage, // Disable while uploading
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        border: Border.all(
                                            color:
                                                Colors.white.withOpacity(0.3)),
                                      ),
                                      child:
                                          _isLoading // Show small loader if something is uploading
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
                                          image: DecorationImage(
                                            image: NetworkImage(
                                                imageUrl), // Use NetworkImage
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          // To show error/loading on images
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
                                          onTap: _isLoading
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
                              onPressed: _isLoading
                                  ? null
                                  : _performLogout, // Disable while loading
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

  // Helper for text fields
  Widget _buildTextField(TextEditingController controller, String hintText,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.blue),
        ),
      ),
      maxLines: maxLines,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field cannot be empty';
        }
        return null;
      },
    );
  }

  // Helper for dropdowns
  Widget _buildDropdown(List<String> items, String? selectedValue,
      ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      dropdownColor: Colors.black, // Background color for dropdown menu
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
      ),
      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: const TextStyle(color: Colors.white)),
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

  // Helper for section titles
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
