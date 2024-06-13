import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Completer<GoogleMapController> _controller = Completer();
  LatLng? _currentPosition;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    // Request location permissions
    if (await Permission.location.request().isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });
        print('Current position: $_currentPosition');
        _fetchNearbyVeterinarians();
      } catch (e) {
        print('Error getting current position: $e');
        // Set a default location if unable to get the current position
        setState(() {
          _currentPosition =
              LatLng(40.7128, -74.0060); // New York coordinates as an example.
        });
        _fetchNearbyVeterinarians();
      }
    } else {
      // Handle permission denial
      print('Location permission denied');
    }
  }

  Future<void> _fetchNearbyVeterinarians() async {
    if (_currentPosition == null) return;

    final String apiKey = 'AIzaSyAZO6oBCJoRGufRcpyRUg9JLpoQkX-suTs';
    final url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${_currentPosition!.latitude},${_currentPosition!.longitude}&radius=1500&type=veterinary_care&key=$apiKey';
    try {
      final response = await http.get(Uri.parse(url));
      final json = jsonDecode(response.body);

      print('Response: $json');

      if (json['status'] == 'OK') {
        for (var result in json['results']) {
          final marker = Marker(
            markerId: MarkerId(result['place_id']),
            position: LatLng(result['geometry']['location']['lat'],
                result['geometry']['location']['lng']),
            infoWindow: InfoWindow(
              title: result['name'],
              snippet: result['vicinity'],
            ),
          );
          setState(() {
            _markers.add(marker);
          });
        }
        print('Markers added: ${_markers.length}');
      } else {
        print('Error fetching places: ${json['status']}');
      }
    } catch (e) {
      print('Error fetching nearby veterinarians: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Veterinarios Cercanos'),
      ),
      body: _currentPosition == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: _currentPosition!,
                zoom: 14,
              ),
              markers: _markers,
              onMapCreated: (GoogleMapController controller) {
                try {
                  _controller.complete(controller);
                } catch (e) {
                  print('Error creating GoogleMapController: $e');
                }
              },
            ),
    );
  }
}
