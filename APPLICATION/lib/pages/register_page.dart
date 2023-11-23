import 'package:bus4u/components/my_text_field.dart';
import 'package:bus4u/components/square_tile.dart';
//import 'package:bus4u/postman/api_service.dart';
//import 'dart:convert';
import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final repassController = TextEditingController();

  //register method
 /* _register(context) async {
    var data = {
      'name': nameController.text,
      'email': emailController.text,
      'password': passController.text,
    };

    var res = await CallApi().postData(data, 'register');
    var body = json.decode(res.body);
    if(body[null]){
      TextButton(
            child: const Text('Approve'),
            onPressed: () {
              Navigator.of(context).pop();
            },
            );
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            Image.asset(
              'assets/images/logo-text.png',
              height: 40,
            ),
          ]),
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  const Icon(
                    Icons.person_add_rounded,
                    size: 100,
                  ),
                  const SizedBox(height: 25),
                  Text(
                    "Welcome",
                    style: TextStyle(color: Colors.grey[800], fontSize: 16),
                  ),
                  const SizedBox(height: 25),
                  MyTextField(
                      controller: emailController,
                      hintText: 'Email',
                      obscureText: false),
                  const TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Firstname',
                    ),
                  ),
                  const SizedBox(height: 25),
                  const TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Lastname',
                    ),
                  ),
                  const SizedBox(height: 25),
                  const TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Username',
                    ),
                  ),
                  const SizedBox(height: 25),
                  const TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                    ),
                  ),
                  const SizedBox(height: 25),
                  const TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Confirm password',
                    ),
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: () {
                     // _register(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 120, vertical: 25),
                    ),
                    child: const Text(
                      'Register',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[800],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text('Or register with'),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[800],
                        ),
                      )
                    ]),
                  ),
                  const SizedBox(height: 25),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SquareTile(
                        imagePath: 'assets/images/google.png',
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      SquareTile(
                        imagePath: 'assets/images/apple.png',
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "You have account?",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        "Login here",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                ],
              ),
            ),
          ),
        ));
  }
}
