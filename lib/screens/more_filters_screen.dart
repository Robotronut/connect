// more_filters_screen.dart
import 'package:flutter/material.dart';

class MoreFiltersScreen extends StatefulWidget {
  final bool initialIsGlobalFilterEnabled;
  final bool initialSelectedFavorites;
  final bool initialSelectedOnline;
  final bool initialSelectedRightNow;
  final String? initialSelectedMinAge;
  final List<String> initialSelectedGenders;
  final List<String> initialSelectedPositions;
  final List<String> initialSelectedPhotos;
  final List<String> initialSelectedTribes;
  final String? initialSelectedBodyType;
  final String? initialSelectedHeight;
  final String? initialSelectedWeight;
  final String? initialSelectedRelationshipStatus;
  final bool initialAcceptsNsfwPics;
  final String? initialSelectedLookingFor;
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
    required this.initialSelectedGenders,
    required this.initialSelectedPositions,
    required this.initialSelectedPhotos,
    required this.initialSelectedTribes,
    this.initialSelectedBodyType,
    this.initialSelectedHeight,
    this.initialSelectedWeight,
    this.initialSelectedRelationshipStatus,
    required this.initialAcceptsNsfwPics,
    this.initialSelectedLookingFor,
    this.initialSelectedMeetAt,
    required this.initialHaventChattedToday,
    required this.ageOptions,
    required this.genderOptions,
    required this.positionOptions,
    required this.photoOptions,
    required this.tribeOptions,
    required this.lookingForOptions,
    required this.meetAtOptions,
    required this.bodyTypeOptions,
    required this.heightOptions,
    required this.weightOptions,
    required this.relationshipStatusOptions,
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
  late List<String> _tempSelectedGenders;
  late List<String> _tempSelectedPositions;
  late List<String> _tempSelectedPhotos;
  late List<String> _tempSelectedTribes;
  late String? _tempSelectedBodyType;
  late String? _tempSelectedHeight;
  late String? _tempSelectedWeight;
  late String? _tempSelectedRelationshipStatus;
  late bool _tempAcceptsNsfwPics;
  late String? _tempSelectedLookingFor;
  late String? _tempSelectedMeetAt;
  late bool _tempHaventChattedToday;

  bool filtersInteractable = true;

  @override
  void initState() {
    super.initState();
    _tempIsGlobalFilterEnabled = widget.initialIsGlobalFilterEnabled;
    _tempSelectedFavorites = widget.initialSelectedFavorites;
    _tempSelectedOnline = widget.initialSelectedOnline;
    _tempSelectedRightNow = widget.initialSelectedRightNow;
    _tempSelectedMinAge = widget.initialSelectedMinAge;
    _tempSelectedGenders = List.from(widget.initialSelectedGenders);
    _tempSelectedPositions = List.from(widget.initialSelectedPositions);
    _tempSelectedPhotos = List.from(widget.initialSelectedPhotos);
    _tempSelectedTribes = List.from(widget.initialSelectedTribes);
    _tempSelectedBodyType = widget.initialSelectedBodyType;
    _tempSelectedHeight = widget.initialSelectedHeight;
    _tempSelectedWeight = widget.initialSelectedWeight;
    _tempSelectedRelationshipStatus = widget.initialSelectedRelationshipStatus;
    _tempAcceptsNsfwPics = widget.initialAcceptsNsfwPics;
    _tempSelectedLookingFor = widget.initialSelectedLookingFor;
    _tempSelectedMeetAt = widget.initialSelectedMeetAt;
    _tempHaventChattedToday = widget.initialHaventChattedToday;

    filtersInteractable = _tempIsGlobalFilterEnabled;
  }

