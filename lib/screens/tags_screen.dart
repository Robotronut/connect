// tags_screen.dart
import 'package:flutter/material.dart';

class TagsScreen extends StatefulWidget {
  final List<String> initialSelectedTags;
  final Map<String, List<String>> allTagOptions;
  final bool initialIsFilterEnabled;

  const TagsScreen({
    super.key,
    required this.initialSelectedTags,
    required this.allTagOptions,
    required this.initialIsFilterEnabled,
  });

  @override
  _TagsScreenState createState() => _TagsScreenState();
}

class _TagsScreenState extends State<TagsScreen> {
  late List<String> _tempSelectedTags;
  late bool _tempIsFilterEnabled;
  bool _filtersInteractable = true; // State to control interactivity of filters

  @override
  void initState() {
    super.initState();
    _tempSelectedTags = List.from(widget.initialSelectedTags);
    _tempIsFilterEnabled = widget.initialIsFilterEnabled;
    _filtersInteractable = _tempIsFilterEnabled; // Initialize based on filter state
  }

  void _applyFilters() {
    Navigator.pop(context, {
      'selectedTags': _tempSelectedTags,
      'filterEnabled': _tempIsFilterEnabled,
    });
  }

  void _resetFilters() {
    setState(() {
      _tempSelectedTags.clear();
      _tempIsFilterEnabled = false;
      _filtersInteractable = false; // Disable filters on reset
    });
  }

  Widget _buildRadioListTile({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
    required bool isEnabled,
  }) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: RadioListTile<bool>(
        title: Text(
          title,
          style: TextStyle(
            color: isEnabled ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        value: true,
        groupValue: value,
        onChanged: isEnabled ? onChanged : null,
        activeColor: Colors.yellow,
        tileColor: Colors.grey[900], // Background color for the tile
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isEnabled ? Colors.grey.shade700 : Colors.grey.shade900,
            width: 1,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tags Filter', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: _resetFilters,
            child: const Text('Reset', style: TextStyle(color: Colors.yellow)),
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Enable Tags Filter',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Switch(
                  value: _tempIsFilterEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      _tempIsFilterEnabled = value;
                      _filtersInteractable = value; // Update interactivity based on switch
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
              absorbing: !_filtersInteractable,
              child: Opacity(
                opacity: _filtersInteractable ? 1.0 : 0.5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.allTagOptions.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: entry.value.map((tag) {
                            final isSelected = _tempSelectedTags.contains(tag);
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _tempSelectedTags.remove(tag);
                                  } else {
                                    _tempSelectedTags.add(tag);
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.yellow : Colors.grey[800],
                                  borderRadius: BorderRadius.circular(20.0),
                                  border: Border.all(
                                    color: isSelected ? Colors.yellow.shade700 : Colors.grey.shade700,
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  tag,
                                  style: TextStyle(
                                    color: isSelected ? Colors.black : Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _filtersInteractable ? _applyFilters : null,
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
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}