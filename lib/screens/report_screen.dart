import 'package:connect/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // For CupertinoIcons
// Assuming these imports are still relevant for your project structure
// import 'package:connect/models/user_model.dart';
// import 'package:connect/screens/chat_screen.dart';
// import 'package:connect/services/api_service.dart';
// import 'package:connect/services/secure_storage_service.dart';
// import 'package:connect/screens/edit_profile_screen.dart';
// import 'package:connect/screens/photo_detail_screen.dart';

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
  // List of predefined report reasons, similar to Grindr
  final List<String> _reportReasons = [
    'Spam or Scam',
    'Inappropriate Content (Nudity, Hate Speech, Violence)',
    'Harassment or Bullying',
    'Underage User',
    'Fake Profile / Impersonation',
    'Offline Behavior (e.g., Catfishing, Solicitation)',
    'Privacy Violation (Sharing private info)',
    'Other (Please describe in detail)',
  ];

  String? _selectedReason; // Holds the currently selected reason
  final TextEditingController _otherReasonController =
      TextEditingController(); // For 'Other' option
  bool _isSubmitting = false;
  String? _submissionMessage; // To show success or error messages

  @override
  void dispose() {
    _otherReasonController.dispose();
    super.dispose();
  }

  String? finalReportReason;

  Future<void> _submitReport() async {
    setState(() {
      _isSubmitting = true;
      _submissionMessage = null;
    });

    if (_selectedReason == null) {
      setState(() {
        _submissionMessage = 'Please select a reason for the report.';
        _isSubmitting = false;
      });
      return;
    } else if (_selectedReason == 'Other (Please describe in detail)') {
      finalReportReason = _otherReasonController.text.trim();
      if (finalReportReason != null) {
        setState(() {
          _submissionMessage = 'Please describe the "Other" reason.';
          _isSubmitting = false;
        });
        return;
      }
    } else {
      finalReportReason = _selectedReason!;
    }

    try {
      // In a real application, you would send this report to your backend
      // using an ApiService call. For this example, we'll simulate it.
      await ApiService.reportUser(widget.reportedUserId, finalReportReason);
      print(
          'Reporting user: ${widget.reportedUsername} (ID: ${widget.reportedUserId})');
      print('Reason: $finalReportReason');

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
      body: SingleChildScrollView(
        // Added SingleChildScrollView here
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Please select a reason for reporting ${widget.reportedUsername}:',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 15),
              // Dropdown for selecting report reason
              DropdownButtonHideUnderline(
                child: DropdownButtonFormField<String>(
                  value: _selectedReason,
                  hint: Text(
                    'Select a reason',
                    style: TextStyle(
                        color: Colors.grey[
                            400]), // Adjusted hint text color for better contrast
                  ),
                  dropdownColor: Colors
                      .grey[800], // Color of the dropdown list when opened
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  icon:
                      const Icon(Icons.arrow_drop_down, color: Colors.white70),
                  decoration: InputDecoration(
                    // Moved BoxDecoration properties here
                    filled: true,
                    fillColor: Colors.grey[
                        850], // This controls the background color of the input field
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12), // Increased vertical padding
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedReason = newValue;
                    });
                  },
                  isExpanded: true,
                  // The `selectedItemBuilder` is crucial for customizing the display of the selected item
                  selectedItemBuilder: (BuildContext context) {
                    return _reportReasons.map<Widget>((String item) {
                      return Row(
                        // Wrap the Text in a Row
                        children: [
                          Expanded(
                            // Use Expanded to ensure text takes available width
                            child: Text(
                              item,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14),
                              maxLines: null, // Allow multiple lines
                              overflow: TextOverflow
                                  .visible, // Ensure full text is visible
                            ),
                          ),
                        ],
                      );
                    }).toList();
                  },
                  items: _reportReasons
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 15),
              // Text field for 'Other' reason, visible only when 'Other' is selected
              if (_selectedReason == 'Other (Please describe in detail)')
                Column(
                  children: [
                    TextField(
                      controller: _otherReasonController,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Describe your reason here...',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        filled: true,
                        fillColor: Colors.grey[850],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
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
                      color: _submissionMessage!.contains('successfully')
                          ? Colors.green
                          : Colors.red,
                      fontSize: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
