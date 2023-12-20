import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class Ticket {
  final String startStation;
  final String destinationStation;
  final String companyName;
  final String routeName;
  final double ticketPrice;
  final List<String> departureTimes;
  int quantity;

  Ticket({
    required this.startStation,
    required this.destinationStation,
    required this.companyName,
    required this.routeName,
    required this.ticketPrice,
    required this.departureTimes,
    required this.quantity,
  });
}

class _HomePageState extends State<HomePage> {
  String? selectedStartCity;
  String? selectedStartStation;
  String? selectedDestinationCity;
  String? selectedDestinationStation;
  String? _tempSelectedStartCity;
  String? _tempSelectedStartStation;
  String? _tempSelectedDestinationCity;
  String? _tempSelectedDestinationStation;
  final String _tempSelectedDate = '';
  final String _tempSelectedTime = '';

  late String selectedDate = '';
  late String selectedTime = '';

  List<Map<String, dynamic>> cities = [];
  List<Map<String, dynamic>> stations = [];
  List<Map<String, dynamic>> destinationCities = [];
  List<Map<String, dynamic>> destinationStations = [];
  List<Ticket> displayedTickets = [];

  DateTime selectedDateTime = DateTime.now();
  late List<Ticket> availableTickets = [];

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

  Future<void> loadDestinationCities() async {
    try {
      destinationCities = await getCities();
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

  Future<void> loadDestinationStations(String cityUid) async {
    try {
      destinationStations = await getStationsByCity(cityUid);
    } catch (e) {
      print('Error loading destination stations: $e');
    }
  }

  Future<void> fetchRoutes() async {
    if (selectedStartCity == null ||
        selectedStartStation == null ||
        selectedDestinationCity == null ||
        selectedDestinationStation == null) {
      print('Please select all cities and stations');
      return;
    }
    try {
      final response = await http.get(
        Uri.parse(
          'https://bus4u.fast-table.com/v1/get_available_tickets?start_city_uid=$selectedStartCity&start_station_uid=$selectedStartStation&destination_city_uid=$selectedDestinationCity&destination_station_uid=$selectedDestinationStation&date=$selectedDate&time=$selectedTime',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> ticketsData = json.decode(response.body);

        List<Ticket> tickets = [];

        for (var ticketData in ticketsData) {
          String startStation = ticketData['start_station'];
          String destinationStation = ticketData['destination_station'];
          String companyName = ticketData['company_name'];
          String routeName = ticketData['route_name'];
          double ticketPrice = double.parse(ticketData['ticket_price']);
          List<String> departureTimes =
              List<String>.from(ticketData['departure_times']);

          Ticket ticket = Ticket(
            startStation: startStation,
            destinationStation: destinationStation,
            companyName: companyName,
            routeName: routeName,
            ticketPrice: ticketPrice,
            departureTimes: departureTimes,
            quantity: 1,
          );

          tickets.add(ticket);
        }

        setState(() {
          availableTickets = tickets;
          displayedTickets = tickets; // Frissítés displayedTickets listával
        });
      } else {
        throw Exception('Failed to load tickets');
      }
    } catch (e) {
      print('Error fetching tickets: $e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Available Tickets'),
        ),
        body: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: FutureBuilder<void>(
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
                            const SizedBox(height: 20),
                            const Text('From', style: TextStyle(fontSize: 18)),

                            // "From" város kiválasztása

                            DropdownButtonFormField<String>(
                              value:
                                  _tempSelectedStartCity ?? selectedStartCity,
                              hint: const Text('Select Start City'),
                              onChanged: (String? value) {
                                setState(() {
                                  _tempSelectedStartCity = value;
                                  _tempSelectedStartStation = null;
                                  _tempSelectedDestinationCity = null;
                                  _tempSelectedDestinationStation = null;
                                  selectedStartStation =
                                      null; // Töröld a korábbi értékeket
                                  selectedDestinationCity =
                                      null; // Töröld a korábbi értékeket
                                  selectedDestinationStation =
                                      null; // Töröld a korábbi értékeket
                                  if (value != null) {
                                    stations =
                                        []; // Állomások listájának ürítése
                                    destinationStations =
                                        []; // Állomások listájának ürítése
                                    destinationCities =
                                        []; // Célvárosok listájának ürítése
                                    selectedStartCity = value;
                                    loadStationsForCity(value);
                                    loadDestinationCities();
                                  }
                                });
                              },
                              items: cities.map((Map<String, dynamic> city) {
                                return DropdownMenuItem<String>(
                                  value: city['city_uid'],
                                  child: Text(city['name']),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 20),

                            // "From" megálló kiválasztása
                            if (stations.isNotEmpty)
                              DropdownButtonFormField<String>(
                                value: _tempSelectedStartStation ??
                                    selectedStartStation,
                                hint: const Text('Select Start Station'),
                                onChanged: (String? value) {
                                  _tempSelectedStartStation = value;
                                },
                                items: stations
                                    .map((Map<String, dynamic> station) {
                                  return DropdownMenuItem<String>(
                                    value: station['station_uid'],
                                    child: Text(station['name']),
                                  );
                                }).toList(),
                              ),
                            const SizedBox(height: 20),

                            // "To" város kiválasztása
                            const SizedBox(height: 20),
                            const Text('To', style: TextStyle(fontSize: 18)),
                            DropdownButtonFormField<String>(
                              value: _tempSelectedDestinationCity ??
                                  selectedDestinationCity,
                              hint: const Text('Select Destination City'),
                              onChanged: (String? value) {
                                setState(() {
                                  _tempSelectedDestinationCity = value;
                                  if (value != null) {
                                    selectedDestinationCity = value;
                                    _tempSelectedDestinationStation =
                                        null; // Null-ra állítjuk a célállomást
                                    selectedDestinationStation = null;
                                    loadDestinationStations(
                                        value); // Betöltjük a célváros állomásait
                                  }
                                });
                              },
                              items: destinationCities
                                  .map((Map<String, dynamic> city) {
                                return DropdownMenuItem<String>(
                                  value: city['city_uid'],
                                  child: Text(city['name']),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 20),

                            // "To" megálló kiválasztása
                            if (destinationStations.isNotEmpty)
                              DropdownButtonFormField<String>(
                                value: _tempSelectedDestinationStation ??
                                    selectedDestinationStation,
                                hint: const Text('Select Destination Station'),
                                onChanged: (String? value) {
                                  _tempSelectedDestinationStation = value;
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
                                final DateTime? pickedDate =
                                    await showDatePicker(
                                  context: context,
                                  initialDate: selectedDateTime,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2101),
                                );
                                if (pickedDate != null &&
                                    pickedDate != selectedDateTime) {
                                  final TimeOfDay? pickedTime =
                                      await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.fromDateTime(
                                        selectedDateTime),
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
                                      selectedTime = DateFormat('HH:mm')
                                          .format(selectedDateTime);
                                    });
                                  }
                                }
                              },
                              controller: TextEditingController(
                                text: _tempSelectedDate.isEmpty
                                    ? '$selectedDate $selectedTime'
                                    : '$_tempSelectedDate $_tempSelectedTime',
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Select Date & Time',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                // Választott értékek alkalmazása és frissítése
                                setState(() {
                                  selectedStartCity = _tempSelectedStartCity;
                                  selectedStartStation =
                                      _tempSelectedStartStation;
                                  selectedDestinationCity =
                                      _tempSelectedDestinationCity;
                                  selectedDestinationStation =
                                      _tempSelectedDestinationStation;
                                  selectedDate = _tempSelectedDate.isEmpty
                                      ? selectedDate
                                      : _tempSelectedDate;
                                  selectedTime = _tempSelectedTime.isEmpty
                                      ? selectedTime
                                      : _tempSelectedTime;
                                });
                                fetchRoutes(); // A "Search" gomb megnyomásakor hívjuk meg a fetchRoutes függvényt
                              },
                              child: const Text('Search'),
                            ),
                            if (displayedTickets.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisSize: MainAxisSize.min,
                                children: displayedTickets
                                    .asMap()
                                    .entries
                                    .expand((ticketEntry) => ticketEntry
                                            .value.departureTimes
                                            .map((departureTime) {
                                          final int ticketIndex =
                                              ticketEntry.key;
                                          return Column(
                                            children: [
                                              ListTile(
                                                title: Text(
                                                  '${ticketEntry.value.startStation} - ${ticketEntry.value.destinationStation}',
                                                ),
                                                subtitle: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                        'Company: ${ticketEntry.value.companyName}'),
                                                    Text(
                                                        'Route: ${ticketEntry.value.routeName}'),
                                                    Text(
                                                        'Ticket Price: \$${ticketEntry.value.ticketPrice.toStringAsFixed(2)}'),
                                                    Text(
                                                        'Departure Time: $departureTime'),
                                                  ],
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  IconButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        if (displayedTickets[
                                                                    ticketIndex]
                                                                .quantity >
                                                            1) {
                                                          displayedTickets[
                                                                  ticketIndex]
                                                              .quantity--;
                                                        }
                                                      });
                                                    },
                                                    icon: Icon(Icons.remove),
                                                  ),
                                                  Container(
                                                    width: 40,
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      '${displayedTickets[ticketIndex].quantity}',
                                                      style: TextStyle(
                                                          fontSize: 18),
                                                    ),
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        displayedTickets[
                                                                ticketIndex]
                                                            .quantity++;
                                                      });
                                                    },
                                                    icon: Icon(Icons.add),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      // Implementáció a jegyek vásárlására
                                                      // Például: buyTickets(ticketIndex);
                                                    },
                                                    child: const Text(
                                                        'Buy Ticket'),
                                                  ),
                                                ],
                                              ),
                                              const Divider(),
                                            ],
                                          );
                                        }))
                                    .toList(),
                              ),
                          ],
                        ),
                      ),
                    );
                  }
                }),
          ),
        ));
  }
}
