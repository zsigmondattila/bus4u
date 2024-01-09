import 'package:bus4u/NavBar.dart';
import 'package:flutter/material.dart';
import 'package:bus4u/pages/home_page.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static bool isLoggedIn = false;
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.white,
        primarySwatch: MaterialColor(
          0xFFEF6C00,
          <int, Color>{
            50: Color(0xFFFFF3E0),
            100: Color(0xFFFFE0B2),
            200: Color(0xFFFFCC80),
            300: Color(0xFFFFB74D),
            400: Color(0xFFFFA726),
            500: Color(0xFFF57C00),
            600: Color(0xFFF57C00),
            700: Color(0xFFF57C00),
            800: Color(0xFFEF6C00),
            900: Color(0xFFE65100),
          },
        ),
      ),
      title: 'bus4u',
      home: AnimatedSplashScreen(
        splash: Image.asset('assets/images/logo-text.png'),
        nextScreen: MyHomePage(
          currentPage: const HomePage(),
          isLoggedIn: isLoggedIn,
        ),
        splashTransition: SplashTransition.fadeTransition,
        backgroundColor: Colors.white,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final Widget? currentPage;
  final bool isLoggedIn;

  const MyHomePage({
    Key? key,
    this.currentPage,
    this.isLoggedIn = false,
  }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Widget currentPage;

  void signOut() async {
    try {
      String? uid = await readData('user_uid');
      String? client = await readData('client');
      String? access_token = await readData('access_token');
      print('uid ${uid} client ${client} ');
      final response = await http.delete(
          Uri.parse('https://bus4u.fast-table.com/auth/sign_out'),
          body: {'uid': uid, 'client': client, 'access-token': access_token});
      if (response.statusCode == 200) {
        setState(() {
          MyApp.isLoggedIn = false;
          currentPage = const HomePage();
        });
      } else {
        print('Logout failed');
      }
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    currentPage = widget.currentPage!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Image.asset(
              'assets/images/logo-text.png',
              height: 40,
            ),
            if (MyApp.isLoggedIn)
              GestureDetector(
                onTap: signOut,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Icon(Icons.account_circle),
                    ),
                    Text(
                      'Sign Out',
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
          ],
        ),
        iconTheme: IconThemeData(color: Colors.orange[800]),
      ),
      drawer: NavBar(
        onSelect: (Widget page) {
          setState(() {
            currentPage = page;
          });
        },
        isLoggedIn: widget.isLoggedIn,
      ),
      body: currentPage,
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
