import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SchedulesPage extends StatefulWidget {
  const SchedulesPage({Key? key}) : super(key: key);

  @override
  _SchedulesPageState createState() => _SchedulesPageState();
}

class _SchedulesPageState extends State<SchedulesPage> {
  String? selectedCity;
  String? selectedStation;
  String? selectedRoute;

LocationData? currentLocation;
  final Location location = Location();
  bool _permission = false;

  var logger = Logger();

  late GoogleMapController mapController;
  Set<Marker> markers = {};
  List<LatLng> polylineCoordinates = [];
  Set<Polyline> polylines = {};

  List<Map<String, dynamic>> cities = [];
  List<Map<String, dynamic>> stations = [];
  List<Map<String, dynamic>> routes = [];
  List<Map<String, dynamic>> schedules = [];
  List<Map<String, dynamic>> busSchedule = [];

  Future<List<Map<String, String>>> getCities() async {
    final response =
        await http.get(Uri.parse('https://bus4u.fast-table.com/v1/get_cities'));
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

  Future<List<Map<String, dynamic>>> getRoutesByStation(
      String stationUid) async {
    final response = await http.get(Uri.parse(
        'https://bus4u.fast-table.com/v1/get_routes_by_station?station_uid=$stationUid'));
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

  Future<void> fetchBusSchedule(String stationUid, String routeUid) async {
    final response = await http.get(Uri.parse(
        'https://bus4u.fast-table.com/v1/get_departure_times_for_station_in_route?route_uid=$routeUid&station_uid=$stationUid'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (data.isNotEmpty) {
        setState(() {
          busSchedule = List<Map<String, dynamic>>.from(data);
        });
      } else {
        setState(() {
          busSchedule = [];
        });
      }
    } else {
      setState(() {
        busSchedule = [];
      });
    }
  }

  Future<void> loadCities() async {
    try {
      List<Map<String, String>> fetchedCities = await getCities();
      setState(() {
        cities = fetchedCities;
      });
    } catch (e) {
      logger.e('Error loading cities: $e');
    }
  }

  Future<void> loadRoutes(String stationUid) async {
    try {
      List<Map<String, dynamic>> fetchedRoutes =
          await getRoutesByStation(stationUid);
      setState(() {
        routes = fetchedRoutes;
      });
    } catch (e) {
      logger.e('Error loading routes: $e');
    }
  }

  Future<void> loadStationsForCity(String cityUid) async {
    try {
      stations = await getStationsByCity(cityUid);
      setState(() {});
    } catch (e) {
      logger.e('Error loading stations: $e');
    }
  }


 void updateMap() {
    setState(() {
      markers.clear();
      polylines.clear();

      for (var station in busSchedule) {
        double latitude = double.parse(station['latitude']);
        double longitude = double.parse(station['longitude']);

        markers.add(
          Marker(
            markerId: MarkerId(station['station_uid']),
            position: LatLng(latitude, longitude),
            infoWindow: InfoWindow(title: station['name']),
          ),
        );

        polylineCoordinates.add(LatLng(latitude, longitude));
      }

      polylines.add(
        Polyline(
          polylineId: PolylineId('route'),
          color: Colors.blue,
          points: polylineCoordinates,
        ),
      );
    });
  }

    void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
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
        mapController.animateCamera(
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
        mapController.animateCamera(
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

  @override
  void initState() {
    super.initState();
    loadCities();
    checkPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
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
              if (stations.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: selectedStation,
                  hint: const Text('Select Station'),
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
              if (routes.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: selectedRoute,
                  hint: const Text('Select Route'),
                  onChanged: (String? value) {
                    setState(() {
                      selectedRoute = value;
                    });
                    if (value != null) {}
                  },
                  items: routes.map((Map<String, dynamic> route) {
                    return DropdownMenuItem<String>(
                      value: route['route_uid'],
                      child: Text(route['name']),
                    );
                  }).toList(),
                ),
              ElevatedButton(
                onPressed: () {
                  if (selectedRoute != null && selectedStation != null) {
                    fetchBusSchedule(selectedStation!, selectedRoute!)
                        .then((_) {
                      updateMap();
                    });
                  }
                },
                child: const Text('Search'),
              ),

              if (busSchedule.isNotEmpty)
                Container(
                  height: 300,
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(currentLocation?.latitude ?? 0.0,
                        currentLocation?.longitude ?? 0.0),
                    zoom: 15.0,
                  ),
                    markers: markers,
                    polylines: polylines,
                  ),
                ),
                
            ],
          ),
        ),
      ),
    );
  }
}
