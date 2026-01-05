import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart' as constants;

class AuthProvider extends ChangeNotifier {
  String? _token;
  String? _userName;
  int? _userId;

  bool get isLoggedIn => _token != null;
  String? get userName => _userName;
  String? get token => _token;
  int? get userId => _userId;

  AuthProvider() {
    loadUser();
  }

  Future<void> login(String email, String password) async {
    final url = Uri.parse('${constants.baseUrl}/login');

    final response = await http.post(
      url,
      headers: {'Accept': 'application/json'},
      body: {'email': email, 'password': password},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      _token = data['access_token'] ?? data['token'];
      _userName = data['user']['name'];
      _userId = data['user']['id'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setString('userName', _userName!);
      await prefs.setInt('userId', _userId!);

      notifyListeners();
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Login gagal');
    }
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _userName = prefs.getString('userName');
    _userId = prefs.getInt('userId');
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _token = null;
    _userName = null;
    _userId = null;
    notifyListeners();
  }
}
