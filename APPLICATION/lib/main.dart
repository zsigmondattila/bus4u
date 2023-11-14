import 'package:bus4u/pages/home_page.dart';
import 'package:bus4u/pages/schedules_page.dart';
import 'package:bus4u/pages/stations_page.dart';
import 'package:bus4u/pages/about_page.dart';
import 'package:bus4u/pages/account_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const RootPage(),
    );
  }
}

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int currentPage = 0;
  List<Widget> pages = const [
    HomePage(),
    SchedulesPage(),
    StationsPage(),
    AboutPage(),
    AccountPage(),
  
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 10,
        title: Container(
          padding: const EdgeInsets.fromLTRB(5,0,200,0),
          child: Image.asset('assets/images/logo-text.png'),
        ),
        centerTitle: true,
        
      ),
      body: pages[currentPage],
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.calendar_month), label: 'Schedules'),
          NavigationDestination(
              icon: Icon(Icons.location_pin), label: 'Stations'),
          NavigationDestination(icon: Icon(Icons.info), label: 'About'),
          NavigationDestination(
              icon: Icon(Icons.account_circle), label: 'Account'),
        ],
        onDestinationSelected: (int index) {
          setState(() {
          currentPage = index;
          });
        },
        selectedIndex: currentPage,
      ),
    );
  }
}
