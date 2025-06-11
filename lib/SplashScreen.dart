import 'package:flutter/material.dart';
import 'package:connect/services/secure_storage_service.dart'; // Ensure this path is correct for your project
import 'package:connect/services/api_service.dart'; // Ensure this path is correct for your project

class SplashScreen extends StatefulWidget {
  // We no longer need 'nextScreen' as we'll determine the next route internally
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus(); // Call the new authentication check method
  }

  // This method handles checking the authentication status
  Future<void> _checkAuthStatus() async {
    // Optional: Keep a minimum display duration for the splash screen

    // 1. Attempt to retrieve the stored API key (security stamp) and email
    final String? storedStamp = await SecureStorageService.getApiKey();
    final String? storedEmail = await SecureStorageService.getEmail();

    // Determine the next route based on stored credentials
    String nextRoute = '/login'; // Default to login screen

    // Proceed only if both a stamp and email are found in storage
    if (storedStamp != null &&
        storedStamp.isNotEmpty &&
        storedEmail != null &&
        storedEmail.isNotEmpty) {
      print('Found stored credentials. Attempting to verify stamp...');
      // 2. If credentials exist, try to verify them with your backend
      // Ensure your ApiService.verifyStamp is designed to handle invalid stamps by returning null
      final String? verifiedStamp = await ApiService.verifyStamp(
        email: storedEmail,
        otpCode: storedStamp, // This is the security stamp/token you stored
      );

      if (verifiedStamp != null) {
        // Stamp verified successfully!
        print('Stamp verified successfully. Navigating to Grindr.');
        // If your API returns a new stamp upon verification, save it.
        //await SecureStorageService.saveApiKey(verifiedStamp);
        nextRoute = '/grindr'; // User is authenticated, go to Grindr
      } else {
        // Stamp verification failed (e.g., expired, invalid, network error)
        print('Stamp verification failed. Navigating to Login.');
        // Optionally, clear invalid credentials to ensure a fresh login
        await SecureStorageService.deleteApiKey();
        await SecureStorageService.deleteAllAuthData();
      }
    } else {
      // No valid stamp or email found in storage, go to login
      print('No stored credentials found. Navigating to Login.');
    }

    // Ensure the widget is still mounted before attempting navigation
    if (mounted) {
      // Use pushReplacementNamed to prevent the user from going back to the splash screen
      Navigator.pushReplacementNamed(context, nextRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    // You can keep your splash screen design
    return const Scaffold(
      backgroundColor: Colors.black, // Your desired background color
      body: Center(
        //child: Image.asset('assets/icon_128.png'), // Your app icon
        // Or you could use a CircularProgressIndicator here to show loading
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 20),
            Text(
              'checking your credentials...',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