  void _applyFilters() {
    Navigator.pop(context, {
      'isGlobalFilterEnabled': _tempIsGlobalFilterEnabled,
      'selectedFavorites': _tempSelectedFavorites,
      'selectedOnline': _tempSelectedOnline,
      'selectedRightNow': _tempSelectedRightNow,
      'selectedMinAge': _tempSelectedMinAge,
      'selectedGenders': _tempSelectedGenders,
      'selectedPositions': _tempSelectedPositions,
      'selectedPhotos': _tempSelectedPhotos,
      'selectedTribes': _tempSelectedTribes,
      'selectedBodyType': _tempSelectedBodyType,
      'selectedHeight': _tempSelectedHeight,
      'selectedWeight': _tempSelectedWeight,
      'selectedRelationshipStatus': _tempSelectedRelationshipStatus,
      'acceptsNsfwPics': _tempAcceptsNsfwPics,
      'selectedLookingFor': _tempSelectedLookingFor,
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
      _tempSelectedGenders.clear();
      _tempSelectedPositions.clear();
      _tempSelectedPhotos.clear();
      _tempSelectedTribes.clear();
      _tempSelectedBodyType = null;
      _tempSelectedHeight = null;
      _tempSelectedWeight = null;
      _tempSelectedRelationshipStatus = null;
      _tempAcceptsNsfwPics = false;
      _tempSelectedLookingFor = null;
      _tempSelectedMeetAt = null;
      _tempHaventChattedToday = false;
      filtersInteractable = false;
    });
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
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
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                label,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<T>(
                  isExpanded: true,
                  value: value,
                  dropdownColor: Colors.grey[800],
                  style: const TextStyle(color: Colors.white),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  onChanged: onChanged,
                  items: items.map<DropdownMenuItem<T>>((T item) {
                    return DropdownMenuItem<T>(
                      value: item,
                      child: Text(item.toString()),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
          ],
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
                      option,
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                        fontSize: 14,
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
        title: const Text('More Filters', style: TextStyle(color: Colors.white)),
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
            child: const Text('Reset All', style: TextStyle(color: Colors.yellow)),
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
            // Individual Filter Options (controlled by filtersInteractable)
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
            _buildDropdown<String>(
              label: 'Minimum Age',
              value: _tempSelectedMinAge,
              items: widget.ageOptions,
              onChanged: (String? newValue) {
                setState(() {
                  _tempSelectedMinAge = newValue;
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
              options: widget.positionOptions.map((e) => e['text'].toString()).toList(),
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
            _buildDropdown<String>(
              label: 'Body Type',
              value: _tempSelectedBodyType,
              items: widget.bodyTypeOptions,
              onChanged: (String? newValue) {
                setState(() {
                  _tempSelectedBodyType = newValue;
                });
              },
              isEnabled: filtersInteractable,
            ),
            _buildDropdown<String>(
              label: 'Height',
              value: _tempSelectedHeight,
              items: widget.heightOptions,
              onChanged: (String? newValue) {
                setState(() {
                  _tempSelectedHeight = newValue;
                });
              },
              isEnabled: filtersInteractable,
            ),
            _buildDropdown<String>(
              label: 'Weight',
              value: _tempSelectedWeight,
              items: widget.weightOptions,
              onChanged: (String? newValue) {
                setState(() {
                  _tempSelectedWeight = newValue;
                });
              },
              isEnabled: filtersInteractable,
            ),
            _buildDropdown<String>(
              label: 'Relationship Status',
              value: _tempSelectedRelationshipStatus,
              items: widget.relationshipStatusOptions,
              onChanged: (String? newValue) {
                setState(() {
                  _tempSelectedRelationshipStatus = newValue;
                });
              },
              isEnabled: filtersInteractable,
            ),
            _buildRadioListTile(
              title: 'Accepts NSFW Pics',
              value: _tempAcceptsNsfwPics,
              onChanged: (bool? value) {
                setState(() {
                  _tempAcceptsNsfwPics = value ?? false;
                });
              },
              isEnabled: filtersInteractable,
            ),
            const SizedBox(height: 16.0),
            _buildDropdown<String>(
              label: 'Looking For',
              value: _tempSelectedLookingFor,
              items: widget.lookingForOptions,
              onChanged: (String? newValue) {
                setState(() {
                  _tempSelectedLookingFor = newValue;
                });
              },
              isEnabled: filtersInteractable,
            ),
            _buildDropdown<String>(
              label: 'Meet At',
              value: _tempSelectedMeetAt,
              items: widget.meetAtOptions,
              onChanged: (String? newValue) {
                setState(() {
                  _tempSelectedMeetAt = newValue;
                });
              },
              isEnabled: filtersInteractable,
            ),
            _buildRadioListTile(
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
                  onPressed: filtersInteractable ? _applyFilters : null,
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