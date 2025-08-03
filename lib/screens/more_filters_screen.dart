// more_filters_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class MoreFiltersScreen extends StatefulWidget {
  final bool initialIsGlobalFilterEnabled;
  final bool initialSelectedFavorites;
  final bool initialSelectedOnline;
  final bool initialSelectedRightNow;
  // Updated for range filter
  final String? initialSelectedMinAge;
  final String? initialSelectedMaxAge;
  final List<String> initialSelectedGenders;
  final List<String> initialSelectedPositions;
  final List<String> initialSelectedPhotos;
  final List<String> initialSelectedTribes;
  final List<String> initialSelectedBodyTypes; // Updated to list
  // Updated for range filter
  final String? initialSelectedMinHeight;
  final String? initialSelectedMaxHeight;
  // Updated for range filter
  final String? initialSelectedMinWeight;
  final String? initialSelectedMaxWeight;
  final List<String> initialSelectedRelationshipStatus; // Updated to list
  final List<String> initialAcceptsNsfwPics;
  final List<String> initialSelectedLookingFor; // Updated to list
  final String? initialSelectedMeetAt;
  final bool initialHaventChattedToday;

  final List<String> ageOptions;
  final List<String> genderOptions;
  final List<Map<String, dynamic>> positionOptions;
  final List<String> photoOptions;
  final List<String> tribeOptions;
  final List<String> lookingForOptions;
  final List<String> meetAtOptions;
  final List<String> bodyTypeOptions;
  final List<String> heightOptions;
  final List<String> weightOptions;
  final List<String> relationshipStatusOptions;

  const MoreFiltersScreen({
    super.key,
    required this.initialIsGlobalFilterEnabled,
    required this.initialSelectedFavorites,
    required this.initialSelectedOnline,
    required this.initialSelectedRightNow,
    this.initialSelectedMinAge,
    this.initialSelectedMaxAge,
    required this.initialSelectedGenders,
    required this.initialSelectedPositions,
    required this.initialSelectedPhotos,
    required this.initialSelectedTribes,
    required this.initialSelectedBodyTypes, // Updated to list
    this.initialSelectedMinHeight,
    this.initialSelectedMaxHeight,
    this.initialSelectedMinWeight,
    this.initialSelectedMaxWeight,
    required this.initialSelectedRelationshipStatus, // Updated to list
    required this.initialAcceptsNsfwPics,
    required this.initialSelectedLookingFor, // Updated to list
    required this.meetAtOptions,
    required this.bodyTypeOptions,
    required this.heightOptions,
    required this.weightOptions,
    required this.relationshipStatusOptions,
    this.initialSelectedMeetAt,
    required this.initialHaventChattedToday,
    required this.lookingForOptions,
    required this.ageOptions,
    required this.genderOptions,
    required this.positionOptions,
    required this.photoOptions,
    required this.tribeOptions,
  });

  @override
  State<MoreFiltersScreen> createState() => _MoreFiltersScreenState();
}

class _MoreFiltersScreenState extends State<MoreFiltersScreen> {
  late bool _tempIsGlobalFilterEnabled;
  late bool _tempSelectedFavorites;
  late bool _tempSelectedOnline;
  late bool _tempSelectedRightNow;
  late String? _tempSelectedMinAge;
  late String? _tempSelectedMaxAge;
  late List<String> _tempSelectedGenders;
  late List<String> _tempSelectedPositions;
  late List<String> _tempSelectedPhotos;
  late List<String> _tempSelectedTribes;
  late List<String> _tempSelectedBodyTypes;
  late String? _tempSelectedMinHeight;
  late String? _tempSelectedMaxHeight;
  late String? _tempSelectedMinWeight;
  late String? _tempSelectedMaxWeight;
  late List<String> _tempSelectedRelationshipStatus; // Updated to list
  late List<String> _tempAcceptsNsfwPics;
  late List<String> _tempSelectedLookingFor; // Updated to list
  late String? _tempSelectedMeetAt;
  late bool _tempHaventChattedToday;

  late bool _isHeightFilterEnabled;
  late bool _isWeightFilterEnabled;
  late bool _isMeetAtFilterEnabled;

