import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


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

  List<Map<String, dynamic>> cities = [];
  List<Map<String, dynamic>> stations = [];
  List<Map<String, dynamic>> routes = [];
  List<Map<String, dynamic>> schedule = []; // A járatok menetrendjének listája

  GoogleMapController? mapController;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};

@override
  void initState() {
    super.initState();
    checkPermission();
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
                      schedule.clear();
                    });
                    if (value != null) {
                      loadSchedule(value);
                      showRouteOnMap(value);
                    }
                  },
                  items: routes.map((Map<String, dynamic> route) {
                    return DropdownMenuItem<String>(
                      value: route['route_uid'],
                      child: Text(route['name']),
                    );
                  }).toList(),
                ),
              if (schedule.isNotEmpty)
                DataTable(
                  columns: const [
                    DataColumn(label: Text('Time')),
                    DataColumn(label: Text('Destination')),
                  ],
                  rows: schedule.map((Map<String, dynamic> entry) {
                    return DataRow(cells: [
                      DataCell(Text(entry['time'])),
                      DataCell(Text(entry['destination'])),
                    ]);
                  }).toList(),
                ),
              const SizedBox(height: 20),
              SizedBox(
                height: 300,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(currentLocation?.latitude ?? 0.0,
                        currentLocation?.longitude ?? 0.0),
                    zoom: 15.0,
                  ),
                  markers: markers,
                  polylines: polylines,
                  onMapCreated: (controller) {
                    setState(() {
                      mapController = controller;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Függvények a városok, megállók, járatok, menetrend és térkép adatok betöltéséhez
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

  Future<void> loadStations(String cityUid) async {
  try {
    final response = await http.get(Uri.parse('API_ENDPOINT/stations?city=$cityUid'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      List<Map<String, dynamic>> fetchedStations = [];
      for (var station in data) {
        fetchedStations.add({
          'station_uid': station['station_uid'],
          'name': station['name'],
          // Add other station details as required
        });
      }
      setState(() {
        stations = fetchedStations;
      });
    } else {
      throw Exception('Failed to load stations');
    }
  } catch (e) {
    print('Error loading stations: $e');
  }
}


Future<void> loadRoutes(String stationUid) async {
  try {
    final response = await http.get(Uri.parse('API_ENDPOINT/routes?station=$stationUid'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      List<Map<String, dynamic>> fetchedRoutes = [];
      for (var route in data) {
        fetchedRoutes.add({
          'route_uid': route['route_uid'],
          'name': route['name'],
          // Add other route details as required
        });
      }
      setState(() {
        routes = fetchedRoutes;
      });
    } else {
      throw Exception('Failed to load routes');
    }
  } catch (e) {
    print('Error loading routes: $e');
  }
}


Future<void> loadSchedule(String routeUid) async {
  try {
    final response = await http.get(Uri.parse('API_ENDPOINT/schedule?route=$routeUid'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      List<Map<String, dynamic>> fetchedSchedule = [];
      for (var scheduleEntry in data) {
        fetchedSchedule.add({
          'time': scheduleEntry['time'],
          'destination': scheduleEntry['destination'],
          // Add other schedule details as required
        });
      }
      setState(() {
        schedule = fetchedSchedule;
      });
    } else {
      throw Exception('Failed to load schedule');
    }
  } catch (e) {
    print('Error loading schedule: $e');
  }
}


 void showRouteOnMap(String routeUid) {
  // Fetch route data from API or other source
  // Set markers for each stop
  // Draw polylines to connect stops
  // Update 'markers' and 'polylines' accordingly
}

}
