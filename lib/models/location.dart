import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class LocationPickerScreen extends StatefulWidget {
  @override
  _LocationPickerScreenState createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  LatLng? _selectedPosition;
  late GoogleMapController _mapController;
  final Location _locationService = Location();

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    bool _serviceEnabled = await _locationService.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _locationService.requestService();
      if (!_serviceEnabled) return;
    }

    PermissionStatus _permissionGranted =
        await _locationService.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationService.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pick Location")),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(-1.286389, 36.817223), // Nairobi
          zoom: 12,
        ),
        myLocationEnabled: true,
        onMapCreated: (controller) => _mapController = controller,
        onTap: (position) {
          setState(() => _selectedPosition = position);
        },
        markers: _selectedPosition == null
            ? {}
            : {
                Marker(
                  markerId: const MarkerId('selected'),
                  position: _selectedPosition!,
                ),
              },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_selectedPosition != null) {
            Navigator.pop(context, _selectedPosition);
          }
        },
        label: const Text("Select"),
        icon: const Icon(Icons.check),
      ),
    );
  }
}
