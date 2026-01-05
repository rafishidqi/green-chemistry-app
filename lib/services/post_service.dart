import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/post_model.dart';
import '../config/constants.dart' as constants;

class PostService {
  // Ambil postingan milik user login
  static Future<List<PostModel>> getUserPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('Token tidak ditemukan');

    final response = await http.get(
      Uri.parse('${constants.baseUrl}/posts'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['data'];
      return data.map((e) => PostModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil postingan: ${response.body}');
    }
  }

  // Ambil semua postingan publik (published)
  static Future<List<PostModel>> getAllPosts() async {
    final response = await http.get(
      Uri.parse('${constants.baseUrl}/posts/all'),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['data'];
      return data.map((e) => PostModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil semua postingan: ${response.body}');
    }
  }

  // Buat postingan baru
  static Future<void> createPost({
    required String judulId,
    required String descriptionId,
    String? judulEn,
    String? descriptionEn,
    String? imageUrl,
    List<int>? categories,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('Token tidak ditemukan');

    final Map<String, dynamic> body = {
      'judul_id': judulId,
      'judul_en': judulEn ?? '',
      'description_id': descriptionId,
      'description_en': descriptionEn ?? '',
      'image_url': imageUrl ?? '',
      'status': 'pending',
      'categories': categories ?? [],
    };

    debugPrint('📦 BODY DIKIRIM: ${jsonEncode(body)}');

    final response = await http.post(
      Uri.parse('${constants.baseUrl}/posts'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    debugPrint('📥 RESPONSE STATUS: ${response.statusCode}');
    debugPrint('📥 RESPONSE BODY: ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Gagal membuat postingan: ${response.body}');
    }
  }

  // Update postingan
  static Future<void> updatePost({
    required int id,
    required String judulId,
    required String descriptionId,
    String? judulEn,
    String? descriptionEn,
    String? imageUrl,
    List<int>? categories,
    String? status,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('Token tidak ditemukan');

    final Map<String, dynamic> body = {
      'judul_id': judulId,
      'judul_en': judulEn ?? '',
      'description_id': descriptionId,
      'description_en': descriptionEn ?? '',
      'image_url': imageUrl ?? '',
      'status': status ?? 'pending',
      'categories': categories ?? [],
    };

    final response = await http.put(
      Uri.parse('${constants.baseUrl}/posts/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    debugPrint('📥 RESPONSE UPDATE: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Gagal memperbarui postingan: ${response.body}');
    }
  }

  //Hapus postingan berdasarkan ID
  static Future<void> deletePost(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('Token tidak ditemukan');

    final response = await http.delete(
      Uri.parse('${constants.baseUrl}/posts/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus postingan: ${response.body}');
    }
  }

  // detail postingan berdasarkan ID
  static Future<PostModel> getPostDetail(int id) async {
    final response = await http.get(
      Uri.parse('${constants.baseUrl}/posts/$id'),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return PostModel.fromJson(data);
    } else {
      throw Exception('Gagal mengambil detail postingan: ${response.body}');
    }
  }
}
