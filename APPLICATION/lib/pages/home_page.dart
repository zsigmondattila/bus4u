import 'package:bus4u/main.dart';
import 'package:bus4u/models/ticket.dart';
import 'package:bus4u/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
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
  var logger = Logger();
  String? token;
  String? user_uid;

  late String selectedDate = '';
  late String selectedTime = '';

  List<Map<String, dynamic>> cities = [];
  List<Map<String, dynamic>> stations = [];
  List<Map<String, dynamic>> destinationCities = [];
  List<Map<String, dynamic>> destinationStations = [];
  List<Ticket> displayedTickets = [];

  DateTime selectedDateTime = DateTime.now();
  bool noAvailableRoutes = false;

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

  Future<void> loadCities() async {
    try {
      cities = await getCities();
      destinationCities = cities;
      selectedDate = DateFormat('yyyy-MM-dd').format(selectedDateTime);
      selectedTime = DateFormat('HH:mm').format(selectedDateTime);
    } catch (e) {
      logger.e('Error loading cities: $e');
    }
    setState(() {});
  }

  Future<void> loadDestinationCities() async {
    try {
      destinationCities = await getCities();
    } catch (e) {
      logger.e('Error loading cities: $e');
    }
    setState(() {});
  }

  Future<void> loadStationsForCity(String cityUid) async {
    try {
      stations = await getStationsByCity(cityUid);
    } catch (e) {
      logger.e('Error loading stations: $e');
    }
    setState(() {});
  }

  Future<void> loadDestinationStations(String cityUid) async {
    try {
      destinationStations = await getStationsByCity(cityUid);
    } catch (e) {
      logger.e('Error loading destination stations: $e');
    }
    setState(() {});
  }

  Future<void> fetchRoutes() async {
    if (selectedStartCity == null || selectedDestinationCity == null) {
      logger.w('Please select all cities and stations');
      return;
    }
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.bus4u.online/v1/get_available_tickets?start_city_uid=$selectedStartCity&start_station_uid=$selectedStartStation&destination_city_uid=$selectedDestinationCity&destination_station_uid=$selectedDestinationStation&date=$selectedDate&time=$selectedTime',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> ticketsData = json.decode(response.body);

        List<Ticket> tickets = [];

        for (var ticketData in ticketsData) {
          Ticket ticket = Ticket(
            startStation: ticketData['from_station'],
            startStationUID: ticketData['from_station_uid'],
            destinationStation: ticketData['to_station'],
            destinationStationUID: ticketData['to_station_uid'],
            companyName: ticketData['company_name'],
            companyUID: ticketData['company_uid'],
            routeName: ticketData['route_name'],
            routeUID: ticketData['route_uid'],
            ticketPrice: double.parse(ticketData['ticket_price']),
            departureTime: ticketData['departure_time'],
            quantity: 1,
          );
          tickets.add(ticket);
          print("price ${ticket.ticketPrice}");
        }
        setState(() {
          noAvailableRoutes = tickets.isEmpty;
          displayedTickets = tickets;
        });
      } else {
        throw Exception('Failed to load tickets');
      }
    } catch (e) {
      logger.e('Error fetching tickets: $e');
    }
  }

  Future<void> buyTicket(int ticketIndex) async {
    try {
      final Ticket selectedTicket = displayedTickets[ticketIndex];
      token = await readData('token');
      user_uid = await readData('user_uid');

      print("uuuid ${user_uid}");

      final Map<String, dynamic> ticketData = {
        "quantity": selectedTicket.quantity,
        "ticket_price": selectedTicket.ticketPrice,
        "company_uid": selectedTicket.companyUID,
        "user_uid": user_uid,
        "type": "normal",
        "route_uid": selectedTicket.routeUID,
        "from_station_uid": selectedTicket.startStationUID,
        "to_station_uid": selectedTicket.destinationStationUID,
      };

      print(ticketData);

      final response = await http.post(
        Uri.parse('https://api.bus4u.online/v1/generate_a_ticket'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': token ?? ""
        },
        body: jsonEncode(ticketData),
      );

      if (response.statusCode == 200) {
        logger.i('Ticket generated successfully');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Ticket ordered successfully!'),
              content: Text(
                'You can manage your tickets on the website',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
                TextButton(
                  onPressed: () {
                    launchUrl(Uri.parse('https://bus4u.online/tickets'));
                    Navigator.of(context).pop();
                  },
                  child: Text('View tickets'),
                ),
              ],
            );
          },
        );
      } else if (response.statusCode == 401) {
        logger.e('Failed to generate ticket');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Unauthorized'),
              content: Text('Please log in before buying!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ));
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
        print(response.statusCode);
      } else {
        print(response.body);
      }
    } catch (e) {
      logger.e('Error buying ticket: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    loadCities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('From', style: TextStyle(fontSize: 18)),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _tempSelectedStartCity ?? selectedStartCity,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(8.0),
                  labelText: 'Start City',
                  border: OutlineInputBorder(),
                ),
                onChanged: (String? value) {
                  setState(() {
                    _tempSelectedStartCity = value;
                    _tempSelectedStartStation = null;
                    selectedStartStation = null;
                    if (value != null) {
                      stations = [];
                      selectedStartCity = value;
                      loadStationsForCity(value);
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
              // From megálló kiválasztása
              DropdownButtonFormField<String>(
                value: _tempSelectedStartStation ?? selectedStartStation,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(8.0),
                  labelText: 'Start Station',
                  border: OutlineInputBorder(),
                ),
                onChanged: (String? value) {
                  _tempSelectedStartStation = value;
                },
                items: stations.map((Map<String, dynamic> station) {
                  return DropdownMenuItem<String>(
                    value: station['station_uid'],
                    child: Text(station['name']),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              const Text('To', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _tempSelectedDestinationCity ?? selectedDestinationCity,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(8.0),
                  labelText: 'Destination City',
                  border: OutlineInputBorder(),
                ),
                onChanged: (String? value) {
                  setState(() {
                    _tempSelectedDestinationCity = value;
                    if (value != null) {
                      selectedDestinationCity = value;
                      _tempSelectedDestinationStation = null;
                      selectedDestinationStation = null;
                      loadDestinationStations(value);
                    }
                  });
                },
                items: destinationCities.map((Map<String, dynamic> city) {
                  return DropdownMenuItem<String>(
                    value: city['city_uid'],
                    child: Text(city['name']),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              // To megálló kiválasztása
              DropdownButtonFormField<String>(
                value: _tempSelectedDestinationStation ??
                    selectedDestinationStation,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(8.0),
                  labelText: 'Destination Station',
                  border: OutlineInputBorder(),
                ),
                onChanged: (String? value) {
                  _tempSelectedDestinationStation = value;
                },
                items: destinationStations.map((Map<String, dynamic> station) {
                  return DropdownMenuItem<String>(
                    value: station['station_uid'],
                    child: Text(station['name']),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              // Dátum és idő kiválasztása
              const Text('Departure', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              TextFormField(
                readOnly: true,
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDateTime,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null && pickedDate != selectedDateTime) {
                    final TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
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
                        selectedDate =
                            DateFormat('yyyy-MM-dd').format(selectedDateTime);
                        selectedTime =
                            DateFormat('HH:mm').format(selectedDateTime);
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
                  contentPadding: EdgeInsets.all(8.0),
                  labelText: 'Date & Time',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  setState(() {
                    selectedStartCity = _tempSelectedStartCity;
                    selectedStartStation = _tempSelectedStartStation;
                    selectedDestinationCity = _tempSelectedDestinationCity;
                    selectedDestinationStation =
                        _tempSelectedDestinationStation;
                    selectedDate = _tempSelectedDate.isEmpty
                        ? selectedDate
                        : _tempSelectedDate;
                    selectedTime = _tempSelectedTime.isEmpty
                        ? selectedTime
                        : _tempSelectedTime;
                  });
                  fetchRoutes();
                },
                style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsets>(
                  const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                )),
                child: const Text('Search'),
              ),
              SizedBox(height: 20),
              if (noAvailableRoutes)
                Text(
                    "There are no available routes, try again with other stations or date"),
              if (displayedTickets.isNotEmpty) ...[
                const Text('Available buses', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          width: 2),
                    ),
                    child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: displayedTickets.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          Ticket ticket = displayedTickets[index];
                          DateTime depTimestamp =
                              DateTime.fromMillisecondsSinceEpoch(
                                  ticket.departureTime * 1000,
                                  isUtc: true);
                          String departureTime =
                              '${depTimestamp.hour}:${depTimestamp.minute.toString().padLeft(2, '0')}';
                          return ListTile(
                            title: Text(
                              '${ticket.startStation} - ${ticket.destinationStation}',
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Company: ${ticket.companyName}'),
                                Text('Route: ${ticket.routeName}'),
                                Text(
                                    'Ticket Price: ${ticket.ticketPrice.toStringAsFixed(2)} RON'),
                                Text('Departure Time: ${departureTime}'),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          if (ticket.quantity > 1) {
                                            ticket.quantity--;
                                          }
                                        });
                                      },
                                      icon: const Icon(Icons.remove),
                                    ),
                                    Container(
                                      width: 40,
                                      alignment: Alignment.center,
                                      child: Text(
                                        '${ticket.quantity}',
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          ticket.quantity++;
                                        });
                                      },
                                      icon: const Icon(Icons.add),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        buyTicket(index);
                                      },
                                      child: const Text('Buy Ticket'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
