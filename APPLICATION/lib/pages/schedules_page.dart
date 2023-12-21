import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';

class SchedulesPage extends StatefulWidget {
  const SchedulesPage({Key? key}) : super(key: key);

  @override
  _SchedulesPageState createState() => _SchedulesPageState();
}

class _SchedulesPageState extends State<SchedulesPage> {
  String? selectedCity;
  String? selectedStation;
  String? selectedRoute;

  var logger = Logger();

  List<Map<String, dynamic>> cities = [];
  List<Map<String, dynamic>> stations = [];
  List<Map<String, dynamic>> routes = [];
  List<Map<String, dynamic>> schedules = [];

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
            // Add other route details if needed
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
      setState(() {
        // Frissítsük a widgetet az új állomásokkal
      });
    } catch (e) {
      logger.e('Error loading stations: $e');
    }
  }

  Future<void> fetchBusSchedule(String stationUid, String routeUid) async {
    final response = await http.get(Uri.parse(
        'https://bus4u.fast-table.com/v1/get_departure_times_for_station_in_route?route_uid=$routeUid&station_uid=$stationUid'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (data.isNotEmpty) {
        setState(() {
          schedules = List<Map<String, dynamic>>.from(data);
        });
      } else {
        setState(() {
          schedules = [];
        });
      }
    } else {
      setState(() {
        schedules = [];
      });
    }
  }

  List<DataCell> _generateTimeCellsForDay(String day) {
    List<DataCell> cells = [];
    final scheduleForDay = schedules
        .firstWhere((schedule) => schedule['name'] == day, orElse: () => {});

    if (scheduleForDay.isNotEmpty &&
        scheduleForDay.containsKey('departure_times')) {
      final List<dynamic> departureTimes = scheduleForDay['departure_times'];
      for (var time in departureTimes) {
        cells.add(DataCell(Text(time)));
      }
    } else {
      for (var i = 0; i < 15; i++) {
        cells.add(DataCell(Text('')));
      }
    }
    return cells;
  }

  @override
  void initState() {
    super.initState();
    // Az inicializáló logika
    loadCities();
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
                    fetchBusSchedule(selectedStation!, selectedRoute!);
                  }
                },
                child: const Text('Search'),
              ),
              if (schedules.isNotEmpty)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text('Day')),
                      for (var schedule in schedules)
                        DataColumn(label: Text(schedule['name'])),
                    ],
                    rows: [
                      DataRow(cells: [
                        DataCell(Text('Monday')),
                        ..._generateTimeCellsForDay('Monday'),
                      ]),
                      DataRow(cells: [
                        DataCell(Text('Tuesday')),
                        ..._generateTimeCellsForDay('Tuesday'),
                      ]),
                      DataRow(cells: [
                        DataCell(Text('Wednesday')),
                        ..._generateTimeCellsForDay('Wednesday'),
                      ]),
                      DataRow(cells: [
                        DataCell(Text('Thursday')),
                        ..._generateTimeCellsForDay('Thursday'),
                      ]),
                      DataRow(cells: [
                        DataCell(Text('Friday')),
                        ..._generateTimeCellsForDay('Friday'),
                      ]),
                      DataRow(cells: [
                        DataCell(Text('Saturday')),
                        ..._generateTimeCellsForDay('Saturday'),
                      ]),
                      DataRow(cells: [
                        DataCell(Text('Sunday')),
                        ..._generateTimeCellsForDay('Sunday'),
                      ]),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}