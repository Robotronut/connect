// --- main.dart ---
import 'package:connect/grindr.dart';
import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // New import
import 'screens/registration_screen.dart';
import 'screens/otp_verification_screen.dart';
import 'screens/forgot_password_screen.dart'; // New import
import '/splashScreen.dart'; // <--- NEW: Import your SplashScreen widget
const kServerUrl = "https://peek.thegwd.ca/chathub";
//const kServerUrl = "https://localhost:7197/chathub";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
// Helper function to create a MaterialColor from a single Color
  // This is a common pattern to avoid manually generating all shades
  MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.r.toInt(), g = color.g.toInt(), b = color.b.toInt();

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }

  @override
  Widget build(BuildContext context) {
    Color basePrimaryColor = const Color(0xFF00AEEF);
    return MaterialApp(
      title: 'User Authentication',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: createMaterialColor(basePrimaryColor),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter', // Using Inter font as per instructions
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0), // Rounded corners
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: basePrimaryColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: basePrimaryColor, width: 2.0),
          ),
          filled: true,
          fillColor: Colors.white.withAlpha(225),
          contentPadding:
          const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0), // Rounded corners
            ),
            backgroundColor: basePrimaryColor, // Background color
            foregroundColor: Colors.white, // Text color
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            elevation: 5, // Shadow
          ),
        ),
      ),
      // Set the initial route to your SplashScreen.
      // Make sure the key matches the route defined in the 'routes' map.
      initialRoute: '/', // <--- CHANGED: Set the initial route to the root '/'
      routes: {
        '/': (context) =>
        const SplashScreen(), // <--- NEW: Map the root route to SplashScreen
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/otp_verification': (context) => const OtpVerificationScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
        '/grindr': (context) =>
        const MainBrowseScreen(), // Make sure 'grindr()' returns a Widget
      },
    );
  }
}