import 'package:bus4u/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NavBar extends StatelessWidget {
  final void Function(int) onSelect;
  final int selectedIndex;

  const NavBar({
    super.key,
    required this.onSelect,
    this.selectedIndex = 0,
  });

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
        Consumer<UserService>(
          builder: (context, user, child) => user.isLoggedIn
              ? Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.account_circle_outlined,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(
                        height: 8.0,
                      ),
                      Text('${user.firstName} ${user.lastName}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant)),
                    ],
                  ),
                )
              : child!,
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Image.asset(
              'assets/images/logo-text.png',
              height: 64,
            ),
          ),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.home),
          label: Text(
            'Home',
          ),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.calendar_month),
          label: Text(
            'Schedule',
          ),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.location_pin),
          label: Text(
            'Stations',
          ),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.receipt),
          label: Text(
            'My Tickets',
          ),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.gps_fixed),
          label: Text(
            'Live map',
          ),
        ),
        const NavigationDrawerDestination(
          label: Text(
            'About',
          ),
          icon: Icon(Icons.info_outline),
        ),
      ],
    );
  }
}
