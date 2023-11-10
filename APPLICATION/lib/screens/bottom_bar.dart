import 'package:bus4u/screens/calendar_screeen.dart';
import 'package:bus4u/screens/home_page.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});
  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _selectedIndex = 0;
  static final List<Widget> _widgetOptions = <Widget>[
    const Homepage(),
    const Calendarcreen(),
    const Text("Location"),
    const Text("Info"),
    const Text("Profile")
  ];
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bus4U"),
        backgroundColor: Colors.orange,
      ),
      body: Container(
        child: _widgetOptions[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
          onTap: _onItemTapped,
          elevation: 10,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedItemColor: Colors.blueGrey,
          unselectedItemColor: const Color(0xFF526480),
          //  type: BottomNavigationBarType.shifting,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(FluentSystemIcons.ic_fluent_home_regular),
                activeIcon: Icon(FluentSystemIcons.ic_fluent_home_filled),
                label: "home"),
            BottomNavigationBarItem(
                icon: Icon(FluentSystemIcons.ic_fluent_calendar_regular),
                activeIcon: Icon(FluentSystemIcons.ic_fluent_calendar_filled),
                label: "calendar"),
            BottomNavigationBarItem(
                icon: Icon(FluentSystemIcons.ic_fluent_location_regular),
                activeIcon: Icon(FluentSystemIcons.ic_fluent_location_filled),
                label: "location"),
            BottomNavigationBarItem(
                icon: Icon(FluentSystemIcons.ic_fluent_info_regular),
                activeIcon: Icon(FluentSystemIcons.ic_fluent_info_filled),
                label: "info"),
            BottomNavigationBarItem(
                icon: Icon(FluentSystemIcons.ic_fluent_person_add_regular),
                activeIcon: Icon(FluentSystemIcons.ic_fluent_person_add_filled),
                label: "profile")
          ]),
    );
  }
}
