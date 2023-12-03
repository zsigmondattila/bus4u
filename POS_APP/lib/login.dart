import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<void> loginUser(String email, String password, BuildContext context) async {
  final response = await http.post(
    Uri.parse('https://bus4u.fast-table.com/admin/sign_in'),
    body: {
      'email': email,
      'password': password,
    },
  );

  if (response.statusCode == 200) {
    print('Sikeres bejelentkezés: ${response.body}');
    Navigator.pushNamed(context, '/scan_ticket');
  } else {
    print('Bejelentkezési hiba: ${response.statusCode}');
    // Sikertelen bejelentkezés esetén párbeszédpanel megjelenítése
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
      appBar: AppBar(
        title: Text("Bus4U POS"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  email = value;
                });
              },
              decoration: InputDecoration(
                labelText: "E-mail",
              ),
            ),
            SizedBox(height: 16.0),
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
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                loginUser(email, password, context);
              },
              child: Text("Sign in"),
            ),
          ],
        ),
      ),
    );
  }
}
