import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String selectedStartCity = 'start_city_uid';
  late String selectedStartStation = 'start_station_uid';
  late String selectedDestinationCity = 'destination_city_uid';
  late String selectedDestinationStation = 'destination_station_uid';
  late String selectedDate = 'date';
  late String selectedTime = 'time';

  List<String> cities = [];
  List<String> stations = [];
  DateTime selectedDateTime = DateTime.now();

  Future<List<String>> getCities() async {
    final response =
        await http.get(Uri.parse('https://bus4u.fast-table.com/v1/get_cities'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data.containsKey('cities')) {
        final List<dynamic> citiesData = data['cities'];
        List<String> cityNames = [];
        for (var city in citiesData) {
          cityNames.add(city['name']);
        }
        return cityNames;
      } else {
        throw Exception('Invalid response format - cities not found');
      }
    } else {
      throw Exception('Failed to load cities');
    }
  }

  Future<List<String>> getStations() async {
    final response = 
      await http.get(Uri.parse('https://bus4u.fast-table.com/v1/get_stations'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data.containsKey('stations')) {
        final List<dynamic> stationsData = data['stations'];
        List<String> stationNames = [];
        for (var station in stationsData) {
          stationNames.add(station['name']);
        }
        return stationNames;
      } else {
        throw Exception('Invalid response format - stations not found');
      }
    } else {
      throw Exception('Failed to load stations');
    }
  }

  Future<void> loadCitiesAndStations() async {
    try {
      cities = await getCities();
      stations = await getStations();
    } catch (e) {
      print('Error loading cities and stations: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    selectedDate = selectedDateTime.toString(); // Set initial date
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    selectedTime = TimeOfDay.fromDateTime(selectedDateTime).format(context);
  }

  Future<void> fetchRoutes() async {
    // Validation check - Check if all mandatory fields are selected
    if (selectedStartCity.isEmpty ||
        selectedDestinationCity.isEmpty ||
        selectedDate.isEmpty ||
        selectedTime.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Please select all mandatory fields.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Tickets'),
      ),
      body: FutureBuilder<void>(
        future: loadCitiesAndStations(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedStartCity,
                      hint: const Text('Select Start City'),
                      onChanged: (String? value) {
                        setState(() {
                          selectedStartCity = value!;
                        });
                      },
                      items: const [
                        DropdownMenuItem<String>(
                          value: 'start_city_uid',
                          child: Text('Start City Name'),
                        ),
                        // További DropdownMenuItem-ek a városokhoz
                      ],
                    ),
                    /*DropdownButtonFormField<String>(
                      value: selectedStartStation,
                      hint: const Text('Select Start Station'),
                      onChanged: (String? value) {
                        setState(() {
                          selectedStartStation = value!;
                        });
                      },
                      items: stations.map((String station) {
                        return DropdownMenuItem<String>(
                          value: station[
                              'station_uid'], // Állítsd be a megfelelő értéket
                          child:
                              Text(station['name']), // A megjelenítendő szöveg
                        );
                      }).toList(),
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedDestinationCity,
                      hint: const Text('Select Destination City'),
                      onChanged: (String? value) {
                        setState(() {
                          selectedDestinationCity = value!;
                        });
                      },
                      items: cities.map((String city) {
                        return DropdownMenuItem<String>(
                          value: city,
                          child: Text(city),
                        );
                      }).toList(),
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedDestinationStation,
                      hint: const Text('Select Destination Station'),
                      onChanged: (String? value) {
                        setState(() {
                          selectedDestinationStation = value!;
                        });
                      },
                      items: stations.map((String station) {
                        return DropdownMenuItem<String>(
                          value: station,
                          child: Text(station),
                        );
                      }).toList(),
                    ),*/
                    ElevatedButton(
                      onPressed: () {
                        fetchRoutes();
                      },
                      child: const Text('Search'),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
