import 'package:flutter/material.dart';
import 'package:get/route_manager.dart'; // Assuming GetX for navigation or similar

/// A screen for managing application settings.
///
/// This screen provides various options for users to configure their account,
/// notifications, privacy, and general app preferences.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // State variables for various settings toggles
  bool _showOnlineStatus = true;
  String _selectedLanguage = 'English'; // Default language

  // New notification toggles
  bool _soundNotificationsEnabled = true;
  bool _vibrationNotificationsEnabled = true;
  bool _tapsNotificationsEnabled = true; // Assuming "received taps" refers to in-app taps/interactions

  // New theme toggle
  bool _isDarkMode = true; // Default to dark mode

  // New state for 'Show Distance'
  bool _showDistanceEnabled = true;

  // Helper method for consistent section titles
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 24.0, left: 16.0),
      child: Text(
        title,
        style: TextStyle(
          color: _isDarkMode ? Colors.yellow : Colors.blueAccent, // Highlighted color for section titles
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// A helper widget to create a full-width, tappable row for navigation or simple actions.
  Widget _buildActionRow({
    required String title,
    required VoidCallback onTap,
    String? subtitle,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          // Removed the border property to eliminate the white border
          color: _isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.shade200, // Background color based on theme
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black87, // Text color based on theme
                    fontSize: 16,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: _isDarkMode ? Colors.grey : Colors.grey[700], // Subtitle color based on theme
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
            Icon(Icons.arrow_forward_ios, color: _isDarkMode ? Colors.grey : Colors.grey[600], size: 16),
          ],
        ),
      ),
    );
  }

  /// A helper widget to create a toggle switch setting.
  Widget _buildSwitchRow({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    String? subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        // Removed the border property to eliminate the white border
        color: _isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.shade200, // Background color based on theme
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: SwitchListTile(
        title: Text(
          title,
          style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black87, fontSize: 16), // Text color based on theme
        ),
        subtitle: subtitle != null
            ? Text(
          subtitle,
          style: TextStyle(color: _isDarkMode ? Colors.grey : Colors.grey[700], fontSize: 12), // Subtitle color based on theme
        )
            : null,
        value: value,
        onChanged: onChanged,
        activeColor: _isDarkMode ? Colors.yellow : Colors.blueAccent, // Color when the switch is ON
        inactiveTrackColor: _isDarkMode ? Colors.grey[700] : Colors.grey[400], // Color of the track when OFF
        inactiveThumbColor: _isDarkMode ? Colors.grey[400] : Colors.grey[600], // Color of the thumb when OFF
      ),
    );
  }

  /// A helper widget to create a selectable row with options (e.g., for language).
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
              color: _isDarkMode ? Colors.grey[900] : Colors.white, // Background color based on theme
              height: 300,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      title,
                      style: TextStyle(
                          color: _isDarkMode ? Colors.white : Colors.black87, // Text color based on theme
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
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
                          return ListTile(
                            title: Text(
                              option,
                              style: TextStyle(
                                color: selectedValue == option
                                    ? (_isDarkMode ? Colors.yellow : Colors.blueAccent) // Selected option color
                                    : (_isDarkMode ? Colors.white : Colors.black87), // Unselected option color
                              ),
                            ),
                            trailing: selectedValue == option
                                ? Icon(Icons.check, color: _isDarkMode ? Colors.yellow : Colors.blueAccent) // Check icon color
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
          // Removed the border property to eliminate the white border
          color: _isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.shade200, // Background color based on theme
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: _isDarkMode ? Colors.white : Colors.black87, // Text color based on theme
                fontSize: 16,
              ),
            ),
            Row(
              children: [
                Text(
                  selectedValue ?? 'Select',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.grey : Colors.grey[700], // Selected value color based on theme
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios, color: _isDarkMode ? Colors.grey : Colors.grey[600], size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkMode ? Colors.black : Colors.white, // Consistent background based on theme
      appBar: AppBar(
        backgroundColor: _isDarkMode ? Colors.black : Colors.blueGrey[800], // AppBar color based on theme
        title: Text(
          'Settings',
          style: TextStyle(
              color: _isDarkMode ? Colors.yellow : Colors.white, // Title color based on theme
              fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: _isDarkMode ? Colors.white : Colors.white), // White back arrow
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Account Settings ---
            _buildSectionTitle('ACCOUNT'),
            _buildActionRow(
              title: 'Change Password',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                );
              },
            ),
            _buildActionRow(
              title: 'Delete Account',
              subtitle: 'Permanently delete your account and data.',
              onTap: () {
                // TODO: Implement delete account logic with confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Show Delete Account Confirmation')),
                );
              },
            ),

            // --- Notification Settings ---
            _buildSectionTitle('NOTIFICATIONS'),
            _buildSwitchRow(
              title: 'Sound Notifications',
              value: _soundNotificationsEnabled,
              onChanged: (bool newValue) {
                setState(() {
                  _soundNotificationsEnabled = newValue;
                });
                // TODO: Update sound notification preference in backend
              },
              subtitle: 'Play a sound for new notifications.',
            ),
            _buildSwitchRow(
              title: 'Vibration Notifications',
              value: _vibrationNotificationsEnabled,
              onChanged: (bool newValue) {
                setState(() {
                  _vibrationNotificationsEnabled = newValue;
                });
                // TODO: Update vibration notification preference in backend
              },
              subtitle: 'Vibrate for new notifications.',
            ),
            _buildSwitchRow(
              title: 'Tap Notifications',
              value: _tapsNotificationsEnabled,
              onChanged: (bool newValue) {
                setState(() {
                  _tapsNotificationsEnabled = newValue;
                });
                // TODO: Update in-app tap notification preference in backend
              },
              subtitle: 'Receive subtle visual cues for new activity.',
            ),

            // --- Privacy Settings ---
            _buildSectionTitle('PRIVACY'),
            _buildSwitchRow(
              title: 'Show Distance', // Changed title
              value: _showDistanceEnabled, // Using new state variable
              onChanged: (bool newValue) {
                setState(() {
                  _showDistanceEnabled = newValue;
                });
                // TODO: Handle preference for showing distance
              },
              subtitle: 'Display your distance from other users.', // New subtitle
            ),
            _buildSwitchRow(
              title: 'Show Online Status',
              value: _showOnlineStatus,
              onChanged: (bool newValue) {
                setState(() {
                  _showOnlineStatus = newValue;
                });
                // TODO: Update online status preference in backend
              },
              subtitle: 'Let others see when you are online.',
            ),
            _buildActionRow(
              title: 'Blocked Users',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BlockedUsersScreen()),
                );
              },
              subtitle: 'Manage users you have blocked.',
            ),

            // --- App Preferences ---
            _buildSectionTitle('APP PREFERENCES'),
            _buildSelectableRow(
              title: 'Language',
              selectedValue: _selectedLanguage,
              options: ['English', 'Spanish', 'French', 'German'], // Example languages
              onChanged: (newValue) {
                setState(() {
                  _selectedLanguage = newValue!;
                });
                // TODO: Change app language (requires localization setup)
              },
            ),
            _buildSwitchRow(
              title: 'Dark Mode',
              value: _isDarkMode,
              onChanged: (bool newValue) {
                setState(() {
                  _isDarkMode = newValue;
                });
                // TODO: Persist theme preference and apply globally if needed
              },
              subtitle: 'Toggle between dark and light themes.',
            ),

            // --- About ---
            _buildSectionTitle('ABOUT'),
            _buildActionRow(
              title: 'Version',
              subtitle: '1.0.0', // Replace with actual app version
              onTap: () {
                // No action, just display version
              },
            ),
            _buildActionRow(
              title: 'Terms of Service',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TermsOfServiceScreen()),
                );
              },
            ),
            _buildActionRow(
              title: 'Privacy Policy',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
                );
              },
            ),
            const SizedBox(height: 50.0), // Padding at the bottom
          ],
        ),
      ),
    );
  }
}

