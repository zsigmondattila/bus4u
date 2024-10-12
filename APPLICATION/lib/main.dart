import 'package:bus4u/nav_bar.dart';
import 'package:bus4u/pages/about_page.dart';
import 'package:bus4u/pages/login_page.dart';
import 'package:bus4u/pages/register_page.dart';
import 'package:bus4u/pages/schedules_page.dart';
import 'package:bus4u/pages/stations_page.dart';
import 'package:bus4u/pages/ticket_page.dart';
import 'package:bus4u/pages/tracking_page.dart';
import 'package:flutter/material.dart';
import 'package:bus4u/pages/home_page.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static bool isLoggedIn = false;
  static late String token;
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.from(
              colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.orange, background: Colors.white))
          .copyWith(
        inputDecorationTheme: const InputDecorationTheme(
          contentPadding: EdgeInsets.all(10.0),
          border: OutlineInputBorder(),
        ),
      ),
      title: 'bus4u',
      home: MyHomePage(
        isLoggedIn: isLoggedIn,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final int currentPage;
  final bool isLoggedIn;
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
    this.isLoggedIn = false,
  });

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late int currentPage;

  void signOut() async {
    try {
      String? uid = await readData('user_uid');
      String? client = await readData('client');
      String? accessToken = await readData('access_token');
      final response = await http.delete(
          Uri.parse('https://api.bus4u.online/auth/sign_out'),
          body: {'uid': uid, 'client': client, 'access-token': accessToken});
      if (response.statusCode == 200) {
        setState(() {
          MyApp.isLoggedIn = false;
          currentPage = 0;
        });
      } else {
        debugPrint('Logout failed');
      }
    } catch (e) {
      debugPrint('Error during logout: $e');
    }
  }

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
            if (MyApp.isLoggedIn)
              IconButton(
                onPressed: signOut,
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
          isLoggedIn: widget.isLoggedIn,
        ),
        body: widget.pages[currentPage],
      ),
    );
  }
}

Future<void> saveData(key, value) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString(key, value);
}

Future<String?> readData(String key) async {
  final prefs = await SharedPreferences.getInstance();
  final value = prefs.getString(key);
  return value;
}

Future<void> removeData(String key) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(key);
}
