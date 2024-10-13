import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveData(key, value) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString(key, value);
}

Future<String?> readData(String key) async {
  final prefs = await SharedPreferences.getInstance();
  final value = prefs.getString(key);
  return value;
}

Future<void> removeData(String key) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(key);
}
