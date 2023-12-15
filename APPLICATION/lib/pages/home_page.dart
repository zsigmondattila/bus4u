import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key});

  @override
  _HomePageState createState() => _HomePageState();
}

class Ticket {
  final String startCity;
  final String startStation;
  final String destinationCity;
  final String destinationStation;
  final String date;
  final String time;
  int numberOfTickets;

  Ticket({
    required this.startCity,
    required this.startStation,
    required this.destinationCity,
    required this.destinationStation,
    required this.date,
    required this.time,
    this.numberOfTickets = 1, // Alapértelmezetten 1 jegy lesz inicializálva
  });
}

class _HomePageState extends State<HomePage> {
  String? selectedStartCity;
  String? selectedStartStation;
  String? selectedDestinationCity;
  String? selectedDestinationStation;

  late String selectedDate = '';
  late String selectedTime = '';

  List<Map<String, dynamic>> cities = [];
  List<Map<String, dynamic>> stations = [];
  List<Map<String, dynamic>> destinationCities = [];
  List<Map<String, dynamic>> destinationStations = [];
  DateTime selectedDateTime = DateTime.now();

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

  Future<void> loadCitiesAndStations() async {
    try {
      cities = await getCities();
    } catch (e) {
      print('Error loading cities: $e');
    }
  }

  Future<void> loadStationsForCity(String cityUid) async {
    try {
      stations = await getStationsByCity(cityUid);
    } catch (e) {
      print('Error loading stations: $e');
    }
  }

  Future<void> loadStationsForDestinationCity(String cityUid) async {
    try {
      destinationStations = await getStationsByCity(cityUid);
    } catch (e) {
      print('Error loading destination stations: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    selectedDate =
        DateFormat('yyyy-MM-dd').format(selectedDateTime); // Set initial date
    selectedTime =
        DateFormat('HH:mm').format(selectedDateTime); // Set initial time
  }

  Future<void> fetchRoutes() async {
    if (selectedStartCity == null ||
        selectedStartStation == null ||
        selectedDestinationCity == null ||
        selectedDestinationStation == null ||
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

    try {
      final response = await http.get(Uri.parse(
          'https://bus4u.fast-table.com/v1/get_available_tickets?start_city_uid=$selectedStartCity&start_station_uid=$selectedStartStation&destination_city_uid=$selectedDestinationCity&destination_station_uid=$selectedDestinationStation&date=$selectedDate&time=$selectedTime'));

      if (response.statusCode == 200) {
        final List<dynamic> ticketsData = json.decode(response.body);
        List<Ticket> tickets = ticketsData.map((ticket) {
          return Ticket(
            startCity: ticket['start_city'],
            startStation: ticket['start_station'],
            destinationCity: ticket['destination_city'],
            destinationStation: ticket['destination_station'],
            date: ticket['date'],
            time: ticket['time'],
          );
        }).toList();

        // Itt kellene megjeleníteni a jegyeket egy listában vagy más megfelelő módon
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Available Tickets'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: tickets.map((ticket) {
                  return ListTile(
                    title:
                        Text('${ticket.startCity} - ${ticket.destinationCity}'),
                    subtitle: Text(
                        'Date: ${ticket.date}, Time: ${ticket.time}, Tickets: ${ticket.numberOfTickets}'),
                    trailing: ElevatedButton(
                      onPressed: () {
                        // Itt lehetne kezelni a jegyvásárlást
                      },
                      child: const Text('Buy Ticket'),
                    ),
                  );
                }).toList(),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        throw Exception('Failed to load tickets');
      }
    } catch (e) {
      print('Error fetching tickets: $e');
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
                    // "From" város kiválasztása
                    const Text('From', style: TextStyle(fontSize: 18)),
                    DropdownButtonFormField<String>(
                      value: selectedStartCity,
                      hint: const Text('Select Start City'),
                      onChanged: (String? value) {
                        setState(() {
                          selectedStartCity = value;
                          selectedStartStation = null; // Reset selected station
                          stations.clear(); // Clear stations list
                          destinationCities = List.from(cities);
                          destinationCities.removeWhere(
                              (city) => city['city_uid'] == selectedStartCity);
                          selectedDestinationCity = null;
                          destinationStations.clear();
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
                    // "From" megálló kiválasztása
                    if (stations.isNotEmpty)
                      DropdownButtonFormField<String>(
                        value: selectedStartStation,
                        hint: const Text('Select Start Station'),
                        onChanged: (String? value) {
                          setState(() {
                            selectedStartStation = value;
                          });
                        },
                        items: stations.map((Map<String, dynamic> station) {
                          return DropdownMenuItem<String>(
                            value: station['station_uid'],
                            child: Text(station['name']),
                          );
                        }).toList(),
                      ),
                    // "To" város kiválasztása
                    const SizedBox(height: 20),
                    const Text('To', style: TextStyle(fontSize: 18)),
                    DropdownButtonFormField<String>(
                      value: selectedDestinationCity,
                      hint: const Text('Select Destination City'),
                      onChanged: (String? value) {
                        setState(() {
                          selectedDestinationCity = value;
                          destinationStations.clear();
                        });
                        if (value != null) {
                          loadStationsForDestinationCity(value);
                        }
                      },
                      items: cities.map((Map<String, dynamic> city) {
                        return DropdownMenuItem<String>(
                          value: city['city_uid'],
                          child: Text(city['name']),
                        );
                      }).toList(),
                    ),

                    // "To" megálló kiválasztása
                    if (destinationStations.isNotEmpty)
                      DropdownButtonFormField<String>(
                        value: selectedDestinationStation,
                        hint: const Text('Select Destination Station'),
                        onChanged: (String? value) {
                          setState(() {
                            selectedDestinationStation = value;
                          });
                        },
                        items: destinationStations
                            .map((Map<String, dynamic> station) {
                          return DropdownMenuItem<String>(
                            value: station['station_uid'],
                            child: Text(station['name']),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 20),

                    // Dátum és idő kiválasztása
                    TextFormField(
                      readOnly: true,
                      onTap: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDateTime,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null &&
                            pickedDate != selectedDateTime) {
                          final TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime:
                                TimeOfDay.fromDateTime(selectedDateTime),
                          );
                          if (pickedTime != null) {
                            setState(() {
                              selectedDateTime = DateTime(
                                pickedDate.year,
                                pickedDate.month,
                                pickedDate.day,
                                pickedTime.hour,
                                pickedTime.minute,
                              );
                              selectedDate = DateFormat('yyyy-MM-dd')
                                  .format(selectedDateTime);
                              selectedTime =
                                  DateFormat('HH:mm').format(selectedDateTime);
                            });
                          }
                        }
                      },
                      controller: TextEditingController(
                        text: selectedDate + ' ' + selectedTime,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Select Date & Time',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
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
