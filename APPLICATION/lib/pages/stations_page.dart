import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class StationsPage extends StatefulWidget {
  const StationsPage({Key? key}) : super(key: key);

  @override
  _StationsPageState createState() => _StationsPageState();
}

class _StationsPageState extends State<StationsPage> {
  GoogleMapController? mapController;
  LocationData? currentLocation;
  final Location location = Location();
  bool _permission = false;

  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    checkPermission();
    setMarkers();
    _waitForLocation();
  }

  void _waitForLocation() async {
    await Future.delayed(const Duration(seconds: 2)); // Várunk 2 másodpercet
    getLocation();
  }

  void checkPermission() async {
    final hasPermission = await location.serviceEnabled();
    if (!hasPermission) {
      _permission = await location.requestService();
      if (!_permission) {
        return;
      }
    }
    getLocation();
  }

  void getLocation() async {
    try {
      LocationData locData = (await location.getLocation());
      setState(() {
        currentLocation = locData;
        mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(locData.latitude!, locData.longitude!),
            15.0,
          ),
        );
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  void setMarkers() {
    markers.add(
      const Marker(
        markerId: MarkerId('Marker1'),
        position: LatLng(37.7749, -122.4194),
        infoWindow: InfoWindow(title: 'Marker 1'),
      ),
    );
    markers.add(
      const Marker(
        markerId: MarkerId('Marker2'),
        position: LatLng(37.3382, -121.8863),
        infoWindow: InfoWindow(title: 'Marker 2'),
      ),
    );
    // Add more markers as needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stations'),
      ),
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          setState(() {
            mapController = controller;
          });
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(currentLocation?.latitude ?? 0.0,
              currentLocation?.longitude ?? 0.0),
          zoom: 15.0,
        ),
        markers: markers,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          checkPermission();
        },
        child: const Icon(Icons.location_searching),
      ),
    );
  }
}
