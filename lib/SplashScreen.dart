import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final Widget? nextScreen;

  const SplashScreen({Key? key, this.nextScreen}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate a loading process or just delay the navigation
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => widget.nextScreen!),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: Image.asset('assets/icon_128.png')),
    );
  }
}
