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

  @override
  void initState() {
    super.initState();
    _tempIsFreshEnabled = widget.initialIsFreshEnabled;
  }

  @override
  Widget build(BuildContext context) {
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
                    _tempIsFreshEnabled = false; // Reset filter
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
                        _tempIsFreshEnabled ? 'Show Fresh Users Only' : 'Show All Users',
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      const SizedBox(width: 10),
                      Switch(
                        value: _tempIsFreshEnabled,
                        onChanged: (bool value) {
                          setState(() {
                            _tempIsFreshEnabled = value;
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
              onPressed: filtersInteractable
                  ? () {
                Navigator.of(context).pop({
                  'isFreshEnabled': _tempIsFreshEnabled,
                });
              }
                  : null,
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