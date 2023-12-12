import 'package:flutter/material.dart';
import 'package:bus4u/pages/home_page.dart';
import 'package:bus4u/pages/schedules_page.dart';
import 'package:bus4u/pages/stations_page.dart';
import 'package:bus4u/pages/info_page.dart';
import 'package:bus4u/pages/account_page.dart';

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
            InfoPage(),
            AccountPage(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.shifting, // Shifting
          selectedItemColor: const Color.fromARGB(255, 24, 13, 1),
          unselectedItemColor: Colors.black,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
                backgroundColor: Colors.orange),
            BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month),
                label: 'Schedules',
                backgroundColor: Colors.orange),
            BottomNavigationBarItem(
                icon: Icon(Icons.location_pin),
                label: 'Stations',
                backgroundColor: Colors.orange),
            BottomNavigationBarItem(
                icon: Icon(Icons.info),
                label: 'Info',
                backgroundColor: Colors.orange),
            BottomNavigationBarItem(
                icon: Icon(Icons.account_circle),
                label: 'Account',
                backgroundColor: Colors.orange),
          ],
          currentIndex: currentPage,
          onTap: (int index) {
            setState(() {
              currentPage = index;
              
              /*_pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease,
              );*/
            });
          },
        ),
      ),
    );
  }
}
