import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class DoctorMapScreen extends StatefulWidget {
  final List<Map<String, dynamic>> doctors;

  const DoctorMapScreen({super.key, required this.doctors});

  @override
  State<DoctorMapScreen> createState() => _DoctorMapScreenState();
}

class _DoctorMapScreenState extends State<DoctorMapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  CameraPosition _initialPosition = const CameraPosition(
    target: LatLng(37.7749, -122.4194), // Default position (San Francisco)
    zoom: 12,
  );
  bool _isLoading = true;
  String _locationError = '';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _addDoctorMarkers();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final GoogleMapController controller = await _controller.future;
      final CameraPosition newPosition = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 14,
      );

      setState(() {
        _initialPosition = newPosition;
        _isLoading = false;
      });

      controller.animateCamera(CameraUpdate.newCameraPosition(newPosition));

      // Add marker for current location
      setState(() {
        _markers.add(
          Marker(
            markerId: const MarkerId('currentLocation'),
            position: LatLng(position.latitude, position.longitude),
            infoWindow: const InfoWindow(title: 'Your Location'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
          ),
        );
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _locationError = e.toString();
      });
    }
  }

  void _addDoctorMarkers() {
    // In a real app, these would be actual coordinates from your backend
    // For demo purposes, we'll generate some nearby locations
    final random = DateTime.now().millisecondsSinceEpoch % 100 / 10000;

    for (int i = 0; i < widget.doctors.length; i++) {
      final doctor = widget.doctors[i];
      final double lat = _initialPosition.target.latitude + (i * random * 0.01);
      final double lng =
          _initialPosition.target.longitude + (i * random * 0.015);

      _markers.add(
        Marker(
          markerId: MarkerId('doctor_$i'),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(
            title: doctor['name'],
            snippet: '${doctor['specialty']} • ${doctor['distance']} km away',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctors Near You'),
        backgroundColor: Colors.teal,
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _locationError.isNotEmpty
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.location_off,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Location Error',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(_locationError, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _getCurrentLocation,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              )
              : GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: _initialPosition,
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: true,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
              ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        child: const Icon(Icons.my_location),
        onPressed: () async {
          _getCurrentLocation();
        },
      ),
    );
  }
}
