import 'package:flutter/material.dart';
import 'package:pos_app/gps.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'scan_ticket.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
          useMaterial3: true,
        ),
        home: const Login(),
        routes: {
          '/scan_ticket': (context) => const ScanTicket(),
          '/gps': (context) => const GPS(),
        });
  }
}

Future<void> saveData(key, value) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString(key, value);
}

Future<String?> readData(String key) async {
  final prefs = await SharedPreferences.getInstance();
  final value = prefs.getString(key);
  return value;
}

Future<void> removeData(String key) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(key);
}
