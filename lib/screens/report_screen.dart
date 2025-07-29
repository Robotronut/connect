import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // For CupertinoIcons
import 'package:connect/models/user_model.dart';
import 'package:connect/screens/chat_screen.dart';
import 'package:connect/services/api_service.dart';
import 'package:connect/services/secure_storage_service.dart';
import 'package:connect/screens/edit_profile_screen.dart';
import 'package:connect/screens/photo_detail_screen.dart';

// --- New ReportScreen Widget ---
class ReportScreen extends StatefulWidget {
  final String? reportedUserId;
  final String? reportedUsername;

  const ReportScreen({
    super.key,
    required this.reportedUserId,
    required this.reportedUsername,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final TextEditingController _reportReasonController = TextEditingController();
  bool _isSubmitting = false;
  String? _submissionMessage; // To show success or error messages

  @override
  void dispose() {
    _reportReasonController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    setState(() {
      _isSubmitting = true;
      _submissionMessage = null;
    });

    final String reportReason = _reportReasonController.text.trim();

    if (reportReason.isEmpty) {
      setState(() {
        _submissionMessage = 'Please provide a reason for the report.';
        _isSubmitting = false;
      });
      return;
    }

    try {
      // In a real application, you would send this report to your backend
      // using an ApiService call. For this example, we'll simulate it.
      print('Reporting user: ${widget.reportedUsername} (ID: ${widget.reportedUserId})');
      print('Reason: $reportReason');

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Assuming the API call was successful
      setState(() {
        _submissionMessage = 'Report submitted successfully!';
      });
      // Optionally navigate back after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    } catch (e) {
      setState(() {
        _submissionMessage = 'Failed to submit report: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Report ${widget.reportedUsername}',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Please describe why you are reporting ${widget.reportedUsername}:',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _reportReasonController,
              maxLines: 5,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'e.g., Inappropriate content, harassment, fake profile...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                filled: true,
                fillColor: Colors.grey[850],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent, // Button color
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                'Submit Report',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            if (_submissionMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  _submissionMessage!,
                  style: TextStyle(
                    color: _submissionMessage!.contains('successfully') ? Colors.green : Colors.red,
                    fontSize: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
