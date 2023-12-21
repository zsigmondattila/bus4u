import 'package:flutter/material.dart';
import 'package:bus4u/NavBar.dart';
import 'package:bus4u/pages/home_page.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
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
          )),
      title: 'bus4u',
      home: AnimatedSplashScreen(
        splash: Image.asset('assets/images/logo-text.png'),
        nextScreen: const MyHomePage(),
        splashTransition: SplashTransition.fadeTransition,
        backgroundColor: Colors.white,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Widget currentPage = const HomePage();

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
      ),
      body: currentPage,
    );
  }
}
