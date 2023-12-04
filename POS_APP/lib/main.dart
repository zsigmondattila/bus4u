import 'package:flutter/material.dart';
import 'package:pos_app/gps.dart';
import 'package:pos_app/home.dart';
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
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: Login(),
        routes: {
          '/home': (context) => Home(),
          '/scan_ticket': (context) => ScanTicket(),
          '/gps': (context) => GPS(),
        });
  }
}
