import 'package:flutter/material.dart';
import 'dart:math'; // For generating random coordinates

// This screen simulates a map interface for location selection.
// In a real Flutter app, you would use a package like google_maps_flutter
// or flutter_map here to display an actual interactive map.
class LocationPickerScreen extends StatefulWidget {
  final Map<String, double>? initialLocation; // { 'latitude': ..., 'longitude': ... }

  const LocationPickerScreen({super.key, this.initialLocation});

  @override
  _LocationPickerScreenState createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  Map<String, double>? _tempSelectedLocation;
  String _displayLocationText = 'No location selected';
  // Removed _selectedMapProvider as it's not directly shown in the reference image's UI
  // and the focus is on the location setting interaction.

  @override
  void initState() {
    super.initState();
    _tempSelectedLocation = widget.initialLocation;
    _updateDisplayLocationText();
  }

  // Helper to update the displayed text based on selected location
  void _updateDisplayLocationText() {
    if (_tempSelectedLocation != null) {
      _displayLocationText =
      'Lat: ${_tempSelectedLocation!['latitude']!.toStringAsFixed(4)}, Lon: ${_tempSelectedLocation!['longitude']!.toStringAsFixed(4)}';
    } else {
      _displayLocationText = 'Current Location'; // Default text for the search bar
    }
  }

  // Simulates getting current GPS location
  void _selectCurrentLocation() {
    setState(() {
      _tempSelectedLocation = {
        'latitude': 40.7128, // Mock New York City
        'longitude': -74.0060,
      };
      _updateDisplayLocationText();
    });
  }

  // Simulates selecting a random location on the map (for demonstration)
  void _selectRandomLocation() {
    final random = Random();
    setState(() {
      _tempSelectedLocation = {
        'latitude': -90.0 + random.nextDouble() * 180.0, // -90 to +90
        'longitude': -180.0 + random.nextDouble() * 360.0, // -180 to +180
      };
      _updateDisplayLocationText();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Allows body to extend behind the app bar
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparent app bar
        elevation: 0, // No shadow
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context); // Close the screen
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5), // Semi-transparent black background
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Simulated Map Area (takes full screen)
          Container(
            color: const Color(0xFF2A5255), // Dark greenish-blue background from image
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Placeholder for map content / selected location marker
                  if (_tempSelectedLocation != null)
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.yellow,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blue, width: 2),
                      ),
                    ),
                  const SizedBox(height: 10),
                  // Removed text displaying lat/lon explicitly here,
                  // as it's not prominent in the image.
                  // The search bar will show "Current Location" or a selected city name.
                ],
              ),
            ),
          ),
          // Bottom UI elements
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8), // Semi-transparent black background
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // Current Location Button (Gear Icon)
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.settings, color: Colors.white), // Using settings as a placeholder for gear icon
                          onPressed: _selectCurrentLocation,
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Search Bar (TextField)
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            // In a real app, this would open a search overlay
                            // For now, it will trigger a random location selection
                            _selectRandomLocation();
                          },
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                const Icon(Icons.search, color: Colors.grey),
                                const SizedBox(width: 8.0),
                                Text(
                                  _displayLocationText, // Display "Current Location" or selected coordinates
                                  style: const TextStyle(color: Colors.white, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  // View Profiles Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Return the selected location when "View Profiles" is pressed
                        Navigator.of(context).pop(_tempSelectedLocation);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'View Profiles',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10), // Padding for bottom safe area
                  // Apple Maps / Legal text (simulated)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        // In a real app, this would open a legal/about page for map provider
                      },
                      child: const Text(
                        ' Maps Legal',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
