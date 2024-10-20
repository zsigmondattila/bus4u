import 'dart:io';

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
  TextEditingController firstnameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();

  bool isLoading = false;
  var logger = Logger();

  void _showVerificationDialog(String email) {
    String verificationCode = '';

    showDialog(
      context: context,
      builder: (context) {
        String? codeError;

        return StatefulBuilder(
          builder: (context, setError) {
            return AlertDialog(
              title: const Text('Email verification'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('We sent a verification code to:'),
                  Text(
                    email,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 32,
                    child: codeError == null
                        ? null
                        : Center(
                            child: Text(
                            codeError!,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error),
                          )),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < 4; i++)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          width: 50,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context).colorScheme.outline),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextFormField(
                            onChanged: (value) {
                              if (value.length == 1) {
                                verificationCode += value;
                              }
                              if (i < 3 && value.length == 1) {
                                FocusScope.of(context).nextFocus();
                              } else if (i > 0 && value.isEmpty) {
                                FocusScope.of(context).previousFocus();
                              }
                            },
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
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
                      setError(() {
                        codeError = null;
                      });
                      Navigator.pop(context, true);
                      verifyCode(email, verificationCode);
                    } else {
                      setError(() {
                        codeError = 'Code must be 4 digits';
                      });
                    }
                  },
                  child: const Text('Verify'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showRegistrationSuccessDialog() {
    showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registration successful'),
        content: const Text('Account created successfully, now you can log in'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context, 'OK');
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const LoginPage()));
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showRegistrationFailureDialog(String message) {
    showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registration error'),
        content: Text(message),
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
    setState(() {
      isLoading = true;
    });
    try {
      Response response = await post(
        Uri.parse('https://api.bus4u.online/v1/send_verification_email'),
        body: {'user_email': email},
      );

      switch (response.statusCode) {
        case 200:
          _showVerificationDialog(email);
          break;
        case 202:
          if (!context.mounted) return;
          showDialog<String>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Registration error'),
              content: const Text(
                  'This email address is already registered. Please try again with a different one.'),
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
          break;
        default:
          _showRegistrationFailureDialog('Failed to send verification email');
      }
    } on SocketException {
      _showRegistrationFailureDialog('No internet connection');
    } catch (e) {
      logger.e(e.toString());
      _showRegistrationFailureDialog('Failed to send verification email');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void verifyCode(String email, String verificationCode) async {
    try {
      Response response = await get(
        Uri.parse(
          'https://api.bus4u.online/v1/verify_code_email?user_email=$email&verification_code=$verificationCode',
        ),
      );

      if (response.statusCode == 200) {
        register(
          emailController.text.toString(),
          passwordController.text.toString(),
          confirmpassController.text.toString(),
          firstnameController.text.toString(),
          lastnameController.text.toString(),
        );
      } else {
        _showRegistrationFailureDialog(
            'The verification code is incorrect. Please try again.');
      }
    } catch (e) {
      _showRegistrationFailureDialog(
          'Failed to verify code due to a network error');
      logger.e(e.toString());
    }
  }

  void register(
      String email, password, confirmpassword, firstname, lastname) async {
    try {
      Response response =
          await post(Uri.parse('https://api.bus4u.online/auth'), body: {
        'email': email,
        'password': password,
        'password_confirmation': confirmpassword,
        'firstname': firstname,
        'lastname': lastname,
      });
      if (response.statusCode == 200) {
        _showRegistrationSuccessDialog();
      } else {
        logger.e('failed');
        _showRegistrationFailureDialog(
            'Wrong email format or existing account');
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
            'Register',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/logo-text.png',
                    height: 64,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: firstnameController,
                    obscureText: false,
                    decoration: InputDecoration(
                        labelText: 'Firstname',
                        hintStyle: TextStyle(color: Colors.grey[500])),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: lastnameController,
                    obscureText: false,
                    decoration: InputDecoration(
                        labelText: 'Lastname',
                        hintStyle: TextStyle(color: Colors.grey[500])),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: emailController,
                    obscureText: false,
                    decoration: InputDecoration(
                        labelText: 'Email',
                        hintStyle: TextStyle(color: Colors.grey[500])),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                        labelText: 'Password',
                        hintStyle: TextStyle(color: Colors.grey[500])),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: confirmpassController,
                    obscureText: true,
                    decoration: InputDecoration(
                        labelText: 'Confirm password',
                        hintStyle: TextStyle(color: Colors.grey[500])),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () {
                      sendVerificationEmail(emailController.text.toString());
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 14),
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
                            'Register',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already registered?"),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (BuildContext context) {
                              return const LoginPage();
                            }),
                          );
                        },
                        child: const Text('Login'),
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
