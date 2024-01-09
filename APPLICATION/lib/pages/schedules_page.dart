import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
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
  GoogleMapController? mapController;
  LocationData? currentLocation;
  final Location location = Location();
  bool _permission = false;
  var logger = Logger();

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

  Future<List<Map<String, dynamic>>> getStationsOfRoute(String routeUid) async {
    final response = await http.get(Uri.parse(
        'https://bus4u.fast-table.com/v1/get_stations_of_a_route?route_uid=$routeUid'));
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
          polylineId: PolylineId('route'),
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

  Widget buildDepartureTimesTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const <DataColumn>[
          DataColumn(label: Text('Day')),
          DataColumn(label: Text('Departure Times')),
        ],
        rows: departureTimes.map((time) {
          return DataRow(
            cells: <DataCell>[
              DataCell(Text(time['name'])),
              DataCell(
                Container(
                  constraints: BoxConstraints(maxWidth: 800),
                  child: Text(time['departure_times'].join('  ')),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Future<void> _showMapDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Map View'),
          content: Container(
            width: 700,
            child: GoogleMap(
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
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
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
          child: Column(
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
                onPressed: () async {
                  if (selectedRoute != null && selectedStation != null) {
                    List<Map<String, dynamic>> routeStations =
                        await getStationsOfRoute(selectedRoute!);
                    drawRouteOnMap(routeStations);
                    String routeUid = selectedRoute!;
                    String stationUid = selectedStation!;
                    String url =
                        'https://bus4u.fast-table.com/v1/get_departure_times_for_station_in_route?route_uid=$routeUid&station_uid=$stationUid';
                    final response = await http.get(Uri.parse(url));
                    if (response.statusCode == 200) {
                      List<dynamic> data = json.decode(response.body);
                      setState(() {
                        departureTimes = List<Map<String, dynamic>>.from(data);
                      });
                    } else {
                      logger.e('Failed to load departure times');
                    }
                  }
                },
                child: const Text('Search'),
              ),
              if (departureTimes.isNotEmpty) buildDepartureTimesTable(),
              ElevatedButton(onPressed: _showMapDialog, child: Text('Show map'))
            ],
          ),
        ),
      ),
    );
  }
}