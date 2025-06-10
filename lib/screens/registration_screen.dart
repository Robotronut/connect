// --- screens/registration_screen.dart ---
// Create a new file: lib/screens/registration_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final String username = _usernameController.text;
      final String email = _emailController.text;
      final String password = _passwordController.text;

      bool success = await ApiService.generateOtp(
        username: username,
        email: email,
        password: password,
      );

      setState(() {
        _isLoading = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Registration successful! OTP sent to your email.')),
        );
        // Navigate to OTP verification screen, passing email for context if needed
        Navigator.pushNamed(
          context,
          '/otp_verification',
          arguments: {
            'email':
                email, // Key-value pair: 'email' is the key, email variable is the value
            'username':
                username, // Key-value pair: 'username' is the key, username variable is the value
            'password':
                password, // Key-value pair: 'password' is the key, password variable is the value
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Registration failed. Please try again.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color? titleColor = Theme.of(context).textTheme.headlineSmall?.color;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Register'),
        centerTitle: true,
        backgroundColor: Colors.black, // Consistent app bar background
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
                // Logo Image
                Image.asset(
                  'assets/icon_128.png',
                  height: 75,
                  width: 75,
                ),
                const SizedBox(height: 5),

                // Title
                Text(
                  'Create Your Account',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[200],
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 0),

                // --- USERNAME INPUT FIELD ---
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        prefixIconColor: Color(0xFFFF0000),
                        hintText: 'Enter your username',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 0), // REDUCED SPACE HERE (was 20)

                // --- EMAIL INPUT FIELD ---
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Email',
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 6,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 0),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.email),
                        prefixIconColor: Color(0xFFFF0000),
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
                const SizedBox(height: 0), // REDUCED SPACE HERE (was 20)

                // --- PASSWORD INPUT FIELD ---
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Password',
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 6,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 0),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.lock),
                        prefixIconColor: Color(0xFFFF0000),
                        hintText: 'Enter your password',
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 0), // REDUCED SPACE HERE (was 20)

                // --- CONFIRM PASSWORD INPUT FIELD ---
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Confirm Password',
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 6,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 0),
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.lock_reset),
                        prefixIconColor: Color(0xFFFF0000),
                        hintText: 'Confirm your password',
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(
                    height: 15), // This one can remain larger before the button

                // Elevated Button for Registration
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _registerUser,
                        child: const Text('Register'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