  bool filtersInteractable = true;

  @override
  void initState() {
    super.initState();
    _tempIsGlobalFilterEnabled = widget.initialIsGlobalFilterEnabled;
    _tempSelectedFavorites = widget.initialSelectedFavorites;
    _tempSelectedOnline = widget.initialSelectedOnline;
    _tempSelectedRightNow = widget.initialSelectedRightNow;
    _tempSelectedMinAge = widget.initialSelectedMinAge;
    _tempSelectedMaxAge = widget.initialSelectedMaxAge;
    _tempSelectedGenders = List.from(widget.initialSelectedGenders);
    _tempSelectedPositions = List.from(widget.initialSelectedPositions);
    _tempSelectedPhotos = List.from(widget.initialSelectedPhotos);
    _tempSelectedTribes = List.from(widget.initialSelectedTribes);
    _tempSelectedBodyTypes = List.from(widget.initialSelectedBodyTypes);
    _tempSelectedMinHeight = widget.initialSelectedMinHeight;
    _tempSelectedMaxHeight = widget.initialSelectedMaxHeight;
    _tempSelectedMinWeight = widget.initialSelectedMinWeight;
    _tempSelectedMaxWeight = widget.initialSelectedMaxWeight;
    _tempSelectedRelationshipStatus =
        List.from(widget.initialSelectedRelationshipStatus);
    _tempAcceptsNsfwPics = widget.initialAcceptsNsfwPics;
    _tempSelectedLookingFor =
        List.from(widget.initialSelectedLookingFor); // Updated
    _tempSelectedMeetAt = widget.initialSelectedMeetAt;
    _tempHaventChattedToday = widget.initialHaventChattedToday;

    // Initialize filter states based on initial values
    _isHeightFilterEnabled = widget.initialSelectedMinHeight != null ||
        widget.initialSelectedMaxHeight != null;
    _isWeightFilterEnabled = widget.initialSelectedMinWeight != null ||
        widget.initialSelectedMaxWeight != null;
    _isMeetAtFilterEnabled = widget.initialSelectedMeetAt != null;

    filtersInteractable = _tempIsGlobalFilterEnabled;
  }

  void _applyFilters() {
    Navigator.pop(context, {
      'isGlobalFilterEnabled': _tempIsGlobalFilterEnabled,
      'selectedFavorites': _tempSelectedFavorites,
      'selectedOnline': _tempSelectedOnline,
      'selectedRightNow': _tempSelectedRightNow,
      'selectedMinAge': _tempSelectedMinAge,
      'selectedMaxAge': _tempSelectedMaxAge,
      'selectedGenders': _tempSelectedGenders,
      'selectedPositions': _tempSelectedPositions,
      'selectedPhotos': _tempSelectedPhotos,
      'selectedTribes': _tempSelectedTribes,
      'selectedBodyTypes': _tempSelectedBodyTypes,
      'selectedMinHeight': _tempSelectedMinHeight,
      'selectedMaxHeight': _tempSelectedMaxHeight,
      'selectedMinWeight': _tempSelectedMinWeight,
      'selectedMaxWeight': _tempSelectedMaxWeight,
      'selectedRelationshipStatus': _tempSelectedRelationshipStatus,
      'acceptsNsfwPics': _tempAcceptsNsfwPics,
      'selectedLookingFor': _tempSelectedLookingFor, // Updated
      'selectedMeetAt': _tempSelectedMeetAt,
      'haventChattedToday': _tempHaventChattedToday,
    });
  }

  void _resetFilters() {
    setState(() {
      _tempIsGlobalFilterEnabled = false;
      _tempSelectedFavorites = false;
      _tempSelectedOnline = false;
      _tempSelectedRightNow = false;
      _tempSelectedMinAge = null;
      _tempSelectedMaxAge = null;
      _tempSelectedGenders.clear();
      _tempSelectedPositions.clear();
      _tempSelectedPhotos.clear();
      _tempSelectedTribes.clear();
      _tempSelectedBodyTypes.clear();
      _tempSelectedMinHeight = null;
      _tempSelectedMaxHeight = null;
      _tempSelectedMinWeight = null;
      _tempSelectedMaxWeight = null;
      _tempSelectedRelationshipStatus.clear();
      _tempAcceptsNsfwPics.clear();
      _tempSelectedLookingFor.clear(); // Updated
      _tempSelectedMeetAt = null;
      _tempHaventChattedToday = false;
      filtersInteractable = false;
      _isHeightFilterEnabled = false;
      _isWeightFilterEnabled = false;
      _isMeetAtFilterEnabled = false;
    });
  }

