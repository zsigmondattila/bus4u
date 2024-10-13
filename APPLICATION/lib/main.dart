import 'package:bus4u/nav_bar.dart';
import 'package:bus4u/pages/about_page.dart';
import 'package:bus4u/pages/login_page.dart';
import 'package:bus4u/pages/register_page.dart';
import 'package:bus4u/pages/schedules_page.dart';
import 'package:bus4u/pages/stations_page.dart';
import 'package:bus4u/pages/tickets_page.dart';
import 'package:bus4u/pages/tracking_page.dart';
import 'package:bus4u/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:bus4u/pages/home_page.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserService(),
      child: MaterialApp(
        theme: ThemeData.from(
                colorScheme: ColorScheme.fromSeed(
                    seedColor: Colors.orange, background: Colors.white))
            .copyWith(
          inputDecorationTheme: const InputDecorationTheme(
            contentPadding: EdgeInsets.all(10.0),
            border: OutlineInputBorder(),
          ),
        ),
        title: 'Bus4U',
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final int currentPage;
  final List<Widget> pages = const [
    HomePage(),
    SchedulesPage(),
    StationsPage(),
    TicketPage(),
    TrackingPage(),
    AboutPage(),
  ];
  final List<String> pageTitles = const [
    'Plan your trip',
    'Schedule',
    'Stations',
    'My tickets',
    'Live map',
    'About',
  ];

  const MyHomePage({
    super.key,
    this.currentPage = 0,
  });

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late int currentPage;

  @override
  void initState() {
    super.initState();
    currentPage = widget.currentPage;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            if (context.watch<UserService>().isLoggedIn)
              IconButton(
                onPressed:
                    Provider.of<UserService>(context, listen: false).signOut,
                icon: const Icon(Icons.logout),
                tooltip: 'Logout',
              )
            else ...[
              IconButton(
                  onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      ),
                  icon: const Icon(Icons.login),
                  tooltip: 'Login'),
              IconButton(
                  onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterPage(),
                        ),
                      ),
                  icon: const Icon(Icons.person_add),
                  tooltip: 'Register'),
            ],
            const SizedBox(width: 10),
          ],
          backgroundColor: Colors.white,
          shadowColor: Colors.grey,
          titleSpacing: 8,
          title: Text(
            widget.pageTitles[currentPage],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        drawer: NavBar(
          selectedIndex: currentPage,
          onSelect: (page) {
            setState(() {
              currentPage = page;
            });
            Navigator.pop(context);
          },
        ),
        body: widget.pages[currentPage],
      ),
    );
  }
}
