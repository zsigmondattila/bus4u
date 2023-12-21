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
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(50.0),
            child: Container(
                      width: 100,
                      height: 100,
                      
                      child:
                          const Icon(Icons.person_outline, size: 100, color: Colors.black),
                    ),
          ),
          ListTile(
            leading: const Icon(Icons.home,color: Colors.orange,),
            title: const Text('Home'),
            onTap: () {
              onSelect(const HomePage());
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month,color: Colors.orange,),
            title: const Text('Schedules'),
            onTap: () {
              onSelect(const SchedulesPage());
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.location_pin,color: Colors.orange,),
            title: const Text('Stations'),
            onTap: () {
              onSelect(const StationsPage());
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.label_rounded,color: Colors.orange,),
            title: const Text('My tickets'),
            onTap: () {
              onSelect(const TicketPage());
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.directions_bus,color: Colors.orange,),
            title: const Text('Tracking bus'),
            onTap: () {
              onSelect(const TrackingPage());
              Navigator.pop(context);
            },
          ),
          Expanded(
            child: Align(
                alignment: FractionalOffset.bottomCenter,
                child: ListTile(
                  title: const Text('About'),
                  leading: const Icon(Icons.info,color: Colors.orange,),
                  onTap: () {
                    onSelect(const AboutPage());
                    Navigator.pop(context);
                  },
                  
                ),
              ),
          ),
          
        ],
      ),
    );
  }
}
