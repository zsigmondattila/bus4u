import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  List<Map<String, dynamic>> cities = [];
  List<Map<String, dynamic>> stations = [];
  String? selectedCity;
  String? selectedRoute;

  Future<List<Map<String, dynamic>>> getStationsByCity(String cityUid) async {
    final response = await http.get(Uri.parse(
        'https://bus4u.fast-table.com/v1/get_stations_by_city?city_uid=$cityUid'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data.containsKey('stations')) {
        final List<dynamic> stationsData = data['stations'];
        List<Map<String, dynamic>> stationDetails = [];
        for (var station in stationsData) {
          stationDetails.add({
            'station_uid': station['station_uid'],
            'name': station['name'],
            'address': station['address'],
            'longitude': station['longitude'],
            'latitude': station['latitude'],
          });
        }
        return stationDetails;
      } else {
        throw Exception('Invalid response format - stations not found');
      }
    } else {
      throw Exception('Failed to load stations');
    }
  }

Future<List<Map<String, dynamic>>> getStationsOfRoute(String routeUid) async {
    final response = await http.get(Uri.parse('https://bus4u.fast-table.com/v1/get_stations_of_a_route?route_uid=$routeUid'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data.containsKey('stations')) {
        final List<dynamic> stationsData = data['stations'];
        List<Map<String, dynamic>> stationDetails = [];
        for (var station in stationsData) {
          stationDetails.add({
            'station_uid': station['station_uid'],
            'name': station['name'],
            'address': station['address'],
            'longitude': station['longitude'],
            'latitude': station['latitude'],
          });
        }
        return stationDetails;
      } else {
        throw Exception('Invalid response format - stations not found');
      }
    } else {
      throw Exception('Failed to load stations');
    }
  }

  Future<void> loadStationsForRoute(String routeUid) async {
    try {
      final List<Map<String, dynamic>> fetchedStations =
          await getStationsOfRoute(routeUid);
      setState(() {
        stations = fetchedStations;
      });
    } catch (e) {
      print('Error loading stations for route: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAvailableCities() async {
  final response = await http.get(Uri.parse('https://bus4u.fast-table.com/v1/get_available_cities'));
  if (response.statusCode == 200) {
    final List<dynamic> citiesData = json.decode(response.body);
    List<Map<String, dynamic>> cityDetails = [];
    for (var city in citiesData) {
      cityDetails.add({
        'city_uid': city['city_uid'],
        'name': city['name'],
        // ... (other city details you may need)
      });
    }
    return cityDetails;
  } else {
    throw Exception('Failed to load available cities');
  }
}

  Future<void> loadCitiesAndStations() async {
  try {
    // Get available cities
    final List<Map<String, dynamic>> fetchedCities = await getAvailableCities();
    setState(() {
      cities = fetchedCities;
    });
  } catch (e) {
    print('Error loading cities: $e');
  }
}

  Future<void> loadStations(String cityUid) async {
    try {
      final List<Map<String, dynamic>> fetchedStations =
          await getStationsByCity(cityUid);
      setState(() {
        stations = fetchedStations;
      });
    } catch (e) {
      print('Error loading stations: $e');
    }
  }

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: selectedCity,
                hint: const Text('Select City'),
                onChanged: (String? value) {
                  setState(() {
                    selectedCity = value;
                    selectedRoute = null;
                    stations.clear();
                  });
                  if (value != null) {
                    loadStations(value);
                  }
                },
                items: cities.map((Map<String, dynamic> city) {
                  return DropdownMenuItem<String>(
                    value: city['city_uid'],
                    child: Text(city['name']),
                  );
                }).toList(),
              ),
              if (stations.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: selectedRoute,
                  hint: const Text('Select Route'),
                  onChanged: (String? value) {
                    setState(() {
                      selectedRoute = value;
                      stations.clear();
                    });
                    // Implement logic for fetching stations for selected route
                    if (value != null) {
                      loadStationsForRoute(value);
                    }
                  },
                  items: stations.map((Map<String, dynamic> station) {
                    return DropdownMenuItem<String>(
                      value: station['route_uid'],
                      child: Text(station['route_name']),
                    );
                  }).toList(),
                ),
              // Implement the Google Map with markers based on selected city or route
              if (stations.isNotEmpty)
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(currentLocation?.latitude ?? 0.0,
                        currentLocation?.longitude ?? 0.0),
                    zoom: 15.0,
                  ),
                  markers: Set<Marker>.from(stations.map((station) {
                    return Marker(
                      markerId: MarkerId(station['station_uid']),
                      position: LatLng(station['latitude'], station['longitude']),
                      infoWindow: InfoWindow(title: station['name']),
                    );
                  })),
                ),
            ],
          ),
        ),
      ),
    );
  }
}