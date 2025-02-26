import 'dart:io';

import 'package:bus4u/components/departure_timetable.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class SchedulesPage extends StatefulWidget {
  const SchedulesPage({super.key});

  @override
  SchedulesPageState createState() => SchedulesPageState();
}

class SchedulesPageState extends State<SchedulesPage> {
  final _formKey = GlobalKey<FormState>();

  String? selectedCity;
  String? selectedStation;
  String? selectedRoute;
  String? selectedRouteName;
  GoogleMapController? mapController;
  LocationData? currentLocation;
  final Location location = Location();
  bool _permission = false;
  bool _isRouteLoading = false;
  bool _isStationLoading = false;
  bool _isScheduleLoading = false;

  List<Marker> markers = [];
  List<LatLng> polylineCoordinates = [];
  List<Polyline> polylines = [];
  List<Map<String, dynamic>> cities = [];
  List<Map<String, dynamic>> stations = [];
  List<Map<String, dynamic>> routes = [];
  List<Map<String, dynamic>> schedules = [];
  List<Map<String, dynamic>> departureTimes = [];

  Future<List<Map<String, String>>> getCities() async {
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
        return cityNames;
      } else {
        throw Exception('Invalid response format - cities not found');
      }
    } else {
      throw Exception('Failed to load cities');
    }
  }

  Future<List<Map<String, dynamic>>> getStationsByCity(String cityUid) async {
    final response = await http.get(Uri.parse(
        'https://api.bus4u.online/v1/get_stations_by_city?city_uid=$cityUid'));
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

  Future<List<Map<String, dynamic>>> getRoutesByStation(
      String stationUid) async {
    final response = await http.get(Uri.parse(
        'https://api.bus4u.online/v1/get_routes_by_station?station_uid=$stationUid'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data.containsKey('routes')) {
        final List<dynamic> routesData = data['routes'];
        List<Map<String, dynamic>> routeDetails = [];
        for (var route in routesData) {
          routeDetails.add({
            'route_uid': route['route_uid'],
            'name': route['name'],
          });
        }
        return routeDetails;
      } else {
        throw Exception('Invalid response format - routes not found');
      }
    } else {
      throw Exception('Failed to load routes');
    }
  }

  Future<List<Map<String, dynamic>>> getStationsOfRoute(String routeUid) async {
    final response = await http.get(Uri.parse(
        'https://api.bus4u.online/v1/get_stations_of_a_route?route_uid=$routeUid'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data.containsKey('stations')) {
        final List<dynamic> stationsData = data['stations'];
        List<Map<String, dynamic>> stationDetails = [];
        for (var station in stationsData) {
          stationDetails.add({
            'route_station_uid': station['route_station_uid'],
            'station_uid': station['station_uid'],
            'name': station['name'],
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

  Future<void> loadCities() async {
    try {
      List<Map<String, String>> fetchedCities = await getCities();
      setState(() {
        cities = fetchedCities;
      });
    } catch (e) {
      debugPrint('Error loading cities: $e');
    }
  }

  Future<void> loadRoutes(String stationUid) async {
    setState(() {
      _isRouteLoading = true;
    });
    try {
      List<Map<String, dynamic>> fetchedRoutes =
          await getRoutesByStation(stationUid);
      setState(() {
        routes = fetchedRoutes;
      });
    } catch (e) {
      debugPrint('Error loading routes: $e');
    } finally {
      setState(() {
        _isRouteLoading = false;
      });
    }
  }

  Future<void> loadStationsForCity(String cityUid) async {
    setState(() {
      _isStationLoading = true;
    });
    try {
      var s = await getStationsByCity(cityUid);
      setState(() {
        stations = s;
      });
    } catch (e) {
      debugPrint('Error loading stations: $e');
    } finally {
      setState(() {
        _isStationLoading = false;
      });
    }
  }

  void drawRouteOnMap(List<Map<String, dynamic>> routeStations) {
    setState(() {
      markers.clear();
      polylines.clear();
      polylineCoordinates.clear();

      for (var station in routeStations) {
        if (station.containsKey('latitude') &&
            station.containsKey('longitude')) {
          double? latitude = double.tryParse(station['latitude']);
          double? longitude = double.tryParse(station['longitude']);

          if (latitude != null && longitude != null) {
            markers.add(
              Marker(
                markerId: MarkerId(station['route_station_uid']),
                position: LatLng(latitude, longitude),
                infoWindow: InfoWindow(
                    title: station['name'], snippet: station['address']),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueOrange),
              ),
            );

            polylineCoordinates.add(LatLng(latitude, longitude));
          }
        }
      }

      polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          color: const Color.fromARGB(255, 239, 108, 0),
          points: polylineCoordinates,
          width: 4,
        ),
      );
    });
    _addCurrentLocationMarker();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _addCurrentLocationMarker();
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

  Future<void> _showMapDialog({String? route}) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog.fullscreen(
          child: Scaffold(
            appBar: AppBar(
              title:
                  route != null ? Text("Route $route") : const Text('Map View'),
            ),
            body: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(currentLocation?.latitude ?? 0.0,
                    currentLocation?.longitude ?? 0.0),
                zoom: 15.0,
              ),
              markers: markers.toSet(),
              polylines: polylines.toSet(),
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    checkPermission();
    loadCities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedCity,
                  decoration: const InputDecoration(
                    labelText: 'City',
                  ),
                  validator: (value) =>
                      value == null ? 'This field is required' : null,
                  onChanged: (String? value) {
                    setState(() {
                      selectedCity = value;
                      selectedStation = null;
                      selectedRoute = null;
                      stations.clear();
                      routes.clear();
                    });
                    if (value != null) {
                      loadStationsForCity(value);
                    }
                  },
                  items: cities.map((Map<String, dynamic> city) {
                    return DropdownMenuItem<String>(
                      value: city['city_uid'],
                      child: Text(city['name']),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedStation,
                  icon: _isStationLoading
                      ? const AspectRatio(
                          aspectRatio: 1,
                          child: CircularProgressIndicator.adaptive(
                            strokeWidth: 3.0,
                          ))
                      : null,
                  decoration: const InputDecoration(labelText: 'Station'),
                  validator: (value) =>
                      value == null ? 'This field is required' : null,
                  onChanged: (String? value) {
                    setState(() {
                      selectedStation = value;
                      selectedRoute = null;
                      routes.clear();
                    });
                    if (value != null) {
                      loadRoutes(value);
                    }
                  },
                  items: stations.map((Map<String, dynamic> station) {
                    return DropdownMenuItem<String>(
                      value: station['station_uid'],
                      child: Text(station['name']),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  icon: _isRouteLoading
                      ? const AspectRatio(
                          aspectRatio: 1,
                          child: CircularProgressIndicator.adaptive(
                            strokeWidth: 3.0,
                          ))
                      : null,
                  value: selectedRoute,
                  decoration: const InputDecoration(labelText: 'Route'),
                  validator: (value) =>
                      value == null ? 'This field is required' : null,
                  onChanged: (String? value) {
                    if (value == null) return;
                    String? selectedName;
                    try {
                      selectedName = routes.firstWhere(
                          (element) => element['route_uid'] == value)['name'];
                    } catch (_) {}
                    setState(() {
                      selectedRoute = value;
                      selectedRouteName = selectedName;
                    });
                  },
                  items: routes.map((Map<String, dynamic> route) {
                    return DropdownMenuItem<String>(
                      value: route['route_uid'],
                      child: Text(route['name']),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                _isScheduleLoading
                    ? const Center(child: CircularProgressIndicator.adaptive())
                    : FilledButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              departureTimes.clear();
                              _isScheduleLoading = true;
                            });
                            String url =
                                'https://api.bus4u.online/v1/get_departure_times_for_station_in_route?route_uid=$selectedRoute&station_uid=$selectedStation';
                            final response = await http.get(Uri.parse(url));
                            List<Map<String, dynamic>> dt = [];
                            if (response.statusCode == 200) {
                              List<dynamic> data = json.decode(response.body);
                              dt = List<Map<String, dynamic>>.from(data);
                            } else {
                              debugPrint('Failed to load departure times');
                            }
                            setState(() {
                              departureTimes = dt;
                              _isScheduleLoading = false;
                            });
                          }
                        },
                        child: const Text('Search'),
                      ),
                if (departureTimes.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Departure times for route $selectedRouteName:',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      )),
                  DepartureTimetable(departureTimes: departureTimes),
                  const SizedBox(height: 16),
                  ElevatedButton(
                      onPressed: () async {
                        List<Map<String, dynamic>> routeStations =
                            await getStationsOfRoute(selectedRoute!);
                        drawRouteOnMap(routeStations);
                        _showMapDialog(route: selectedRouteName);
                      },
                      child: const Text('View route on the map')),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
