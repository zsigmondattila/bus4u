import 'package:bus4u/pages/login_page.dart';
import 'package:bus4u/pages/tracking_page.dart';
import 'package:flutter/material.dart';
import 'package:bus4u/pages/home_page.dart';
import 'package:bus4u/pages/schedules_page.dart';
import 'package:bus4u/pages/stations_page.dart';
import 'package:bus4u/pages/info_page.dart';
import 'package:bus4u/pages/ticket_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int currentPage = 0;
  late PageController _pageController;
  

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: Scaffold(
        appBar: AppBar(
          elevation: 10,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(
                'assets/images/logo-text.png',
                height: 40,
              ),
            ],
          ),
        ),
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          onPageChanged: (int index) {
            setState(() {
              currentPage = index;
            });
          },
          children: const [
            HomePage(),
            SchedulesPage(),
            StationsPage(),
            TicketPage(),
            TrackingPage(),
            InfoPage(),
            LoginPage(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed, 
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.black,
          backgroundColor: Colors.orange,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month),
                label: 'Schedules'),
            BottomNavigationBarItem(
                icon: Icon(Icons.location_pin),
                label: 'Stations'),
                BottomNavigationBarItem(
                icon: Icon(Icons.airplane_ticket),
                label: 'Ticket'),
            BottomNavigationBarItem(
                icon: Icon(Icons.spatial_tracking),
                label: 'Tracking'),
            BottomNavigationBarItem(
                icon: Icon(Icons.info),
                label: 'Info'),
            BottomNavigationBarItem(
                icon: Icon(Icons.account_circle),
                label: 'Account'),
          ],
          currentIndex: currentPage,
          onTap: (int index) {
            setState(() {
              currentPage = index;
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease,
              );
            });
          },
        ),
      ),
    );
  }
}
