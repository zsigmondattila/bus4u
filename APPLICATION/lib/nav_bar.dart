import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  final void Function(int) onSelect;
  final bool isLoggedIn;
  final int selectedIndex;

  const NavBar({
    Key? key,
    required this.onSelect,
    required this.isLoggedIn,
    this.selectedIndex = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      selectedIndex: selectedIndex,
      onDestinationSelected: onSelect,
      tilePadding: const EdgeInsets.only(right: 8),
      indicatorShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(
            left: Radius.zero, right: Radius.circular(50)),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(32),
          child: Image.asset(
            'assets/images/logo-text.png',
            height: 48,
          ),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.home),
          label: const Text(
            'Home',
          ),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.calendar_month),
          label: const Text(
            'Schedule',
          ),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.location_pin),
          label: const Text(
            'Stations',
          ),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.receipt),
          label: const Text(
            'My tickets',
          ),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.gps_fixed),
          label: const Text(
            'Live map',
          ),
        ),
        NavigationDrawerDestination(
          label: const Text(
            'About',
          ),
          icon: const Icon(Icons.info_outline),
        ),
      ],
    );
  }
}
