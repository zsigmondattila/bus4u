import 'package:bus4u/pages/about_page.dart';
import 'package:bus4u/pages/home_page.dart';
import 'package:bus4u/pages/login_page.dart';
import 'package:bus4u/pages/schedules_page.dart';
import 'package:bus4u/pages/stations_page.dart';
import 'package:bus4u/pages/ticket_page.dart';
import 'package:bus4u/pages/tracking_page.dart';
import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  final Function(Widget) onSelect;
  const NavBar({Key? key, required this.onSelect}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const UserAccountsDrawerHeader(
            accountName: Text('Account name'),
            accountEmail: Text('example@gmail.com'),
            decoration: BoxDecoration(
              color: Colors.orange,
              image: DecorationImage(
                  image: AssetImage('assets/images/logo-text.png')),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              onSelect(const HomePage());
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: const Text('Schedules'),
            onTap: () {
              onSelect(const SchedulesPage());
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.location_pin),
            title: const Text('Stations'),
            onTap: () {
              onSelect(const StationsPage());
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.label_rounded),
            title: const Text('My tickets'),
            onTap: () {
              onSelect(const TicketPage());
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.directions_bus),
            title: const Text('Tracking bus'),
            onTap: () {
              onSelect(const TrackingPage());
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              onSelect(const AboutPage());
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Account'),
            leading: const Icon(Icons.account_circle),
            onTap: () {
              onSelect(const LoginPage());
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
