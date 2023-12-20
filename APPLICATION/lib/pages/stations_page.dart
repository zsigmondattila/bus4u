import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class StationsPage extends StatefulWidget {
  const StationsPage({Key? key}) : super(key: key);

  @override
  _StationsPageState createState() => _StationsPageState();
}

class _StationsPageState extends State<StationsPage> {
  GoogleMapController? mapController;
  List<Marker> markers = [];
  LocationData? currentLocation;
  final Location location = Location();
  bool _permission = false;
  String? selectedCity; // A kiválasztott város neve

  List<Map<String, String>> cities = []; // Városok listája

  @override
void initState() {
  super.initState();
  checkPermission();
  getCities(); // Városok lekérése
  getStations(); // Helyzet lekérése
}


void getLocation() async {
  try {
    LocationData locData = (await location.getLocation());
    setState(() {
      currentLocation = locData;
      _addCurrentLocationMarker(); // Az aktuális helyzet hozzáadása markerként
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(locData.latitude!, locData.longitude!),
          15.0,
        ),
      );
    });
  } catch (e) {
    print("Error getting location: $e");
  }
}


  void checkPermission() async {
    final hasPermission = await location.serviceEnabled();
    if (!hasPermission) {
      _permission = await location.requestService();
      if (_permission) {
        getLocation();
      }
    } else {
      getLocation();
    }
  }

  void getCities() async {
    try {
      final response = await http.get(Uri.parse('https://bus4u.fast-table.com/v1/get_cities'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('cities')) {
          final List<dynamic> citiesData = data['cities'];
          List<Map<String, String>> cityNames = [];
          for (var city in citiesData) {
            cityNames.add({
              'name': city['name'],
              'city_uid': city['city_uid'],
            });
          }
          setState(() {
            cities = cityNames; // Városok frissítése
            cities.insert(0, {'name': 'All city'}); 
          });
        } else {
          throw Exception('Invalid response format - cities not found');
        }
      } else {
        throw Exception('Failed to load cities');
      }
    } catch (e) {
      print("Error fetching cities: $e");
    }
  }

void getStations() async {
  try {
    setState(() {
      markers.clear(); // Törölje a jelenlegi markereket
    });

    final response = await http.get(Uri.parse('https://bus4u.fast-table.com/v1/get_stations'));
    if (response.statusCode == 200) {
      List<dynamic> stationData = json.decode(response.body)['stations'];

      setState(() {
        if (selectedCity == 'All city') {
          for (var station in stationData) {
            markers.add(
              Marker(
                markerId: MarkerId(station['station_uid']),
                position: LatLng(double.parse(station['latitude']), double.parse(station['longitude'])),
                infoWindow: InfoWindow(title: station['name'], snippet: station['address']),
              ),
            );
          }
        } else {
          for (var station in stationData) {
            if (station['city'] == selectedCity) {
              markers.add(
                Marker(
                  markerId: MarkerId(station['station_uid']),
                  position: LatLng(double.parse(station['latitude']), double.parse(station['longitude'])),
                  infoWindow: InfoWindow(title: station['name'], snippet: station['address']),
                ),
              );
            }
          }
        }
      });
    }
  } catch (e) {
    print("Error fetching stations: $e");
  }
}
void _addCurrentLocationMarker() {
    if (currentLocation != null) {
      setState(() {
        markers.add(
          Marker(
            markerId: MarkerId('currentLocation'),
            position: LatLng(
              currentLocation!.latitude!,
              currentLocation!.longitude!,
            ),
            infoWindow: InfoWindow(
              title: 'Current Location',
              snippet: 'Your current position',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
        );

        mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(
              currentLocation!.latitude!,
              currentLocation!.longitude!,
            ),
            15.0,
          ),
        );
      });
    }
}

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stations Map'),
      ),
      body: Column(
        children: [
          if (cities.isNotEmpty) // Legördülő lista csak akkor jelenik meg, ha vannak városok
            DropdownButton<String>(
              value: selectedCity,
              items: cities
                  .map((city) => DropdownMenuItem<String>(
                        value: city['name'],
                        child: Text(city['name'] ?? ''),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCity = value;
                  markers.clear(); // Törölje a jelenlegi markereket
                  getStations(); // Frissítse a markereket a kiválasztott város alapján
                });
              },
              hint: const Text('Select City'),
            ),
            ElevatedButton(
            onPressed: _addCurrentLocationMarker,
            child: const Text('Current Location'),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(currentLocation?.latitude ?? 0.0, currentLocation?.longitude ?? 0.0),
                zoom: 15.0,
              ),
              markers: Set<Marker>.of(markers),
            ),
          ),
        ],
      ),
    );
  }
}
