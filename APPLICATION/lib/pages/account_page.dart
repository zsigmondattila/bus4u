import 'package:bus4u/pages/login_page.dart';
import 'package:bus4u/pages/register_page.dart';
import 'package:flutter/material.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 25),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (BuildContext context) {
                  return const LoginPage();
                }),
              );
            },
            child: const Text('Login'),
          ),
          const SizedBox(height: 25),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (BuildContext context) {
                  return RegisterPage();
                }),
              );
            },
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }
}
