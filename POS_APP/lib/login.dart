import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pos_app/main.dart';
import 'package:flutter_svg/flutter_svg.dart';

Future<void> loginUser(
    String email, String password, BuildContext context) async {
  final response = await http.post(
    Uri.parse('https://bus4u.fast-table.com/admin/sign_in'),
    body: {
      'email': email,
      'password': password,
    },
  );

  if (response.statusCode == 200) {
    Map<String, dynamic> responseBody = json.decode(response.body);
    String companyUid = responseBody['data']['company_uid'] ?? "";
    saveData("token", response.headers['authorization'] ?? '');
    saveData("company", companyUid);
    Navigator.pushNamed(context, '/gps');
  } else {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('POS'),
          content: Text('Incorrect e-mail or password'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String email = "";
  String password = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 80.0,
                  child: Image(image: AssetImage('assets/pos.png')),
                ),
                SizedBox(height: 80.0),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        email = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: "E-mail",
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
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
                ),
                SizedBox(height: 32.0),
                ElevatedButton(
                  onPressed: () {
                    loginUser(email, password, context);
                  },
                  style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(216, 67, 21, 1),
                  foregroundColor: Colors.white,
                ),
                  child: Text("Sign in"),
                ),
              ],
            ),
      ),
    );
  }
}

