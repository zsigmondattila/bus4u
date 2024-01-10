import 'package:bus4u/pages/login_page.dart';
import 'package:bus4u/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:bus4u/main.dart';
import 'package:http/http.dart' as http;

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool isLoggedIn = MyApp.isLoggedIn;

  Future<void> signOut() async {
    try {
      final response = await http.delete(
        Uri.parse('https://bus4u.fast-table.com/auth/sign_out'),
      );
      if (response.statusCode == 200) {
        setState(() {
          MyApp.isLoggedIn = false;
        });
      } else {
        print('Logout failed');
      }
    } catch (e) {
      print('Error during logout: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 25),
            if (isLoggedIn)
              Column(
                children: [
                  Text(
                    'Welcome!',
                    style: TextStyle(fontSize: 24, color: Colors.black),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      await signOut();
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.orange,
                      padding: EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 20,
                      ),
                    ),
                    child: Text(
                      'Sign Out',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (BuildContext context) {
                          return const LoginPage();
                        }),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.orange[800],
                      padding: EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 20,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.login, size: 40),
                        SizedBox(height: 8),
                        Text(
                          'Sign In',
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                   ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (BuildContext context) {
                          return const RegisterPage();
                        }),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.orange[800],
                      padding: EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 20,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.person_add, size: 40),
                        SizedBox(height: 8),
                        Text(
                          'Register',
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}