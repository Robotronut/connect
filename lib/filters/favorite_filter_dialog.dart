// favorite_filter_dialog.dart
import 'package:flutter/material.dart';

class FavoriteFilterDialog extends StatefulWidget {
  final bool initialShowOnlyFavorites;
  final bool initialFilterEnabled;

  const FavoriteFilterDialog({
    super.key,
    required this.initialShowOnlyFavorites,
    required this.initialFilterEnabled,
  });

  @override
  _FavoriteFilterDialogState createState() => _FavoriteFilterDialogState();
}

class _FavoriteFilterDialogState extends State<FavoriteFilterDialog> {
  late bool _tempShowOnlyFavorites;
  late bool _tempIsFilterEnabled;

  @override
  void initState() {
    super.initState();
    _tempShowOnlyFavorites = widget.initialShowOnlyFavorites;
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
                    _tempShowOnlyFavorites = false; // Reset filter
                    _tempIsFilterEnabled = false;
                  });
                },
                child: const Text('Reset', style: TextStyle(color: Colors.yellow)),
              ),
              const Text(
                'Favorites',
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
                        _tempShowOnlyFavorites ? 'Show Favorite Users Only' : 'Show All Users',
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      const SizedBox(width: 10),
                      Switch(
                        value: _tempShowOnlyFavorites,
                        onChanged: (bool value) {
                          setState(() {
                            _tempShowOnlyFavorites = value;
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
                    'Toggle to filter for favorite users',
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
                  'showOnlyFavorites': _tempShowOnlyFavorites,
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