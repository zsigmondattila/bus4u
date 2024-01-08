import 'package:bus4u/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:logger/logger.dart';

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

  var logger = Logger();

  void _showVerificationDialog(String email) {
    String verificationCode = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Column(
            children: [
              Image.asset(
                'assets/images/logo-text.png',
                height: 40,
              ),
              const SizedBox(height: 10),
              const Text('We sent a verification code to:'),
              Text(email),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < 4; i++)
                    Container(
                      width: 50,
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextFormField(
                        onChanged: (value) {
                          if (value.length == 1) {
                            verificationCode += value;
                          }
                          if (i < 3 && value.length == 1) {
                            FocusScope.of(context).nextFocus();
                          } else if (i > 0 && value.length == 0) {
                            FocusScope.of(context).previousFocus();
                          }
                        },
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (verificationCode.length == 4) {
                  Navigator.pop(context, true);
                  verifyCode(email, verificationCode);
                } else {
                  logger.e('wrong code');
                }
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  void _showRegistrationSuccessDialog() {
    showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Successful'),
        content: const Text(
            'You created an account successfully, now you can sign in'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context, 'OK');
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => LoginPage()));
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showRegistrationFailureDialog() {
    showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Something wrong'),
        content: const Text('Wrong email format or existing account'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context, 'OK');
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void sendVerificationEmail(String email) async {
    try {
      Response response = await post(
        Uri.parse('https://bus4u.fast-table.com/v1/send_verification_email'),
        body: {'user_email': email},
      );

      if (response.statusCode == 202) {
        showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: const Text('This email address is already registered.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context, 'OK');
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else if (response.statusCode == 200) {
        _showVerificationDialog(email);
      } else {
        logger.e('Failed to send verification email');
      }
    } catch (e) {
      logger.e(e.toString());
    }
  }

  void verifyCode(String email, String verificationCode) async {
    try {
      Response response = await get(
        Uri.parse(
          'https://bus4u.fast-table.com/v1/verify_code_email?user_email=$email&verification_code=$verificationCode',
        ),
      );
      print('Response status code: $email');
      print('Response body: $verificationCode');
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('Code verification successful');
        register(
          emailController.text.toString(),
          passwordController.text.toString(),
          confirmpassController.text.toString(),
          nameController.text.toString(),
        );
      } else {
        print('Code verification failed');
      }
    } catch (e) {
      print('Error during code verification: $e');
      logger.e(e.toString());
    }
  }

  void register(String email, password, confirmpassword, firstname) async {
    try {
      Response response =
          await post(Uri.parse('https://bus4u.fast-table.com/auth'), body: {
        'email': email,
        'password': password,
        'password_confirmation': confirmpassword,
        'firstname': firstname,
      });
      if (response.statusCode == 200) {
        _showRegistrationSuccessDialog();
      } else {
        logger.e('failed');
        _showRegistrationFailureDialog();
      }
    } catch (e) {
      logger.e(e.toString());
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
                      sendVerificationEmail(emailController.text.toString());
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
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Registered yet?",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 15),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (BuildContext context) {
                              return const LoginPage();
                            }),
                          );
                        },
                        child: const Text('Sign in'),
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
