// --- screens/otp_verification_screen.dart ---
// Create a new file: lib/screens/otp_verification_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For TextInputFormatter
import '../services/api_service.dart';
import '../services/secure_storage_service.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());
  String _enteredOtp = '';
  bool _isLoading = false;
  String? _userEmail; // To store the email passed from the registration screen
  String? _userName;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _otpControllers.length; i++) {
      _otpControllers[i].addListener(() {
        if (_otpControllers[i].text.isNotEmpty && i < _focusNodes.length - 1) {
          // Move focus to the next field if a digit is entered and it's not the last field
          _focusNodes[i + 1].requestFocus();
        }
        _updateEnteredOtp();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retrieve the email passed as arguments
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      _userEmail = args['email'] as String?;
      _userName = args['username'] as String?;
    }
    if (_userEmail == null) {
      // Handle case where email is not passed (e.g., if user navigates directly)
      // Guard the use of context
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Error: User email not found. Please register again.')),
      );
      // Optionally, navigate back to registration or show an error
      // if (mounted) Navigator.pop(context); // Guard navigation too
    }
  }

  void _updateEnteredOtp() {
    _enteredOtp = _otpControllers.map((controller) => controller.text).join();
    setState(() {
      // Rebuild to update button state if needed
    });
  }

  Future<void> _verifyOtp() async {
    if (_enteredOtp.length != 4) {
      // Guard the use of context
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a complete 4-digit OTP.')),
      );
      return;
    }

    if (_userEmail == null) {
      // Guard the use of context
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error: Cannot verify OTP without user email.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final String otpCode = _enteredOtp;
      final String? userName = _userName;
      final String? key = await ApiService.verifyOtp(
          email: _userEmail!, otp: otpCode, username: userName!);

      setState(() {
        _isLoading = false;
      });

      if (key != null) {
        await SecureStorageService.saveApiKey(key);
        // Guard the use of context
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('OTP verified successfully! Key saved.')),
        );
        // You can now navigate to the main application screen
        // For example: Navigator.pushReplacementNamed(context, '/home');

        // Guard the call to showDialog
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text('Success!'),
              content: const Text('OTP verified and API Key saved securely.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(); // Close the dialog
                    // Guard the navigation too
                    if (!mounted) return;
                    Navigator.pushReplacementNamed(context, '/grindr');
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        // Guard the use of context
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('OTP verification failed. Please try again.')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Guard the use of context
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'Enter 4-Digit Code',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[800],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'A 4-digit code has been sent to your email: ${_userEmail ?? 'N/A'}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  return SizedBox(
                    width: 60,
                    child: TextFormField(
                      controller: _otpControllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1, // Only one digit per box
                      decoration: const InputDecoration(
                        counterText: "", // Hide the character counter
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter
                            .digitsOnly, // Only allow digits
                      ],
                      onChanged: (value) {
                        _updateEnteredOtp();
                        if (value.isEmpty && index > 0) {
                          // Move focus to previous field on backspace if current is empty
                          _focusNodes[index - 1].requestFocus();
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 40),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _enteredOtp.length == 4
                          ? _verifyOtp
                          : null, // Enable button only when 4 digits are entered
                      child: const Text('Verify OTP'),
                    ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  // Implement resend OTP logic here if needed
                  // Guard the use of context
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Resend OTP functionality not implemented yet.')),
                  );
                },
                child: const Text('Resend Code'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