/// A screen for changing the user's password.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (_newPasswordController.text != _confirmNewPasswordController.text) {
        setState(() {
          _errorMessage = 'New passwords do not match.';
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMessage)),
        );
        return;
      }

      try {
        // TODO: Implement actual API call to change password
        // Example: await ApiService.changePassword(_oldPasswordController.text, _newPasswordController.text);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully!')),
        );
        Navigator.pop(context); // Go back to settings screen
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'Failed to change password: ${e.toString()}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMessage)),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine if the parent SettingsScreen is in dark mode to apply consistent theme
    // This is a simplified approach; a proper theme management solution would be better
    final SettingsScreen? parentSettings = context.findAncestorWidgetOfExactType<SettingsScreen>();
    final bool parentIsDarkMode = (parentSettings?.createState() as _SettingsScreenState?)?._isDarkMode ?? true;


    return Scaffold(
      backgroundColor: parentIsDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: parentIsDarkMode ? Colors.black : Colors.blueGrey[800],
        title: Text(
          'Change Password',
          style: TextStyle(
              color: parentIsDarkMode ? Colors.yellow : Colors.white,
              fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: parentIsDarkMode ? Colors.white : Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _oldPasswordController,
                obscureText: true,
                style: TextStyle(color: parentIsDarkMode ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Old Password',
                  labelStyle: TextStyle(color: parentIsDarkMode ? Colors.grey : Colors.grey[700]),
                  filled: true,
                  fillColor: parentIsDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.shade300,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: parentIsDarkMode ? Colors.blueGrey : Colors.grey.shade500),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: parentIsDarkMode ? Colors.yellow : Colors.blueAccent),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your old password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                style: TextStyle(color: parentIsDarkMode ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: 'New Password',
                  labelStyle: TextStyle(color: parentIsDarkMode ? Colors.grey : Colors.grey[700]),
                  filled: true,
                  fillColor: parentIsDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.shade300,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: parentIsDarkMode ? Colors.blueGrey : Colors.grey.shade500),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: parentIsDarkMode ? Colors.yellow : Colors.blueAccent),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a new password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _confirmNewPasswordController,
                obscureText: true,
                style: TextStyle(color: parentIsDarkMode ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  labelStyle: TextStyle(color: parentIsDarkMode ? Colors.grey : Colors.grey[700]),
                  filled: true,
                  fillColor: parentIsDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.shade300,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: parentIsDarkMode ? Colors.blueGrey : Colors.grey.shade500),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: parentIsDarkMode ? Colors.yellow : Colors.blueAccent),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your new password';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),
              Center(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: parentIsDarkMode ? Colors.yellow : Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: parentIsDarkMode ? Colors.black : Colors.white)
                      : Text(
                    'Change Password',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: parentIsDarkMode ? Colors.black : Colors.white),
                  ),
                ),
              ),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Center(
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A screen for managing blocked users.
class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({Key? key}) : super(key: key);

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  // Example list of blocked users
  final List<String> _blockedUsers = [
    'User123',
    'AnotherUser',
    'BlockedGuy',
    'SpammerBot',
  ];

  void _unblockUser(String user) {
    setState(() {
      _blockedUsers.remove(user);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$user has been unblocked.')),
    );
    // TODO: Implement actual API call to unblock user
  }

  @override
  Widget build(BuildContext context) {
    // Determine if the parent SettingsScreen is in dark mode to apply consistent theme
    final SettingsScreen? parentSettings = context.findAncestorWidgetOfExactType<SettingsScreen>();
    final bool parentIsDarkMode = (parentSettings?.createState() as _SettingsScreenState?)?._isDarkMode ?? true;

    return Scaffold(
      backgroundColor: parentIsDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: parentIsDarkMode ? Colors.black : Colors.blueGrey[800],
        title: Text(
          'Blocked Users',
          style: TextStyle(
              color: parentIsDarkMode ? Colors.yellow : Colors.white,
              fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: parentIsDarkMode ? Colors.white : Colors.white),
      ),
      body: _blockedUsers.isEmpty
          ? Center(
        child: Text(
          'No blocked users.',
          style: TextStyle(color: parentIsDarkMode ? Colors.grey : Colors.black54, fontSize: 16),
        ),
      )
          : ListView.builder(
        itemCount: _blockedUsers.length,
        itemBuilder: (context, index) {
          final user = _blockedUsers[index];
          return Container(
            decoration: BoxDecoration(
              // Removed the border property to eliminate the white border
              color: parentIsDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10.0),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  user,
                  style: TextStyle(color: parentIsDarkMode ? Colors.white : Colors.black87, fontSize: 16),
                ),
                ElevatedButton(
                  onPressed: () => _unblockUser(user),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: const Text(
                    'Unblock',
                    style: TextStyle(color: Colors.white, fontSize: 14),
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

/// A screen for displaying the Privacy Policy.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Access the dark mode status from the parent SettingsScreen.
    final SettingsScreen? parentSettings = context.findAncestorWidgetOfExactType<SettingsScreen>();
    final bool parentIsDarkMode = (parentSettings?.createState() as _SettingsScreenState?)?._isDarkMode ?? true;

    return Scaffold(
      backgroundColor: parentIsDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: parentIsDarkMode ? Colors.black : Colors.blueGrey[800],
        title: Text(
          'Privacy Policy',
          style: TextStyle(
              color: parentIsDarkMode ? Colors.yellow : Colors.white,
              fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: parentIsDarkMode ? Colors.white : Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          _privacyPolicyText,
          style: TextStyle(
            color: parentIsDarkMode ? Colors.white70 : Colors.black87,
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  // A placeholder string for the privacy policy content.
  // This version is tailored for a dating app.
  final String _privacyPolicyText = '''
**1. Introduction**

This Privacy Policy describes how [App Name] ("we," "us," or "our") collects, uses, and shares your personal information when you use our dating application. We are committed to protecting your privacy and being transparent about our data practices.

**2. Information We Collect**

* **Profile Information:** When you create a profile, we collect information you provide, such as your name, gender, age, birth date, photos, interests, and a personal bio. This information is used to build your profile and is visible to other users of the service.
* **Location Data:** With your consent, we collect your precise geographic location to show you potential matches in your area. You can manage this permission in your device settings.
* **Messages and Communications:** We collect and store all messages and content you send and receive through the app's messaging features. This includes chat logs, photos, and other shared content. This is necessary to provide the service and for safety and moderation purposes.
* **Usage Data:** We automatically collect data on your interactions with the app, such as the profiles you view, the people you "like" or "pass," and your activity duration. This helps us to improve our matching algorithm and the overall user experience.
* **Device and Technical Information:** We collect information about your device, including the IP address, device type, operating system, and unique device identifiers. This is used for security, analytics, and to prevent fraud.

**3. How We Use Your Information**

We use the collected data for the following purposes:
* **To Provide and Improve the Service:** We use your profile information and preferences to match you with other users. Your usage data helps us to optimize our service and develop new features.
* **For Safety and Security:** We use your information to verify your identity, prevent fraud, and enforce our Terms of Service. We may use messages for moderation to ensure a safe and respectful community.
* **To Communicate With You:** We use your contact information to send you updates about the app, new features, and important service announcements.
* **To Personalize Your Experience:** We use your data to provide you with a more personalized experience, such as showing you profiles and content that may be of interest to you.

**4. Sharing Your Information**

Your profile information (name, photos, bio, etc.) is shared with other users of the app to facilitate connections. We do not sell or rent your personal information to third parties. We may share information with trusted third-party service providers who assist us in operating the app, conducting business, or serving you.

**5. Data Security and Your Rights**

We take reasonable measures to protect your personal information from unauthorized access or disclosure. However, no internet service is completely secure. You have the right to access, update, or delete your personal information. You can do this through your account settings or by contacting us.

**6. Changes to This Privacy Policy**

We may update our Privacy Policy periodically. We will notify you of any significant changes by posting the new policy on this page or through other communication methods.

**7. Contact Us**

If you have any questions or concerns about this Privacy Policy, please contact us at [Your Email Address].
''';
}

/// A screen for displaying the Terms of Service.
class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Access the dark mode status from the parent SettingsScreen.
    final SettingsScreen? parentSettings = context.findAncestorWidgetOfExactType<SettingsScreen>();
    final bool parentIsDarkMode = (parentSettings?.createState() as _SettingsScreenState?)?._isDarkMode ?? true;

    return Scaffold(
      backgroundColor: parentIsDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: parentIsDarkMode ? Colors.black : Colors.blueGrey[800],
        title: Text(
          'Terms of Service',
          style: TextStyle(
              color: parentIsDarkMode ? Colors.yellow : Colors.white,
              fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: parentIsDarkMode ? Colors.white : Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          _termsOfServiceText,
          style: TextStyle(
            color: parentIsDarkMode ? Colors.white70 : Colors.black87,
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  // A placeholder string for the terms of service content.
  // This version is tailored for a dating app.
  final String _termsOfServiceText = '''
**1. Acceptance of Terms**

By creating an account and using the [App Name] application ("the Service"), you agree to be bound by these Terms of Service. If you do not agree with any part of these terms, you may not use the Service.

**2. Eligibility and Account Creation**

* You must be at least 18 years old to use the Service.
* You are responsible for maintaining the confidentiality of your account password and for all activities that occur under your account.
* You agree to provide accurate, current, and complete information during registration and to update it as necessary. You may not create an account using false information.

**3. User Conduct and Content**

* You are solely responsible for the content you publish or display on the Service, including photos, profile information, and messages.
* You agree not to:
    * Post or transmit any content that is offensive, harassing, defamatory, obscene, or illegal.
    * Use the Service for any purpose that is fraudulent, misleading, or deceptive.
    * Harass, stalk, or abuse other users.
    * Impersonate any person or entity or misrepresent your age, identity, or affiliation.
    * Promote illegal activities or provide instructions on how to perform them.
    * Post content that infringes on the intellectual property rights of others.

**4. Safety and Interactions**

* We do not conduct background checks on our users. You are solely responsible for your interactions with other members.
* Exercise caution and use your best judgment when communicating with or meeting others.
* Report any inappropriate behavior to us immediately.

**5. Intellectual Property Rights**

You grant us a worldwide, transferable, sub-licensable, royalty-free license to use, reproduce, modify, and display the content you submit to the Service. The Service and its original content are the exclusive property of [Your Company Name] and its licensors.

**6. Termination**

We may terminate or suspend your account immediately, without prior notice or liability, for any reason, including without limitation if you breach these Terms. Upon termination, your right to use the Service will cease immediately.

**7. Disclaimers and Limitation of Liability**

The Service is provided on an "as is" and "as available" basis. We do not guarantee that the Service will be uninterrupted, error-free, or secure. In no event shall [Your Company Name] be liable for any indirect, incidental, special, or consequential damages arising out of your use of or inability to use the Service.

**8. Governing Law**

These Terms shall be governed by and construed in accordance with the laws of [Your Jurisdiction], without regard to its conflict of law provisions.

**9. Changes to Terms**

We reserve the right to modify or replace these Terms at any time. We will make reasonable efforts to provide notice of any new terms. By continuing to access or use the Service after those revisions become effective, you agree to be bound by the revised terms.

**10. Contact Information**

If you have any questions about these Terms of Service, please contact us at [Your Email Address].
''';
}