  Widget _buildRangeFilter({
    required String label,
    required String? minValue,
    required String? maxValue,
    required List<String> allOptions,
    required ValueChanged<String?> onMinChanged,
    required ValueChanged<String?> onMaxChanged,
    required bool isEnabled,
  }) {
    final minOptions = ['No Minimum', ...allOptions];
    final maxOptions = ['No Maximum', ...allOptions];
    int minIndex =
        minValue == 'No Minimum' ? 0 : allOptions.indexOf(minValue ?? '');
    int maxIndex = maxValue == 'No Maximum'
        ? allOptions.length - 1
        : allOptions.indexOf(maxValue ?? '');
    List<String> filteredMinOptions = minOptions;
    if (maxIndex != -1 && maxValue != 'No Maximum') {
      filteredMinOptions = [
        'No Minimum',
        ...allOptions.sublist(0, maxIndex + 1)
      ];
    }
    List<String> filteredMaxOptions = maxOptions;
    if (minIndex != -1 && minValue != 'No Minimum') {
      filteredMaxOptions = ['No Maximum', ...allOptions.sublist(minIndex)];
    }
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: IgnorePointer(
        ignoring: !isEnabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                label,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: minValue,
                        dropdownColor: Colors.grey[800],
                        style: const TextStyle(color: Colors.white),
                        icon: const Icon(Icons.arrow_drop_down,
                            color: Colors.white),
                        onChanged: onMinChanged,
                        items: filteredMinOptions
                            .map<DropdownMenuItem<String>>((String item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: maxValue,
                        dropdownColor: Colors.grey[800],
                        style: const TextStyle(color: Colors.white),
                        icon: const Icon(Icons.arrow_drop_down,
                            color: Colors.white),
                        onChanged: onMaxChanged,
                        items: filteredMaxOptions
                            .map<DropdownMenuItem<String>>((String item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }

  /// Builds a simple toggle filter with a dot indicator.
  /// This is used for simple boolean on/off options.
  Widget _buildToggleDotFilter({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
    required bool isEnabled,
  }) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: IgnorePointer(
        ignoring: !isEnabled,
        child: GestureDetector(
          onTap: () {
            onChanged(!value);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            color: Colors.transparent,
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: value ? Colors.yellow : Colors.transparent,
                    border: Border.all(
                      color: value ? Colors.yellow : Colors.white,
                      width: 2.0,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: value ? Colors.white : Colors.grey,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showHeightPicker() async {
    final List<String> minPickerOptions = widget.heightOptions;
    final List<String> maxPickerOptions = widget.heightOptions;

    int minHeightIndex = _tempSelectedMinHeight == null
        ? 0
        : minPickerOptions.indexOf(_tempSelectedMinHeight!);
    int maxHeightIndex = _tempSelectedMaxHeight == null
        ? maxPickerOptions.length - 1
        : maxPickerOptions.indexOf(_tempSelectedMaxHeight!);

    await showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: Column(
            children: [
              Container(
                color: Colors.grey[900],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: const Text('Reset',
                          style: TextStyle(color: Colors.yellow)),
                      onPressed: () {
                        setState(() {
                          _tempSelectedMinHeight = null;
                          _tempSelectedMaxHeight = null;
                          _isHeightFilterEnabled = false;
                        });
                        Navigator.pop(context);
                      },
                    ),
                    CupertinoButton(
                      child: const Text('Done',
                          style: TextStyle(color: Colors.yellow)),
                      onPressed: () {
                        setState(() {
                          String selectedMin = minPickerOptions[minHeightIndex];
                          String selectedMax = maxPickerOptions[maxHeightIndex];

                          _tempSelectedMinHeight = selectedMin;
                          _tempSelectedMaxHeight = selectedMax;
                          _isHeightFilterEnabled = true;
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoPicker(
                        backgroundColor: Colors.black,
                        itemExtent: 40,
                        scrollController: FixedExtentScrollController(
                            initialItem: minHeightIndex),
                        onSelectedItemChanged: (int index) {
                          minHeightIndex = index;
                        },
                        children: minPickerOptions.map((String item) {
                          return Center(
                            child: Text(
                              item,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 18),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        backgroundColor: Colors.black,
                        itemExtent: 40,
                        scrollController: FixedExtentScrollController(
                            initialItem: maxHeightIndex),
                        onSelectedItemChanged: (int index) {
                          maxHeightIndex = index;
                        },
                        children: maxPickerOptions.map((String item) {
                          return Center(
                            child: Text(
                              item,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 18),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showWeightPicker() async {
    final List<String> minPickerOptions = widget.weightOptions;
    final List<String> maxPickerOptions = widget.weightOptions;

    int minWeightIndex = _tempSelectedMinWeight == null
        ? 0
        : minPickerOptions.indexOf(_tempSelectedMinWeight!);
    int maxWeightIndex = _tempSelectedMaxWeight == null
        ? maxPickerOptions.length - 1
        : maxPickerOptions.indexOf(_tempSelectedMaxWeight!);

    await showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: Column(
            children: [
              Container(
                color: Colors.grey[900],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: const Text('Reset',
                          style: TextStyle(color: Colors.yellow)),
                      onPressed: () {
                        setState(() {
                          _tempSelectedMinWeight = null;
                          _tempSelectedMaxWeight = null;
                          _isWeightFilterEnabled = false;
                        });
                        Navigator.pop(context);
                      },
                    ),
                    CupertinoButton(
                      child: const Text('Done',
                          style: TextStyle(color: Colors.yellow)),
                      onPressed: () {
                        setState(() {
                          String selectedMin = minPickerOptions[minWeightIndex];
                          String selectedMax = maxPickerOptions[maxWeightIndex];

                          _tempSelectedMinWeight = selectedMin;
                          _tempSelectedMaxWeight = selectedMax;
                          _isWeightFilterEnabled = true;
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoPicker(
                        backgroundColor: Colors.black,
                        itemExtent: 40,
                        scrollController: FixedExtentScrollController(
                            initialItem: minWeightIndex),
                        onSelectedItemChanged: (int index) {
                          minWeightIndex = index;
                        },
                        children: minPickerOptions.map((String item) {
                          return Center(
                            child: Text(
                              item,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 18),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        backgroundColor: Colors.black,
                        itemExtent: 40,
                        scrollController: FixedExtentScrollController(
                            initialItem: maxWeightIndex),
                        onSelectedItemChanged: (int index) {
                          maxWeightIndex = index;
                        },
                        children: maxPickerOptions.map((String item) {
                          return Center(
                            child: Text(
                              item,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 18),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showSingleSelectPicker({
    required String title,
    required List<String> options,
    required String? selectedValue,
    required Function(String?) onSave,
  }) async {
    String? tempSelectedValue = selectedValue;
    int initialItemIndex =
        tempSelectedValue != null ? options.indexOf(tempSelectedValue) : 0;

    await showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: Column(
            children: [
              Container(
                color: Colors.grey[900],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: const Text('Reset',
                          style: TextStyle(color: Colors.yellow)),
                      onPressed: () {
                        onSave(null);
                        Navigator.pop(context);
                      },
                    ),
                    CupertinoButton(
                      child: const Text('Done',
                          style: TextStyle(color: Colors.yellow)),
                      onPressed: () {
                        onSave(tempSelectedValue);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  backgroundColor: Colors.black,
                  itemExtent: 40,
                  scrollController: FixedExtentScrollController(
                      initialItem: initialItemIndex),
                  onSelectedItemChanged: (int index) {
                    tempSelectedValue = options[index];
                  },
                  children: options.map((String item) {
                    return Center(
                      child: Text(
                        item,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showMultiSelectChipPicker({
    required String title,
    required List<String> options,
    required List<String> selectedValues,
    required Function(List<String>) onSave,
  }) async {
    List<String> tempSelectedValues = List.from(selectedValues);

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.black,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateModal) {
            return Container(
              height: 400,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          setStateModal(() {
                            tempSelectedValues.clear();
                          });
                        },
                        child: const Text('Reset',
                            style: TextStyle(color: Colors.yellow)),
                      ),
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          onSave(tempSelectedValues);
                          Navigator.pop(context);
                        },
                        child: const Text('Save',
                            style: TextStyle(color: Colors.yellow)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 2.0, // Reduced aspect ratio
                      ),
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final option = options[index];
                        final isSelected = tempSelectedValues.contains(option);
                        return ElevatedButton(
                          onPressed: () {
                            setStateModal(() {
                              if (isSelected) {
                                tempSelectedValues.remove(option);
                              } else {
                                tempSelectedValues.add(option);
                              }
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isSelected ? Colors.yellow : Colors.grey[800],
                            foregroundColor:
                                isSelected ? Colors.black : Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 6.0), // Reduced padding
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  8), // Reduced border radius
                            ),
                          ),
                          child: Text(
                            option,
                            style: const TextStyle(
                                fontSize: 12), // Reduced font size
                            softWrap: true,
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSingleSelectFilter({
    required String title,
    required String? selectedValue,
    required bool isEnabled,
    required Function() onTap,
  }) {
    String titleText = title;
    if (selectedValue != null) {
      titleText = '$title: $selectedValue';
    }

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: IgnorePointer(
        ignoring: !isEnabled,
        child: GestureDetector(
          onTap: () {
            if (selectedValue != null) {
              // This acts as a reset button
              setState(() {
                _tempSelectedMeetAt = null;
                _isMeetAtFilterEnabled = false;
              });
            } else {
              onTap();
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            color: Colors.transparent,
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selectedValue != null
                        ? Colors.yellow
                        : Colors.transparent,
                    border: Border.all(
                      color:
                          selectedValue != null ? Colors.yellow : Colors.white,
                      width: 2.0,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    titleText,
                    style: TextStyle(
                      color: selectedValue != null ? Colors.white : Colors.grey,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a multi-select filter with a dot indicator that shows selected values.
  /// Tapping the dot or text resets the filter, and tapping again brings up the picker.
  Widget _buildMultiSelectDotFilter({
    required String title,
    required List<String> selectedValues,
    required List<String> allOptions,
    required bool isEnabled,
    required Function(List<String>) onSave,
  }) {
    String titleText = title;
    if (selectedValues.isNotEmpty) {
      titleText = '$title: ${selectedValues.join(', ')}';
    }

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: IgnorePointer(
        ignoring: !isEnabled,
        child: GestureDetector(
          onTap: () {
            if (selectedValues.isNotEmpty) {
              // Reset the filter
              setState(() {
                onSave([]);
              });
            } else {
              _showMultiSelectChipPicker(
                title: title,
                options: allOptions,
                selectedValues: selectedValues,
                onSave: (List<String> newValues) {
                  setState(() {
                    onSave(newValues);
                  });
                },
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            color: Colors.transparent,
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selectedValues.isNotEmpty
                        ? Colors.yellow
                        : Colors.transparent,
                    border: Border.all(
                      color: selectedValues.isNotEmpty
                          ? Colors.yellow
                          : Colors.white,
                      width: 2.0,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    titleText,
                    style: TextStyle(
                      color: selectedValues.isNotEmpty
                          ? Colors.white
                          : Colors.grey,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeightFilter() {
    String titleText = 'Height';
    if (_isHeightFilterEnabled) {
      String minText = _tempSelectedMinHeight ?? 'No Min';
      String maxText = _tempSelectedMaxHeight ?? 'No Max';
      titleText = 'Height: $minText - $maxText';
    }
    return Opacity(
      opacity: filtersInteractable ? 1.0 : 0.5,
      child: IgnorePointer(
        ignoring: !filtersInteractable,
        child: GestureDetector(
          onTap: () {
            if (_isHeightFilterEnabled) {
              setState(() {
                _isHeightFilterEnabled = false;
                _tempSelectedMinHeight = null;
                _tempSelectedMaxHeight = null;
              });
            } else {
              _showHeightPicker();
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            color: Colors.transparent,
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isHeightFilterEnabled
                        ? Colors.yellow
                        : Colors.transparent,
                    border: Border.all(
                      color:
                          _isHeightFilterEnabled ? Colors.yellow : Colors.white,
                      width: 2.0,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  titleText,
                  style: TextStyle(
                    color: _isHeightFilterEnabled ? Colors.white : Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeightFilter() {
    String titleText = 'Weight';
    if (_isWeightFilterEnabled) {
      String minText = _tempSelectedMinWeight ?? 'No Min';
      String maxText = _tempSelectedMaxWeight ?? 'No Max';
      titleText = 'Weight: $minText - $maxText';
    }
    return Opacity(
      opacity: filtersInteractable ? 1.0 : 0.5,
      child: IgnorePointer(
        ignoring: !filtersInteractable,
        child: GestureDetector(
          onTap: () {
            if (_isWeightFilterEnabled) {
              setState(() {
                _isWeightFilterEnabled = false;
                _tempSelectedMinWeight = null;
                _tempSelectedMaxWeight = null;
              });
            } else {
              _showWeightPicker();
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            color: Colors.transparent,
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isWeightFilterEnabled
                        ? Colors.yellow
                        : Colors.transparent,
                    border: Border.all(
                      color:
                          _isWeightFilterEnabled ? Colors.yellow : Colors.white,
                      width: 2.0,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  titleText,
                  style: TextStyle(
                    color: _isWeightFilterEnabled ? Colors.white : Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMultiSelectChipFilter({
    required String title,
    required List<String> options,
    required List<String> selectedValues,
    required bool isEnabled,
  }) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: IgnorePointer(
        ignoring: !isEnabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Text(
                title,
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
              children: options.map((option) {
                final isSelected = selectedValues.contains(option);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectedValues.remove(option);
                      } else {
                        selectedValues.add(option);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 6.0), // Reduced padding
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.yellow : Colors.grey[800],
                      borderRadius:
                          BorderRadius.circular(10.0), // Reduced border radius
                      border: Border.all(
                        color: isSelected
                            ? Colors.yellow.shade700
                            : Colors.grey.shade700,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      option,
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                        fontSize: 13, // Reduced font size
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
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
        tileColor: Colors.grey[900],
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
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.yellow)),
                  ),
                  const Text(
                    'More Filters',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: _resetFilters,
                    child: const Text('Reset',
                        style: TextStyle(color: Colors.yellow)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Enable Global Filters',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Switch(
                          value: _tempIsGlobalFilterEnabled,
                          onChanged: (bool value) {
                            setState(() {
                              _tempIsGlobalFilterEnabled = value;
                              filtersInteractable = value;
                            });
                          },
                          activeColor: Colors.yellow,
                          inactiveThumbColor: Colors.grey,
                          inactiveTrackColor: Colors.grey.withOpacity(0.5),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildRadioListTile(
                      title: 'Show Favorites',
                      value: _tempSelectedFavorites,
                      onChanged: (bool? value) {
                        setState(() {
                          _tempSelectedFavorites = value ?? false;
                        });
                      },
                      isEnabled: filtersInteractable,
                    ),
                    const SizedBox(height: 16.0),
                    _buildRadioListTile(
                      title: 'Show Online',
                      value: _tempSelectedOnline,
                      onChanged: (bool? value) {
                        setState(() {
                          _tempSelectedOnline = value ?? false;
                        });
                      },
                      isEnabled: filtersInteractable,
                    ),
                    const SizedBox(height: 16.0),
                    _buildRadioListTile(
                      title: 'Show Right Now',
                      value: _tempSelectedRightNow,
                      onChanged: (bool? value) {
                        setState(() {
                          _tempSelectedRightNow = value ?? false;
                        });
                      },
                      isEnabled: filtersInteractable,
                    ),
                    const SizedBox(height: 16.0),
                    _buildRangeFilter(
                      label: 'Age Range',
                      minValue: _tempSelectedMinAge,
                      maxValue: _tempSelectedMaxAge,
                      allOptions: widget.ageOptions,
                      onMinChanged: (String? newValue) {
                        setState(() {
                          _tempSelectedMinAge = newValue;
                        });
                      },
                      onMaxChanged: (String? newValue) {
                        setState(() {
                          _tempSelectedMaxAge = newValue;
                        });
                      },
                      isEnabled: filtersInteractable,
                    ),
                    _buildMultiSelectChipFilter(
                      title: 'Genders',
                      options: widget.genderOptions,
                      selectedValues: _tempSelectedGenders,
                      isEnabled: filtersInteractable,
                    ),
                    _buildMultiSelectChipFilter(
                      title: 'Positions',
                      options: widget.positionOptions
                          .map((e) => e['text'].toString())
                          .toList(),
                      selectedValues: _tempSelectedPositions,
                      isEnabled: filtersInteractable,
                    ),
                    _buildMultiSelectChipFilter(
                      title: 'Photos',
                      options: widget.photoOptions,
                      selectedValues: _tempSelectedPhotos,
                      isEnabled: filtersInteractable,
                    ),
                    _buildMultiSelectChipFilter(
                      title: 'Tribes',
                      options: widget.tribeOptions,
                      selectedValues: _tempSelectedTribes,
                      isEnabled: filtersInteractable,
                    ),
                    _buildMultiSelectDotFilter(
                      title: 'Body Type',
                      selectedValues: _tempSelectedBodyTypes,
                      allOptions: widget.bodyTypeOptions,
                      isEnabled: filtersInteractable,
                      onSave: (newValues) {
                        setState(() {
                          _tempSelectedBodyTypes = newValues;
                        });
                      },
                    ),
                    _buildHeightFilter(),
                    _buildWeightFilter(),
                    _buildMultiSelectDotFilter(
                      title: 'Relationship Status',
                      selectedValues: _tempSelectedRelationshipStatus,
                      allOptions: widget.relationshipStatusOptions,
                      isEnabled: filtersInteractable,
                      onSave: (newValues) {
                        setState(() {
                          _tempSelectedRelationshipStatus = newValues;
                        });
                      },
                    ),
                    _buildMultiSelectDotFilter(
                      title: 'Accepts NSFW Pics',
                      selectedValues: _tempAcceptsNsfwPics,
                      allOptions: widget.initialAcceptsNsfwPics,
                      isEnabled: filtersInteractable,
                      onSave: (newValues) {
                        setState(() {
                          _tempAcceptsNsfwPics = newValues;
                        });
                      },
                    ),
                    _buildMultiSelectDotFilter(
                      title: 'Looking For',
                      selectedValues: _tempSelectedLookingFor,
                      allOptions: widget.lookingForOptions,
                      isEnabled: filtersInteractable,
                      onSave: (newValues) {
                        setState(() {
                          _tempSelectedLookingFor = newValues;
                        });
                      },
                    ),
                    _buildSingleSelectFilter(
                      title: 'Meet At',
                      selectedValue: _tempSelectedMeetAt,
                      isEnabled: filtersInteractable,
                      onTap: () => _showSingleSelectPicker(
                        title: 'Meet At',
                        options: widget.meetAtOptions,
                        selectedValue: _tempSelectedMeetAt,
                        onSave: (String? newValue) {
                          setState(() {
                            _tempSelectedMeetAt = newValue;
                            _isMeetAtFilterEnabled = newValue != null;
                          });
                        },
                      ),
                    ),
                    _buildToggleDotFilter(
                      title: 'Haven\'t Chatted Today',
                      value: _tempHaventChattedToday,
                      onChanged: (bool? value) {
                        setState(() {
                          _tempHaventChattedToday = value ?? false;
                        });
                      },
                      isEnabled: filtersInteractable,
                    ),
                    const SizedBox(height: 40),
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _applyFilters,
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
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
