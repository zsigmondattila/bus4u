// ignore_for_file: prefer_const_constructors

import 'package:bus4u/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bus4u/main.dart';
import 'package:logger/logger.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.currentPage});

  final Widget? currentPage;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String email = "";
  String password = "";
  var logger = Logger();

  void signUserIn(String email, password) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.bus4u.online/auth/sign_in'),
        body: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        String token = response.headers['authorization'] ?? '';
        String userUid = response.headers['uid'] ?? '';
        String client = response.headers['client'] ?? '';
        String accessToken = response.headers['access-token'] ?? '';
        debugPrint("uiduser $userUid");
        saveData('token', token);
        saveData('user_uid', userUid);
        saveData('client', client);
        saveData('access_token', accessToken);

        MyApp.isLoggedIn = true;

        if (!context.mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MyHomePage(
              currentPage: 0,
              isLoggedIn: true,
            ),
          ),
        );
      } else {
        logger.e('failed');
        if (!context.mounted) return;
        showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Something wrong'),
            content: const Text('Email or password incorrect'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, 'Cancel'),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, 'OK'),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      logger.e(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Login',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 50),
                Image.asset(
                  'assets/images/logo-text.png',
                  height: 64,
                ),
                const SizedBox(height: 64),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      email = value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: "E-mail",
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      password = value;
                    });
                  },
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                  ),
                ),
                const SizedBox(height: 50),
                FilledButton(
                  onPressed: () {
                    signUserIn(email, password);
                  },
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsets>(
                      const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                const Text("Not a member?"),
                const SizedBox(height: 8),
                ElevatedButton(
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsets>(
                      const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return const RegisterPage();
                        },
                      ),
                    );
                  },
                  child: const Text('Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
