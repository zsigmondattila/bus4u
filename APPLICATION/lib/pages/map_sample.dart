import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  GoogleMapController? mapController;
  LocationData? currentLocation;
  Location location = Location();
  @override
  void initState() {
    super.initState();
    getLocation();
  }

  void getLocation() async {
    try {
      var currentLocation = await location.getLocation();
      setState(() {
        currentLocation = currentLocation;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Location'),
      ),
      body: Column(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(currentLocation?.latitude ?? 0.0,
                  currentLocation?.longitude ?? 0.0),
              zoom: 15,
            ),
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
            markers: <Marker>{
              Marker(
                markerId: const MarkerId('My Location'),
                position: LatLng(currentLocation?.latitude ?? 0.0,
                    currentLocation?.longitude ?? 0.0),
                infoWindow: const InfoWindow(title: 'My Location'),
              ),
              Marker(
                markerId: const MarkerId("marker1"),
                position: const LatLng(37.422131, -122.084801),
                draggable: true,
                onDragEnd: (value) {
                  // value is the new position
                },
                // To do: custom marker icon
              ),
              const Marker(
                markerId: MarkerId("marker2"),
                position: LatLng(37.415768808487435, -122.08440050482749),
              ),
            },
          ),
        ],
      ),
    );
  }
}
