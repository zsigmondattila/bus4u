import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

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
  String? selectedCity = 'All city';
  var logger = Logger();
  List<Map<String, String>> cities = [];

  @override
  void initState() {
    super.initState();
    checkPermission();
    getCities();
    getStations();
  }

  void getLocation() async {
    try {
      LocationData locData = (await location.getLocation());
      setState(() {
        currentLocation = locData;
        _addCurrentLocationMarker();
        mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(locData.latitude!, locData.longitude!),
            15.0,
          ),
        );
      });
    } catch (e) {
      logger.e("Error getting location, $e");
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
      final response = await http
          .get(Uri.parse('https://bus4u.fast-table.com/v1/get_cities'));
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
            cities = cityNames;
            cities.insert(0, {'name': 'All city'});
          });
        } else {
          throw Exception('Invalid response format - cities not found');
        }
      } else {
        throw Exception('Failed to load cities');
      }
    } catch (e) {
      logger.e("Error fetching cities: $e");
    }
  }

  void getStations() async {
    try {
      setState(() {
        markers.clear();
      });
      final response = await http
          .get(Uri.parse('https://bus4u.fast-table.com/v1/get_stations'));
      if (response.statusCode == 200) {
        List<dynamic> stationData = json.decode(response.body)['stations'];
        setState(() {
          if (selectedCity == 'All city') {
            for (var station in stationData) {
              markers.add(
                Marker(
                  markerId: MarkerId(station['station_uid']),
                  position: LatLng(double.parse(station['latitude']),
                      double.parse(station['longitude'])),
                  infoWindow: InfoWindow(
                      title: station['name'], snippet: station['address']),
                ),
              );
            }
          } else {
            for (var station in stationData) {
              if (station['city'] == selectedCity) {
                markers.add(
                  Marker(
                    markerId: MarkerId(station['station_uid']),
                    position: LatLng(double.parse(station['latitude']),
                        double.parse(station['longitude'])),
                    infoWindow: InfoWindow(
                        title: station['name'], snippet: station['address']),
                  ),
                );
              }
            }
          }
        });
      }
    } catch (e) {
      logger.e("Error fetching stations: $e");
    }
  }

  void _addCurrentLocationMarker() {
    if (currentLocation != null) {
      setState(() {
        markers.add(
          Marker(
            markerId: const MarkerId('currentLocation'),
            position: LatLng(
              currentLocation!.latitude!,
              currentLocation!.longitude!,
            ),
            infoWindow: const InfoWindow(
              title: 'Current Location',
              snippet: 'Your current position',
            ),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
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
      body: Stack(
        children: [
          Column(
            children: [
              Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Select City: ',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (cities.isNotEmpty)
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
                          markers.clear();
                          getStations();
                        });
                      },
                      hint: const Text('Select City'),
                    ),
                ],
              ),
              Expanded(
                child: GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(currentLocation?.latitude ?? 0.0,
                        currentLocation?.longitude ?? 0.0),
                    zoom: 15.0,
                  ),
                  markers: Set<Marker>.of(markers),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FloatingActionButton(
                onPressed: _addCurrentLocationMarker,
                child: const Icon(Icons.location_on),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
