// --- screens/login_screen.dart ---
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/secure_storage_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _loginUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final String email = _emailController.text;
      final String password =
          _passwordController.text; // This is used as otpCode for verifyStamp

      // First attempt to verify stamp (assuming this is a pre-login or 2FA step)
      final String? receivedKey = await ApiService.verifyStamp(
        email: email,
        otpCode:
            password, // Note: This uses password as otpCode, confirm your logic.
      );

      if (receivedKey != null) {
        // If verifyStamp is successful, handle the API key and navigate
        final String? storedKey = await SecureStorageService.getApiKey();

        if (storedKey == null || storedKey != receivedKey) {
          await SecureStorageService.saveApiKey(receivedKey);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Verification successful! API Key updated.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('Verification successful! Key already up-to-date.')),
          );
        }
        Navigator.pushReplacementNamed(context, '/grindr');
      } else {
        // If verifyStamp fails (receivedKey is null), then attempt the standard login
        print('OTP verification failed, attempting standard login...');
        final bool loginSuccess = await ApiService.login(
            email, password); // Await the result of AuthService.login

        setState(() {
          _isLoading = false; // Set loading to false after the login attempt
        });

        if (loginSuccess) {
          // Login was successful
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login successful!')),
          );
          Navigator.pushReplacementNamed(
              context, '/grindr'); // Navigate on successful login
        } else {
          // Login failed
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Login failed. Please check your credentials.')),
          );
        }
      }

      // Ensure _isLoading is set to false in all paths to prevent UI getting stuck
      // If it was set to false within the `else` block, ensure it's also handled if `receivedKey != null`
      // Or set it once after all async operations are complete.
      if (_isLoading) {
        // Only set to false if it's still true from the initial setState
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the color from the "Welcome Back!" title for consistency

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
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
                Image.asset(
                  'assets/icon_128.png', // Replace with your image path
                  height: 100, // Adjust height as needed
                  width: 100, // Adjust width as needed
                ),
                Text(
                  'Welcome Back!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[
                            200], // This is the color you want for the labels
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                // --- EMAIL INPUT ---
                Column(
                  crossAxisAlignment: CrossAxisAlignment
                      .start, // Align text and field to the start
                  children: [
                    const SizedBox(
                        height: 0), // Space between label and TextField
                    TextFormField(
                      controller: _emailController,
                      // Removed labelText from InputDecoration
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.email),
                        prefixIconColor: Color(0xFFFF0000),
                        alignLabelWithHint:
                            true, // Keep this if you want hint to align with label when it's there
                        hintText:
                            'Enter your email', // Add hint text if you like
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
                const SizedBox(height: 20),

                // --- PASSWORD INPUT ---
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                        height: 0), // Space between label and TextField
                    TextFormField(
                      controller: _passwordController,
                      // Removed labelText from InputDecoration
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.lock),
                        prefixIconColor: Color(
                            0xFFFF0000), // Assuming you want this color for password icon too
                        hintText:
                            'Enter your password', // Add hint text if you like
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 30),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _loginUser,
                        child: const Text('Login'),
                      ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text('Don\'t have an account? Register'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/forgot_password');
                  },
                  child: const Text('Forgot Password?'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
