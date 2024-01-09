import 'package:bus4u/pages/about_page.dart';
import 'package:bus4u/pages/account_page.dart';
import 'package:bus4u/pages/home_page.dart';
import 'package:bus4u/pages/schedules_page.dart';
import 'package:bus4u/pages/stations_page.dart';
import 'package:bus4u/pages/ticket_page.dart';
import 'package:bus4u/pages/tracking_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NavBar extends StatelessWidget {
  final Function(Widget) onSelect;
  final bool isLoggedIn;

  const NavBar({
    Key? key,
    required this.onSelect,
    required this.isLoggedIn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(50.0),
            child: Container(
              width: 100,
              height: 100,
              child: const Icon(
                Icons.person_outline,
                size: 100,
                color: Colors.black,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListTile(
              leading: const Icon(Icons.home, color: Colors.orange, size: 35),
              title: const Text(
                'Home',
                style: TextStyle(fontSize: 20),
              ),
              onTap: () {
                onSelect(const HomePage());
                Navigator.pop(context);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListTile(
              leading: const Icon(Icons.calendar_month,
                  color: Colors.orange, size: 35),
              title: const Text(
                'Schedules',
                style: TextStyle(fontSize: 20),
              ),
              onTap: () {
                onSelect(const SchedulesPage());
                Navigator.pop(context);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListTile(
              leading: const Icon(Icons.location_pin,
                  color: Colors.orange, size: 35),
              title: const Text(
                'Stations',
                style: TextStyle(fontSize: 20),
              ),
              onTap: () {
                onSelect(const StationsPage());
                Navigator.pop(context);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListTile(
              leading: const Icon(Icons.label_rounded,
                  color: Colors.orange, size: 35),
              title: const Text(
                'My tickets',
                style: TextStyle(fontSize: 20),
              ),
              onTap: () {
                launch('https://bus4u.netlify.com/tickets');
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListTile(
              leading: const Icon(Icons.directions_bus,
                  color: Colors.orange, size: 35),
              title: const Text(
                'Live map',
                style: TextStyle(fontSize: 20),
              ),
              onTap: () {
                onSelect(const TrackingPage());
                Navigator.pop(context);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListTile(
              leading: const Icon(Icons.verified_user,
                  color: Colors.orange, size: 35),
              title: const Text(
                'Profile',
                style: TextStyle(fontSize: 20),
              ),
              onTap: () {
                onSelect(const AccountPage());
                Navigator.pop(context);
              },
            ),
          ),
          Expanded(
            child: Align(
              alignment: FractionalOffset.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListTile(
                  title: const Text(
                    'About',
                    style: TextStyle(fontSize: 20),
                  ),
                  leading:
                      const Icon(Icons.info, color: Colors.orange, size: 35),
                  onTap: () {
                    onSelect(const AboutPage());
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
