// age_filter_dialog.dart
import 'package:flutter/material.dart';

/// A dialog widget for selecting an age range filter.
class AgeFilterDialog extends StatefulWidget {
  final RangeValues initialAgeRange;
  final bool initialFilterEnabled;

  const AgeFilterDialog({
    super.key,
    required this.initialAgeRange,
    required this.initialFilterEnabled,
  });

  @override
  _AgeFilterDialogState createState() => _AgeFilterDialogState();
}

class _AgeFilterDialogState extends State<AgeFilterDialog> {
  late RangeValues _tempAgeRange;
  late bool _tempIsFilterEnabled;

  @override
  void initState() {
    super.initState();
    _tempAgeRange = widget.initialAgeRange;
    _tempIsFilterEnabled = widget.initialFilterEnabled;
  }

  @override
  Widget build(BuildContext context) {
    bool filtersInteractable = _tempIsFilterEnabled;

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
                    _tempAgeRange = const RangeValues(18, 99); // Reset to default
                    _tempIsFilterEnabled = false; // Turn off filter
                  });
                },
                child: const Text('Reset', style: TextStyle(color: Colors.yellow)),
              ),
              const Text(
                'Age',
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
                  Text(
                    '${_tempAgeRange.start.round()} - ${_tempAgeRange.end.round()}',
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  RangeSlider(
                    values: _tempAgeRange,
                    min: 18,
                    max: 99,
                    divisions: 81, // (99 - 18)
                    labels: RangeLabels(
                      _tempAgeRange.start.round().toString(),
                      _tempAgeRange.end.round().toString(),
                    ),
                    activeColor: Colors.yellow,
                    inactiveColor: Colors.grey.withOpacity(0.7),
                    onChanged: (RangeValues newValues) {
                      setState(() {
                        _tempAgeRange = newValues;
                      });
                    },
                  ),
                  const Text(
                    'Drag to adjust range',
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
                  'selectedAgeRange': _tempAgeRange,
                  'filterEnabled': _tempIsFilterEnabled,
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