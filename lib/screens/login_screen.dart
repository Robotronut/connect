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
  bool _isPasswordVisible = false; // New state for password visibility

  Future<void> _loginUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Start loading spinner
      });

      final String email = _emailController.text;
      final String password = _passwordController.text;

      try {
        final String? jwtToken = await ApiService.login(email, password);

        if (mounted) { // Ensure widget is still mounted before setState/ScaffoldMessenger
          if (jwtToken != null && jwtToken.isNotEmpty) {
            // Login was successful, save the JWT token
            //await SecureStorageService.saveApiKey(jwtToken);
            // Navigate on successful login and verification
            Navigator.pushReplacementNamed(context, '/grindr');
          } else {
            // Login failed (e.g., incorrect credentials, API returned null/empty token)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Login failed. Please check your credentials.')),
            );
          }
        }
      } catch (e) {
        // Catch any exceptions during the API call (e.g., network error)
        print('Login error: $e'); // Log the error for debugging
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('An error occurred during login: ${e.toString()}')),
          );
        }
      } finally {
        // Ensure _isLoading is set to false in all paths (success, failure, error)
        if (mounted) {
          setState(() {
            _isLoading = false; // Stop loading spinner
          });
        }
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
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.email),
                        prefixIconColor: Color(0xFFFF0000),
                        alignLabelWithHint: true,
                        hintText: 'Enter your email',
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
                      obscureText: !_isPasswordVisible, // Use the new state here
                      decoration: InputDecoration( // Changed to InputDecoration to use suffixIcon
                        prefixIcon: const Icon(Icons.lock),
                        prefixIconColor: const Color(0xFFFF0000),
                        hintText: 'Enter your password',
                        suffixIcon: IconButton( // Add the eyeball icon
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey, // Adjust color as needed
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible; // Toggle visibility
                            });
                          },
                        ),
                      ),
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
