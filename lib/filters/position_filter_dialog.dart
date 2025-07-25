// position_filter_dialog.dart
import 'package:flutter/material.dart';

/// A dialog widget for selecting a position filter.
class PositionFilterDialog extends StatefulWidget {
  // Changed to a List<String> to support multiple initial selections
  final List<String> initialSelectedPositions;
  final bool initialFilterEnabled;
  final List<Map<String, dynamic>> positionOptions;

  const PositionFilterDialog({
    super.key,
    // Updated parameter name and type
    this.initialSelectedPositions = const [], // Default to empty list if not provided
    required this.initialFilterEnabled,
    required this.positionOptions,
  });

  @override
  _PositionFilterDialogState createState() => _PositionFilterDialogState();
}

class _PositionFilterDialogState extends State<PositionFilterDialog> {
  Set<String> _tempSelectedPositions = {}; // Changed to a Set for multiple selections
  late bool _tempIsFilterEnabled;

  @override
  void initState() {
    super.initState();
    _tempIsFilterEnabled = widget.initialFilterEnabled;

    // Initialize _tempSelectedPositions from the provided list
    _tempSelectedPositions.addAll(widget.initialSelectedPositions);
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
                    _tempSelectedPositions.clear(); // Clear all selections
                    _tempIsFilterEnabled = false; // Turn off filter
                  });
                },
                child: const Text('Reset', style: TextStyle(color: Colors.yellow)),
              ),
              const Text(
                'Position',
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
                    // Optionally, if the filter is turned off, clear selections
                    // or disable the selection interaction. For now, the AbsorbPointer
                    // handles disabling interaction.
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
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.5,
                ),
                itemCount: widget.positionOptions.length,
                itemBuilder: (context, index) {
                  final option = widget.positionOptions[index];
                  // Check if the current option is in the set of selected positions
                  final isSelected = _tempSelectedPositions.contains(option['text']);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _tempSelectedPositions.remove(option['text']); // Deselect
                        } else {
                          _tempSelectedPositions.add(option['text']); // Select
                        }
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.yellow : Colors.grey[800],
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: isSelected ? Colors.yellow.shade700 : Colors.grey.shade700,
                          width: 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                          BoxShadow(
                            color: Colors.yellow.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ]
                            : [],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            option['icon'],
                            color: isSelected ? Colors.black : Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            option['text'],
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              // The onPressed is always active, allowing the user to apply changes
              // even if the filter is currently disabled or reset.
              onPressed: () {
                Navigator.of(context).pop({
                  'selectedPositions': _tempSelectedPositions.toList(), // Return as a List
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
