import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class StationsPage extends StatefulWidget {
  const StationsPage({super.key});

  @override
  StationsPageState createState() => StationsPageState();
}

class StationsPageState extends State<StationsPage> {
  GoogleMapController? mapController;
  List<Marker> markers = [];
  LocationData? currentLocation;
  Marker? currentLocationMarker;
  final Location location = Location();
  bool _permission = false;
  bool _isCitiesLoading = false;
  bool _isRoutesLoading = false;
  String? selectedCity;
  String? selectedRoute;
  List<Map<String, String>> cities = [];
  List<Map<String, String>> routes = [];

  @override
  void initState() {
    super.initState();
    checkPermission();
    getAllStations();
    getCities();
    getRoutes();
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
      debugPrint("Error getting location, $e");
    }
  }

  void checkPermission() async {
    try {
      if (!Platform.isAndroid) return;
      final hasPermission = await location.serviceEnabled();
      if (!hasPermission) {
        _permission = await location.requestService();
        if (_permission) {
          getLocation();
        }
      } else {
        getLocation();
      }
    } catch (e) {
      debugPrint("Error checking permission: $e");
    }
  }

  void _addCurrentLocationMarker() {
    if (currentLocation != null) {
      setState(() {
        currentLocationMarker = Marker(
          markerId: const MarkerId('currentLocation'),
          position: LatLng(
            currentLocation!.latitude!,
            currentLocation!.longitude!,
          ),
          infoWindow: const InfoWindow(
            title: 'Current Location',
            snippet: 'Your current position',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
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

  void getAllStations() async {
    try {
      setState(() {
        markers.clear();
      });
      final response =
          await http.get(Uri.parse('https://api.bus4u.online/v1/get_stations'));
      if (response.statusCode == 200) {
        List<dynamic> stationData = json.decode(response.body)['stations'];
        setState(() {
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
        });
      }
    } catch (e) {
      debugPrint("Error fetching stations: $e");
    }
  }

  void getCities() async {
    try {
      final response =
          await http.get(Uri.parse('https://api.bus4u.online/v1/get_cities'));
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
          });
        } else {
          throw Exception('Cities not found');
        }
      } else {
        throw Exception('Failed to load cities');
      }
    } catch (e) {
      debugPrint("Error fetching cities: $e");
    }
  }

  void getRoutes() async {
    try {
      final response =
          await http.get(Uri.parse('https://api.bus4u.online/v1/get_routes'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('routes')) {
          final List<dynamic> routesData = data['routes'];
          List<Map<String, String>> routeNames = [];
          for (var route in routesData) {
            routeNames.add({
              'name': route['name'],
              'route_uid': route['route_uid'],
            });
          }
          setState(() {
            routes = routeNames;
          });
        } else {
          throw Exception('Routes not found');
        }
      } else {
        throw Exception('Failed to load routes');
      }
    } catch (e) {
      debugPrint("Error fetching routes: $e");
    }
  }

  void getStationsOfCity() async {
    _isCitiesLoading = true;
    try {
      final response = await http.get(Uri.parse(
          'https://api.bus4u.online/v1/get_stations_by_city?city_uid=$selectedCity'));
      if (response.statusCode == 200) {
        List<dynamic> stationData = json.decode(response.body)['stations'];
        List<Marker> tmpMarkers = [];
        for (var station in stationData) {
          tmpMarkers.add(
            Marker(
              markerId: MarkerId(station['station_uid']),
              position: LatLng(double.parse(station['latitude']),
                  double.parse(station['longitude'])),
              infoWindow: InfoWindow(
                  title: station['name'], snippet: station['address']),
            ),
          );
        }
        setState(() {
          markers = tmpMarkers;
        });
        mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(markers[0].position.latitude, markers[0].position.longitude),
            13.0,
          ),
        );
      }
    } catch (e) {
      setState(() {
        markers.clear();
      });
      debugPrint("Error fetching stations: $e");
    } finally {
      setState(() {
        _isCitiesLoading = false;
      });
    }
  }

  void getStationsOfRoute(String routeUid) async {
    _isRoutesLoading = true;
    try {
      final response = await http.get(Uri.parse(
          'https://api.bus4u.online/v1/get_stations_of_a_route?route_uid=$routeUid'));
      if (response.statusCode == 200) {
        List<Marker> tmpMarkers = [];
        List<dynamic> stationData = json.decode(response.body)['stations'];
        for (var station in stationData) {
          tmpMarkers.add(
            Marker(
              markerId: MarkerId(station['station_uid']),
              position: LatLng(double.parse(station['latitude']),
                  double.parse(station['longitude'])),
              infoWindow: InfoWindow(
                  title: station['name'], snippet: station['address']),
            ),
          );
        }
        setState(() {
          markers.clear();
          markers = tmpMarkers;
        });
      }
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(markers[0].position.latitude, markers[0].position.longitude),
          13.0,
        ),
      );
    } catch (e) {
      setState(() {
        markers.clear();
      });
      debugPrint("Error fetching stations of route: $e");
    } finally {
      setState(() {
        _isRoutesLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentLocationMarker != null) markers.add(currentLocationMarker!);
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(currentLocation?.latitude ?? 0.0,
                  currentLocation?.longitude ?? 0.0),
              zoom: 15.0,
            ),
            markers: Set<Marker>.of(markers),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                if (cities.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.0),
                      color: Colors.white.withAlpha(230),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: selectedCity,
                      items: cities
                          .map((city) => DropdownMenuItem<String>(
                                value: city['city_uid'],
                                child: Text(city['name'] ?? ''),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCity = value;
                          selectedRoute = null;
                          markers.clear();
                          getStationsOfCity();
                        });
                      },
                      icon: _isCitiesLoading
                          ? const AspectRatio(
                              aspectRatio: 1,
                              child: CircularProgressIndicator.adaptive(
                                strokeWidth: 3.0,
                              ))
                          : null,
                      hint: const Text('Filter by City'),
                    ),
                  ),
                const SizedBox(height: 10),
                if (routes.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.0),
                      color: Colors.white.withAlpha(230),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: selectedRoute,
                      items: routes
                          .map((route) => DropdownMenuItem<String>(
                                value: route['route_uid'],
                                child: Text(route['name'] ?? ''),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedRoute = value;
                          selectedCity = null;
                          markers.clear();
                          getStationsOfRoute(selectedRoute!);
                        });
                      },
                      icon: _isRoutesLoading
                          ? const AspectRatio(
                              aspectRatio: 1,
                              child: CircularProgressIndicator.adaptive(
                                strokeWidth: 3.0,
                              ))
                          : null,
                      hint: const Text('Filter by Route'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCurrentLocationMarker,
        child: const Icon(Icons.location_on),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
