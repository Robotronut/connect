// --- screens/forgot_password_screen.dart ---
// Create a new file: lib/screens/forgot_password_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _sendPasswordResetEmail() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final String email = _emailController.text;

      bool success = await ApiService.forgotPassword(email: email);

      setState(() {
        _isLoading = false;
      });

      if (success) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Password Reset'),
              content: const Text(
                  'If an account exists for this email, a password reset link has been sent.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Go back to login screen
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Failed to send password reset email. Please try again.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the color from the "Reset Your Password" title for consistency
    final Color? titleColor = Theme.of(context).textTheme.headlineSmall?.color;

    return Scaffold(
      backgroundColor: Colors.black, // Consistent background
      appBar: AppBar(
        title: const Text('Forgot Password'),
        centerTitle: true,
        backgroundColor: Colors.black, // Consistent app bar background
        foregroundColor: Colors.white, // Consistent app bar text color
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Logo Image
                Image.asset(
                  'assets/icon_128.png', // Ensure this path is correct
                  height: 100, // Adjust height as needed
                  width: 100, // Adjust width as needed
                ),
                const SizedBox(height: 15), // Added small space after logo

                // Title
                Text(
                  'Reset Your Password',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[200], // This is your title color
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // --- EMAIL INPUT FIELD ---
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Email', // Explicit label text
                      style: TextStyle(
                        color: titleColor, // Use the color from your title
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                        height: 8), // Spacing between label and field
                    TextFormField(
                      controller: _emailController,
                      // Removed labelText from InputDecoration
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.email),
                        // Assuming you want the same color for the icon as in login screen
                        prefixIconColor: Color(0xFFFF0000),
                        hintText: 'Enter your email', // Optional hint text
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Elevated Button for Sending Reset Link
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _sendPasswordResetEmail,
                        child: const Text('Send Reset Link'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
