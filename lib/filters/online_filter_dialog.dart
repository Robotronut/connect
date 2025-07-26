// online_filter_dialog.dart
import 'package:flutter/material.dart';

/// A dialog widget for selecting online status filter.
class OnlineFilterDialog extends StatefulWidget {
  final bool initialShowOnlyOnline;
  final bool initialFilterEnabled;

  const OnlineFilterDialog({
    super.key,
    required this.initialShowOnlyOnline,
    required this.initialFilterEnabled,
  });

  @override
  _OnlineFilterDialogState createState() => _OnlineFilterDialogState();
}

class _OnlineFilterDialogState extends State<OnlineFilterDialog> {
  late bool _tempShowOnlyOnline;
  late bool _tempIsFilterEnabled;

  @override
  void initState() {
    super.initState();
    _tempShowOnlyOnline = widget.initialShowOnlyOnline;
    _tempIsFilterEnabled = widget.initialFilterEnabled;
  }

  @override
  Widget build(BuildContext context) {
    bool filtersInteractable = _tempIsFilterEnabled;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
        ),
      ),
      padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0 + bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _tempShowOnlyOnline = false; // Reset to show all
                    _tempIsFilterEnabled = false; // Turn off filter
                  });
                },
                child:
                    const Text('Reset', style: TextStyle(color: Colors.yellow)),
              ),
              const Text(
                'Online',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Switch(
                value: _tempIsFilterEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _tempIsFilterEnabled = value;
                  });
                },
                activeColor: Colors.yellow,
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.grey.withOpacity(0.5),
              ),
            ],
          ),
          const SizedBox(height: 20),
          AbsorbPointer(
            absorbing: !filtersInteractable,
            child: Opacity(
              opacity: filtersInteractable ? 1.0 : 0.5,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _tempShowOnlyOnline
                            ? 'Show Online Only'
                            : 'Show All Users',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      const SizedBox(width: 10),
                      Switch(
                        value: _tempShowOnlyOnline,
                        onChanged: (bool value) {
                          setState(() {
                            _tempShowOnlyOnline = value;
                          });
                        },
                        activeColor: Colors.green, // Green for online toggle
                        inactiveThumbColor:
                            Colors.red, // Red for offline/all toggle
                        inactiveTrackColor: Colors.red.withOpacity(0.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Toggle to filter for online users',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              // The onPressed is now always active, allowing the user to apply changes
              // even if the filter is currently disabled or reset.
              onPressed: () {
                Navigator.of(context).pop({
                  'showOnlyOnline': _tempShowOnlyOnline,
                  'filterEnabled': _tempIsFilterEnabled,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Apply',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
