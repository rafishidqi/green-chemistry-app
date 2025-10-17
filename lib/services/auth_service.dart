import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart' as constants;

class AuthService {

  static Future<String?> login(String email, String password) async {
    final url = Uri.parse('${constants.baseUrl}/login');

    try {
      final response = await http.post(
        url,
        headers: {'Accept': 'application/json'},
        body: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['token'] != null) {
          return data['token']; // kembalikan token
        } else {
          throw Exception(data['message'] ?? 'Token tidak ditemukan');
        }
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Login gagal (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan koneksi: $e');
    }
  }
}
