// lib/screens/select_tags_screen.dart
import 'package:flutter/material.dart';

/// A screen for selecting multiple tags from predefined categories.
/// It enforces a maximum number of selections.
class SelectTagsScreen extends StatefulWidget {
  final List<String> initialSelectedTags;
  final Map<String, List<String>> allTagOptions;
  final int maxSelections;

  const SelectTagsScreen({
    super.key,
    required this.initialSelectedTags,
    required this.allTagOptions,
    required this.maxSelections,
  });

  @override
  _SelectTagsScreenState createState() => _SelectTagsScreenState();
}

class _SelectTagsScreenState extends State<SelectTagsScreen> {
  late List<String> _tempSelectedTags;
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  final Map<String, bool> _expandedSections = {}; // To manage section expansion

  // Number of tags to show initially per section
  static const int _initialTagsToShow = 5;

  @override
  void initState() {
    super.initState();
    _tempSelectedTags = List.from(widget.initialSelectedTags);
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase();
      });
    });

    // Initialize all sections as not expanded
    widget.allTagOptions.keys.forEach((category) {
      _expandedSections[category] = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Handles the "Apply" button press, returning the selected tags.
  void _applySelection() {
    Navigator.pop(context, {'selectedTags': _tempSelectedTags});
  }

  /// Filters tags based on the search text.
  List<String> _getFilteredTags(List<String> tags) {
    if (_searchText.isEmpty) {
      return tags;
    }
    return tags.where((tag) => tag.toLowerCase().contains(_searchText)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Tags', style: TextStyle(color: Colors.yellow)),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Pop without applying changes if back button is pressed
            Navigator.pop(context);
          },
        ),
        actions: [
          // Display current selection count in the AppBar
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                '${_tempSelectedTags.length}/${widget.maxSelections}',
                style: const TextStyle(
                  color: Colors.yellow,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search tags...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.yellow),
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.allTagOptions.entries.map((entry) {
                  final category = entry.key;
                  final allTagsInCategory = entry.value;
                  final filteredTags = _getFilteredTags(allTagsInCategory);

                  // If search text is not empty and no tags match, hide the section
                  if (_searchText.isNotEmpty && filteredTags.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  // Determine which tags to display
                  final bool isExpanded = _expandedSections[category] ?? false;
                  final List<String> displayedTags = isExpanded || filteredTags.length <= _initialTagsToShow
                      ? filteredTags
                      : filteredTags.take(_initialTagsToShow).toList();

                  final int remainingTagsCount = filteredTags.length - displayedTags.length;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Text(
                          category, // Category title (e.g., "Interests")
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
                        children: displayedTags.map((tag) {
                          final isSelected = _tempSelectedTags.contains(tag);
                          // Determine if the tag can be selected based on maxSelections
                          final bool canSelect = isSelected ||
                              (_tempSelectedTags.length < widget.maxSelections);

                          return GestureDetector(
                            onTap: canSelect
                                ? () {
                              setState(() {
                                if (isSelected) {
                                  _tempSelectedTags.remove(tag);
                                } else {
                                  _tempSelectedTags.add(tag);
                                }
                              });
                            }
                                : null, // Disable onTap if cannot select
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
                              child: Opacity( // Apply opacity based on canSelect
                                opacity: canSelect ? 1.0 : 0.5,
                                child: Text(
                                  tag,
                                  style: TextStyle(
                                    color: isSelected ? Colors.black : Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      if (remainingTagsCount > 0 || isExpanded) // Show button if there are more tags or if expanded
                        Center( // Centered the TextButton
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _expandedSections[category] = !isExpanded;
                              });
                            },
                            child: Text(
                              isExpanded ? '- Show Less' : '+ $remainingTagsCount more', // Added hyphen
                              style: const TextStyle(color: Colors.yellow),
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Apply Button (moved to the bottom to be always visible)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applySelection, // Call the apply method
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
    );
  }
}
