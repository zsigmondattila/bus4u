import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:bus4u/pages/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  //sign user in method
  void signUserIn(String email, password) async {
    try {
      Response response = await post(
          Uri.parse('https://bus4u.fast-table.com/auth/sign_in'),
          body: {
            'email': email,
            'password': password,
          });
      if (response.statusCode == 200) {
        showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Successfull'),
            content: const Text('Logined successful'),
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
      } else {
        print('failed');
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
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  const Icon(
                    Icons.lock,
                    size: 100,
                  ),
                  const SizedBox(height: 25),
                  Text(
                    "Welcome back",
                    style: TextStyle(color: Colors.grey[800], fontSize: 16),
                  ),
                  const SizedBox(height: 25),
                  TextFormField(
                    controller: emailController,
                    obscureText: false,
                    decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: 'Email',
                        hintStyle: TextStyle(color: Colors.grey[500])),
                  ),
                  const SizedBox(height: 25),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: 'Password',
                        hintStyle: TextStyle(color: Colors.grey[500])),
                  ),
                  const SizedBox(height: 15),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: () {
                      signUserIn(emailController.text.toString(),
                          passwordController.text.toString());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 120, vertical: 25),
                    ),
                    child: const Text(
                      'Sign in',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 25),
                   Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       const Text(
                        "Not a member?",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 4),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (BuildContext context) {
                              return const RegisterPage();
                            }),
                          );
                        },
                        child: const Text('Register'),
                      ),
                      
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
