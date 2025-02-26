import 'package:bus4u/pages/register_page.dart';
import 'package:bus4u/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:bus4u/main.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.currentPage});

  final Widget? currentPage;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String email = "";
  String password = "";
  bool isLoading = false;

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
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
            child: Column(
              children: [
                const SizedBox(height: 64),
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
                const SizedBox(height: 24),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      password = value;
                    });
                  },
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });
                    if (await Provider.of<UserService>(context, listen: false)
                        .signIn(email, password)) {
                      if (!context.mounted) return;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyHomePage(
                            currentPage: 0,
                          ),
                        ),
                      );
                    } else {
                      if (!context.mounted) return;
                      setState(() {
                        isLoading = false;
                      });
                      showDialog<String>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Login failed'),
                          content: const Text(
                              'The provided email address or password is incorrect.'),
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
                  },
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all<EdgeInsets>(
                      const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 14,
                      ),
                    ),
                  ),
                  child: isLoading
                      ? Container(
                          padding: const EdgeInsets.all(2.0),
                          height: 28,
                          width: 28,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3.0,
                          ))
                      : const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 64),
                const Text("Not a member?"),
                const SizedBox(height: 8),
                ElevatedButton(
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
