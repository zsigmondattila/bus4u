import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UserService extends ChangeNotifier {
  String? token;
  String? userUid;
  String? client;
  String? accessToken;
  String? firstName;
  String? lastName;

  UserService() {
    getUserData();
  }

  bool get isLoggedIn => token != null;

  void getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    userUid = prefs.getString('user_uid');
    client = prefs.getString('client');
    accessToken = prefs.getString('access_token');
    firstName = prefs.getString('firstname');
    lastName = prefs.getString('lastname');
    notifyListeners();
  }

  Future<bool> signIn(String email, password) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.bus4u.online/auth/sign_in'),
        body: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        token = response.headers['authorization'] ?? '';
        userUid = response.headers['uid'] ?? '';
        client = response.headers['client'] ?? '';
        accessToken = response.headers['access-token'] ?? '';
        var body = jsonDecode(response.body)['data'];
        firstName = body['firstname'];
        lastName = body['lastname'];
        saveData();
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('Error during login: $e');
      return false;
    }
    return true;
  }

  Future<bool> signOut() async {
    try {
      final response = await http
          .delete(Uri.parse('https://api.bus4u.online/auth/sign_out'), body: {
        'uid': userUid,
        'client': client,
        'access-token': accessToken
      });
      if (response.statusCode == 200) {
        token = null;
        userUid = null;
        client = null;
        accessToken = null;
        firstName = null;
        lastName = null;
        saveData();
      } else {
        debugPrint('Logout failed');
        return false;
      }
    } catch (e) {
      debugPrint('Error during logout: $e');
      return false;
    } finally {
      notifyListeners();
    }
    return true;
  }

  void saveData() async {
    final prefs = await SharedPreferences.getInstance();
    if (token == null ||
        userUid == null ||
        client == null ||
        accessToken == null) {
      prefs.remove('token');
      prefs.remove('user_uid');
      prefs.remove('client');
      prefs.remove('access_token');
      prefs.remove('firstname');
      prefs.remove('lastname');
    } else {
      prefs.setString('token', token!);
      prefs.setString('user_uid', userUid!);
      prefs.setString('client', client!);
      prefs.setString('access_token', accessToken!);
      prefs.setString('firstname', firstName!);
      prefs.setString('lastname', lastName!);
    }
  }
}
