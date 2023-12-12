import 'package:flutter/material.dart';
import 'package:http/http.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmpassController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  void login(String email, password, confirmpassword, firstname) async {
    try {
      Response response =
          await post(Uri.parse('https://bus4u.fast-table.com/auth'), body: {
        'email': email,
        'password': password,
        'password_confirmation': confirmpassword,
        'firstname': firstname,
      });
      if (response.statusCode == 200) {
        showDialog<String>(
          context: context,
          builder: ( context) => AlertDialog(
            title: const Text('Successfull'),
            content: const Text('You created account successfully, now you can sign in'),
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
          builder: ( context) => AlertDialog(
            title: const Text('Something wrong'),
            content: const Text('Wrong email format or exiting account'),
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

  //register method
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
                  const SizedBox(height: 25),
                  TextFormField(
                    controller: confirmpassController,
                    obscureText: true,
                    decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: 'Confirm password',
                        hintStyle: TextStyle(color: Colors.grey[500])),
                  ),
                  const SizedBox(height: 25),
                  TextFormField(
                    controller: nameController,
                    obscureText: false,
                    decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: 'Firstname',
                        hintStyle: TextStyle(color: Colors.grey[500])),
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: () {
                      login(
                          emailController.text.toString(),
                          passwordController.text.toString(),
                          confirmpassController.text.toString(),
                          nameController.text.toString());
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
