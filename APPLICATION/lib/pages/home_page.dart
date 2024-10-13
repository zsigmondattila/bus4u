import 'package:bus4u/main.dart';
import 'package:bus4u/models/route_ticket.dart';
import 'package:bus4u/pages/login_page.dart';
import 'package:bus4u/utils/state_management.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();

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
  String? userUid;

  late String selectedDate = '';
  late String selectedTime = '';

  List<Map<String, dynamic>> cities = [];
  List<Map<String, dynamic>> stations = [];
  List<Map<String, dynamic>> destinationCities = [];
  List<Map<String, dynamic>> destinationStations = [];
  List<RouteTicket> displayedRouteTickets = [];

  DateTime selectedDateTime = DateTime.now();
  bool _noAvailableRoutes = false;
  bool _isStartStationLoading = false;
  bool _isDestStationLoading = false;
  bool _isRoutesLoading = false;

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
      setState(() {
        destinationCities = cities;
        selectedDate = DateFormat('yyyy-MM-dd').format(selectedDateTime);
        selectedTime = DateFormat('HH:mm').format(selectedDateTime);
      });
    } catch (e) {
      logger.e('Error loading cities: $e');
    }
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
    _isStartStationLoading = true;
    try {
      stations = await getStationsByCity(cityUid);
    } catch (e) {
      logger.e('Error loading stations: $e');
    } finally {
      _isStartStationLoading = false;
    }
    setState(() {});
  }

  Future<void> loadDestinationStations(String cityUid) async {
    _isDestStationLoading = true;
    try {
      destinationStations = await getStationsByCity(cityUid);
    } catch (e) {
      logger.e('Error loading destination stations: $e');
    } finally {
      _isDestStationLoading = false;
    }
    setState(() {});
  }

  Future<void> fetchRoutes() async {
    if (selectedStartCity == null || selectedDestinationCity == null) {
      logger.w('Please select all cities and stations');
      return;
    }
    _isRoutesLoading = true;
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.bus4u.online/v1/get_available_tickets?start_city_uid=$selectedStartCity&start_station_uid=$selectedStartStation&destination_city_uid=$selectedDestinationCity&destination_station_uid=$selectedDestinationStation&date=$selectedDate&time=$selectedTime',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> ticketsData = json.decode(response.body);

        List<RouteTicket> tickets = [];

        for (var ticketData in ticketsData) {
          RouteTicket ticket = RouteTicket(
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
        }
        setState(() {
          _noAvailableRoutes = tickets.isEmpty;
          displayedRouteTickets = tickets;
        });
      } else {
        throw Exception('Failed to load tickets');
      }
    } catch (e) {
      logger.e('Error fetching tickets: $e');
    } finally {
      _isRoutesLoading = false;
    }
  }

  Future<void> buyRouteTicket(int ticketIndex) async {
    try {
      final RouteTicket selectedRouteTicket =
          displayedRouteTickets[ticketIndex];
      token = await readData('token');
      userUid = await readData('user_uid');

      final Map<String, dynamic> ticketData = {
        "quantity": selectedRouteTicket.quantity,
        "ticket_price": selectedRouteTicket.ticketPrice,
        "company_uid": selectedRouteTicket.companyUID,
        "user_uid": userUid,
        "type": "normal",
        "route_uid": selectedRouteTicket.routeUID,
        "from_station_uid": selectedRouteTicket.startStationUID,
        "to_station_uid": selectedRouteTicket.destinationStationUID,
      };

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
        if (!context.mounted) return;
        showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Successful order'),
              content: const Text(
                'Your new ticket(s) has been added to the collection, which can be viewed on the My Tickets page.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('OK'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('View tickets'),
                ),
              ],
            );
          },
        ).then((value) => value == true
            ? Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const MyHomePage(currentPage: 3)))
            : null);
      } else if (response.statusCode == 401) {
        logger.e('Failed to generate ticket');
        if (!context.mounted) return;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Unauthorized'),
              content: const Text('Please log in before buying a ticket'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ));
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('From', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _tempSelectedStartCity ?? selectedStartCity,
                  decoration: const InputDecoration(
                    labelText: 'Start City',
                  ),
                  validator: (value) =>
                      value == null ? 'This field is required' : null,
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
                const SizedBox(height: 16),
                // From megálló kiválasztása
                DropdownButtonFormField<String>(
                  value: _tempSelectedStartStation ?? selectedStartStation,
                  icon: _isStartStationLoading
                      ? const AspectRatio(
                          aspectRatio: 1,
                          child: CircularProgressIndicator.adaptive(
                            strokeWidth: 3.0,
                          ))
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Start Station',
                  ),
                  validator: (value) =>
                      value == null ? 'This field is required' : null,
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
                  value:
                      _tempSelectedDestinationCity ?? selectedDestinationCity,
                  decoration: const InputDecoration(
                    labelText: 'Destination City',
                  ),
                  validator: (value) =>
                      value == null ? 'This field is required' : null,
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
                const SizedBox(height: 16),
                // To megálló kiválasztása
                DropdownButtonFormField<String>(
                  value: _tempSelectedDestinationStation ??
                      selectedDestinationStation,
                  icon: _isDestStationLoading
                      ? const AspectRatio(
                          aspectRatio: 1,
                          child: CircularProgressIndicator.adaptive(
                            strokeWidth: 3.0,
                          ))
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Destination Station',
                  ),
                  validator: (value) =>
                      value == null ? 'This field is required' : null,
                  onChanged: (String? value) {
                    _tempSelectedDestinationStation = value;
                  },
                  items:
                      destinationStations.map((Map<String, dynamic> station) {
                    return DropdownMenuItem<String>(
                      value: station['station_uid'],
                      child: Text(station['name']),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                // Dátum és idő kiválasztása
                const Text('Date & time', style: TextStyle(fontSize: 18)),
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
                    if (pickedDate != null &&
                        pickedDate != selectedDateTime &&
                        context.mounted) {
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
                ),
                const SizedBox(height: 20),
                _isRoutesLoading
                    ? const Center(child: CircularProgressIndicator.adaptive())
                    : FilledButton(
                        onPressed: () {
                          if (!_formKey.currentState!.validate()) return;
                          setState(() {
                            selectedStartCity = _tempSelectedStartCity;
                            selectedStartStation = _tempSelectedStartStation;
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
                          fetchRoutes();
                        },
                        child: const Text('Search'),
                      ),
                const SizedBox(height: 32),
                if (_noAvailableRoutes)
                  const Text(
                      "There are no available routes, try again with other stations or date"),
                if (displayedRouteTickets.isNotEmpty) ...[
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
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: Theme.of(context).dividerColor, width: 1),
                      ),
                      child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: displayedRouteTickets.length,
                          separatorBuilder: (context, index) =>
                              Divider(color: Theme.of(context).dividerColor),
                          itemBuilder: (context, index) {
                            RouteTicket ticket = displayedRouteTickets[index];
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
                                  Text('Departure Time: $departureTime'),
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
                                          buyRouteTicket(index);
                                        },
                                        child: const Text('Buy ticket'),
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
      ),
    );
  }
}
