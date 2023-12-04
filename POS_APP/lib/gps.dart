import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'package:pos_app/main.dart';

class GPS extends StatefulWidget {
  @override
  _GPSState createState() => _GPSState();
}

class _GPSState extends State<GPS> {
  final Location _location = Location();
  bool _isGpsEnabled = false;
  bool _isSwitched = false;
  late StreamSubscription<LocationData> _locationSubscription;
  late Timer _timer;
  String _currentLatitude = '';
  String _currentLongitude = '';
  String? selectedBus;
  List<String> _busList = [];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 20), (timer) {
      _sendCurrentLocation();
    });
    _fetchBuses();
  }

  Future<void> _fetchBuses() async {
      final String companyUid = await readData("company") ?? "";
      final response = await http.get(
        Uri.parse(
            'https://bus4u.fast-table.com/v1/admin/get_buses_of_a_company?company_uid=$companyUid'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> buses = json.decode(response.body);
        final List<String> plates = buses.map<String>((dynamic bus) {
          return (bus as Map<String, dynamic>)['license_plate'] as String;
        }).toList();
        setState(() {
          _busList = plates;
        });
      } else {
        print('Error: ${response.statusCode}');
      }  
  }

  Future<void> enableGps() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        throw Exception('GPS service is not enabled.');
      }
    }

    PermissionStatus permission = await _location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await _location.requestPermission();
      if (permission != PermissionStatus.granted) {
        throw Exception('Location permission not granted.');
      }
    }

    setState(() {
      _isGpsEnabled = true;
    });

    _startLocationUpdates();
  }

  void _startLocationUpdates() {
    _locationSubscription =
        _location.onLocationChanged.listen((LocationData currentLocation) {
      if (_isSwitched) {
        setState(() {
          _currentLatitude = currentLocation.latitude.toString();
          _currentLongitude = currentLocation.longitude.toString();
        });
      }
    });
  }

  void _sendCurrentLocation() async {
    if (_isGpsEnabled && _isSwitched && selectedBus != null) {
      final Map<String, dynamic> requestBody = {
        'license_plate': selectedBus!,
        'latitude': _currentLatitude,
        'longitude': _currentLongitude,
      };

      try {
        final response = await http.post(
          Uri.parse('https://bus4u.fast-table.com/v1/admin/set_location'),
          body: jsonEncode(requestBody),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          print('Location sent successfully.');
        } else {
          print('Error sending location: ${response.statusCode}');
        }
      } catch (e) {
        print('Error sending location: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            DropdownButton<String>(
              hint: Text('Válassz egy buszt'),
              value: selectedBus,
              onChanged: (String? newValue) {
                setState(() {
                  selectedBus = newValue!;
                });
              },
              items: _busList.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Tracking'),
                Switch(
                  value: _isSwitched,
                  onChanged: (value) {
                    setState(() {
                      _isSwitched = value;
                      if (_isSwitched) {
                        enableGps();
                      } else {
                        stopGpsUpdates();
                      }
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            if (_isSwitched)
              Text(
                'Latitude: $_currentLatitude, Longitude: $_currentLongitude',
              ),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/scan_ticket');
              },
              child: Text('Ticket scanner'),
            ),
          ],
        ),
      ),
    );
  }

  void stopGpsUpdates() {
    _locationSubscription.cancel();
  }

  @override
  void dispose() {
    _locationSubscription.cancel();
    _timer.cancel();
    super.dispose();
  }
}
