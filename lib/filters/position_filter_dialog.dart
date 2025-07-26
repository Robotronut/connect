import 'package:flutter/material.dart';

/// A dialog widget for selecting a position filter.
class PositionFilterDialog extends StatefulWidget {
  // CORRECTED: Only one parameter for initial selections
  final List<String> initialSelectedPositions;
  final bool initialFilterEnabled;
  final List<Map<String, dynamic>> positionOptions;

  const PositionFilterDialog({
    super.key,
    this.initialSelectedPositions = const [], // Default to empty list
    required this.initialFilterEnabled,
    required this.positionOptions, List<String>? initialSelectedPosition,
    // REMOVED: initialSelectedPosition parameter entirely
  });

  @override
  _PositionFilterDialogState createState() => _PositionFilterDialogState();
}

class _PositionFilterDialogState extends State<PositionFilterDialog> {
  Set<String> _tempSelectedPositions = {};
  late bool _tempIsFilterEnabled;

  @override
  void initState() {
    super.initState();
    _tempIsFilterEnabled = widget.initialFilterEnabled;

    // Correctly initialize _tempSelectedPositions from widget.initialSelectedPositions
    _tempSelectedPositions.addAll(widget.initialSelectedPositions);
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
                    // If filter is turned off, clear selections
                    if (!value) {
                      _tempSelectedPositions.clear();
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
                  final isSelected = _tempSelectedPositions.contains(option['text']);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _tempSelectedPositions.remove(option['text']);
                        } else {
                          _tempSelectedPositions.add(option['text']);
                        }
                        // If selections are made, ensure filter is enabled
                        if (_tempSelectedPositions.isNotEmpty && !_tempIsFilterEnabled) {
                          _tempIsFilterEnabled = true;
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
              onPressed: () {
                Navigator.of(context).pop({
                  'selectedPosition': _tempSelectedPositions.toList(),
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