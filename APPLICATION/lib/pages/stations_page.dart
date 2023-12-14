import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class StationsPage extends StatefulWidget {
  const StationsPage({Key? key}) : super(key: key);

  @override
  StationsPageState createState() => StationsPageState();
}

class StationsPageState extends State<StationsPage> {
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
        markerId: MarkerId('Sapi parkolo'),
        position: LatLng(46.5234, 24.5984),
        infoWindow: InfoWindow(title: 'Sapi parkolo'),
      ),
    );
    // a tobbi marker
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
        markers: <Marker>{
              Marker(
                markerId: const MarkerId('My Location'),
                position: LatLng(currentLocation?.latitude ?? 0.0,
                    currentLocation?.longitude ?? 0.0),
                infoWindow: const InfoWindow(title: 'My Location'),
              ),
            },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          checkPermission();
        },
        child: const Icon(Icons.my_location),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
