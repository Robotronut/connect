// fresh_filter_dialog.dart
import 'package:flutter/material.dart';

class FreshFilterDialog extends StatefulWidget {
  final bool initialIsFreshEnabled;

  const FreshFilterDialog({
    super.key,
    required this.initialIsFreshEnabled,
  });

  @override
  _FreshFilterDialogState createState() => _FreshFilterDialogState();
}

class _FreshFilterDialogState extends State<FreshFilterDialog> {
  late bool _tempIsFreshEnabled;
  late bool _tempShowFreshUsersOnly; // New state variable for the inner toggle

  @override
  void initState() {
    super.initState();
    _tempIsFreshEnabled = widget.initialIsFreshEnabled;
    // Initialize the inner toggle's state based on the initial filter state
    // or set a default if it should be truly independent from the start.
    // For now, it will mirror the initialIsFreshEnabled state.
    _tempShowFreshUsersOnly = widget.initialIsFreshEnabled;
  }

  @override
  Widget build(BuildContext context) {
    // This variable controls the opacity and absorbency of the inner filter section.
    // It should still be based on the main filter's enabled state.
    bool filtersInteractable = _tempIsFreshEnabled;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _tempIsFreshEnabled = false; // Reset main filter toggle
                    _tempShowFreshUsersOnly = false; // Reset inner toggle as well
                  });
                },
                child: const Text('Reset', style: TextStyle(color: Colors.yellow)),
              ),
              const Text(
                'Fresh',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Switch(
                value: _tempIsFreshEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _tempIsFreshEnabled = value;
                    // When the main filter is turned off, also turn off the inner filter
                    if (!value) {
                      _tempShowFreshUsersOnly = false;
                    }
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
                        // This text now depends on the new _tempShowFreshUsersOnly state
                        _tempShowFreshUsersOnly ? 'Show Fresh Users Only' : 'Show All Users',
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      const SizedBox(width: 10),
                      Switch(
                        // This switch now controls _tempShowFreshUsersOnly
                        value: _tempShowFreshUsersOnly,
                        onChanged: (bool value) {
                          setState(() {
                            _tempShowFreshUsersOnly = value;
                          });
                        },
                        activeColor: Colors.green,
                        inactiveThumbColor: Colors.red,
                        inactiveTrackColor: Colors.red.withOpacity(0.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Toggle to filter for fresh users',
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
              onPressed: () {
                Navigator.of(context).pop({
                  'isFreshEnabled': _tempIsFreshEnabled,
                  'showFreshUsersOnly': _tempShowFreshUsersOnly, // Return the new state
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
