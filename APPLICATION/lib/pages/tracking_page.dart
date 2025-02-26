import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class TrackingPage extends StatefulWidget {
  const TrackingPage({super.key});

  @override
  TrackingPageState createState() => TrackingPageState();
}

class TrackingPageState extends State<TrackingPage> {
  GoogleMapController? mapController;
  List<Marker> markers = [];
  LocationData? currentLocation;
  Marker? currentLocationMarker;
  final Location location = Location();
  bool _permission = false;
  bool _isStationsLoading = false;
  bool _isBusesLoading = false;
  String? selectedCity;
  String? selectedRoute;
  List<Map<String, String>> cities = [];
  List<Map<String, dynamic>> routes = [];
  var logger = Logger();
  Set<Polyline> polylines = <Polyline>{};

  @override
  void initState() {
    super.initState();
    checkPermission();
    getCities();
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
    _addCurrentLocationMarker();
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
      logger.e("Error fetching cities: $e");
    }
  }

  void getRoutesByCity(String cityUid) async {
    _isStationsLoading = true;
    try {
      final response = await http.get(
        Uri.parse(
            'https://api.bus4u.online/v1/get_routes_by_city?city_uid=$cityUid'),
      );

      if (response.statusCode == 200) {
        List<dynamic> routesData = json.decode(response.body);

        setState(() {
          routes = routesData.map((route) {
            return {
              'route_uid': route['route_uid'],
              'name': route['name'],
            };
          }).toList();
        });
      } else {
        throw Exception('Failed to load routes');
      }
    } catch (e) {
      logger.e("Error fetching routes by city: $e");
    } finally {
      _isStationsLoading = false;
    }
  }

  void getBusesOnRoute(String routeUid) async {
    _isBusesLoading = true;
    try {
      final response = await http.get(
        Uri.parse(
            'https://api.bus4u.online/v1/get_bus_locations_by_route?route_uid=$routeUid'),
      );

      if (response.statusCode == 200) {
        List<dynamic> busesData = json.decode(response.body);

        setState(() {
          markers.clear();

          // Add markers for bus locations
          for (var bus in busesData) {
            markers.add(
              Marker(
                markerId: MarkerId(bus['bus_uid']),
                position: LatLng(
                  double.parse(bus['latitude']),
                  double.parse(bus['longitude']),
                ),
                infoWindow: InfoWindow(
                  title: '${bus['license_plate']}',
                  snippet: 'Capacity: ${bus['capacity']}',
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed),
              ),
            );
          }
        });
      } else {
        throw Exception('Failed to load buses on route');
      }
    } catch (e) {
      logger.e("Error fetching buses on route: $e");
    } finally {
      _isBusesLoading = false;
    }
  }

  void getStationsOfRoute(String routeUid) async {
    try {
      final response = await http.get(Uri.parse(
          'https://api.bus4u.online/v1/get_stations_of_a_route?route_uid=$routeUid'));
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
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueOrange),
              ),
            );
          }
        });
        drawPolyline(stationData);
      }
    } catch (e) {
      logger.e("Error fetching stations of route: $e");
    }
  }

  void drawPolyline(List<dynamic> stationData) {
    List<LatLng> polylineCoordinates = [];

    for (var station in stationData) {
      double latitude = double.parse(station['latitude']);
      double longitude = double.parse(station['longitude']);
      polylineCoordinates.add(LatLng(latitude, longitude));
    }

    Polyline polyline = Polyline(
      polylineId: const PolylineId('route'),
      color: Colors.orange.withAlpha(128),
      points: polylineCoordinates,
      width: 4,
    );

    setState(() {
      polylines.clear();
      polylines.add(polyline);
    });
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
            polylines: polylines,
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                if (cities.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.0),
                        color: Colors.white.withAlpha(230)),
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
                          polylines.clear();
                          getRoutesByCity(value!);
                        });
                      },
                      icon: _isStationsLoading
                          ? const AspectRatio(
                              aspectRatio: 1,
                              child: CircularProgressIndicator.adaptive(
                                strokeWidth: 3.0,
                              ))
                          : null,
                      hint: const Text('Select City'),
                    ),
                  ),
                const SizedBox(height: 10),
                if (routes.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.0),
                        color: Colors.white.withAlpha(230)),
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
                        });
                        if (selectedRoute != null) {
                          getStationsOfRoute(selectedRoute!);
                          getBusesOnRoute(selectedRoute!);
                        }
                      },
                      icon: _isBusesLoading
                          ? const AspectRatio(
                              aspectRatio: 1,
                              child: CircularProgressIndicator.adaptive(
                                strokeWidth: 3.0,
                              ))
                          : null,
                      hint: const Text('Select Route'),
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
