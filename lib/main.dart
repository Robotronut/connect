import 'package:flutter/material.dart';
import 'grindr.dart';
import 'SplashScreen.dart'; // Import your SplashScreen widget

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Black Login Screen',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashScreen(nextScreen: LoginScreen()),
      routes: {
        '/forgotPassword': (context) => const ForgotPasswordScreen(),
        '/register': (context) => const RegisterScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset is true by default, which is what we want.
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: Colors.black),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            // Center the scrollable content
            child: SingleChildScrollView(
              // Make content scrollable
              child: Column(
                mainAxisSize:
                    MainAxisSize.min, // Column takes minimum vertical space
                mainAxisAlignment:
                    MainAxisAlignment
                        .center, // Center content within the column if it has extra space (less likely with min)
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Text(
                    'Login',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  TextField(
                    controller: _usernameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      labelStyle: TextStyle(color: Colors.grey),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  TextField(
                    controller: _passwordController,
                    style: const TextStyle(color: Colors.white),
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(color: Colors.grey),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  ElevatedButton(
                    onPressed: () {
                      String username = _usernameController.text;
                      String password = _passwordController.text;
                      print('Login - Username: $username, Password: $password');

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => grindr()),
                      );
                      // Implement your actual login logic
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFCD05),
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(color: Colors.black, fontSize: 18.0),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/forgotPassword');
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      const Text(' / ', style: TextStyle(color: Colors.grey)),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: const Text(
                          'Register',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: Colors.black),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            // Center the scrollable content
            child: SingleChildScrollView(
              // Make content scrollable
              child: Column(
                mainAxisSize:
                    MainAxisSize.min, // Column takes minimum vertical space
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Text(
                    'Forgot Password',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  const TextField(
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      labelStyle: TextStyle(color: Colors.grey),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  ElevatedButton(
                    onPressed: () {
                      print('Request Password Reset');
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFCD05),
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text(
                      'Reset Password',
                      style: TextStyle(color: Colors.black, fontSize: 18.0),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Back to Login',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: Colors.black),
        padding: const EdgeInsets.all(
          20.0,
        ), // Container provides overall padding
        child: Center(
          // Center the scrollable content
          child: SingleChildScrollView(
            // Make content scrollable
            child: Column(
              mainAxisSize:
                  MainAxisSize.min, // Column takes minimum vertical space
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  'Register',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30.0),
                const TextField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Username',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                const TextField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                const TextField(
                  style: TextStyle(color: Colors.white),
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                const TextField(
                  style: TextStyle(color: Colors.white),
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(height: 30.0),
                ElevatedButton(
                  onPressed: () {
                    print('Register New User');
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFCD05),
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    'Register',
                    style: TextStyle(color: Colors.black, fontSize: 18.0),
                  ),
                ),
                const SizedBox(height: 20.0),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Back to Login',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
