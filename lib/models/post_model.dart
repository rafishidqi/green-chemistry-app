import 'package:flutter/foundation.dart';
import '../config/constants.dart' as constants;

class PostModel {
  final int idKonten;
  final int idAuthor;
  final String judulId;
  final String judulEn;
  final String descriptionId;
  final String descriptionEn;
  final String? imageUrl;
  final String status;
  final String? authorName;
  final List<String>? categoryNamesId;  // Nama kategori dalam Bahasa Indonesia
  final List<String>? categoryNamesEn;  // Nama kategori dalam Bahasa Inggris
  final List<int>? categoryIds;         // ID kategori

  PostModel({
    required this.idKonten,
    required this.idAuthor,
    required this.judulId,
    required this.judulEn,
    required this.descriptionId,
    required this.descriptionEn,
    this.imageUrl,
    required this.status,
    this.authorName,
    this.categoryNamesId,
    this.categoryNamesEn,
    this.categoryIds,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {

    // Debug logging
    if (kDebugMode) {
      debugPrint('=== POST MODEL FROM JSON ===');
      debugPrint('Full JSON: $json');
      debugPrint('image_url value: ${json['image_url']}');
      debugPrint('image_url type: ${json['image_url'].runtimeType}');
    }

    // Helper konversi integer
    int safeInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) {
        return value;
      } else if (value is String) {
        return int.tryParse(value) ?? 0;
      }
      return 0;
    }

    final List<dynamic>? categoriesData = json['categories'] as List<dynamic>?;

    // Inisialisasi list untuk ID dan Nama Kategori (bilingual)
    List<int> ids = [];
    List<String> namesId = [];
    List<String> namesEn = [];

    if (categoriesData != null) {
      for (var cat in categoriesData) {
        if (cat is Map) {
          // ID Asli dari API
          dynamic idValue = cat['id_kategori'];
          String? nameId = cat['kategori_id'];
          String? nameEn = cat['kategori_en'];

          // Parse ID hanya jika ada nilai asli dari API
          int? id;
          if (idValue is String) {
            id = int.tryParse(idValue);
          } else if (idValue is int) {
            id = idValue;
          }

          // Tambahkan ke list hanya jika ID valid dari API
          if (id != null && id > 0) {
            ids.add(id);
            namesId.add(nameId ?? 'Tanpa nama');
            namesEn.add(nameEn ?? 'No name');
          }
        }
      }
    }

    String? imageUrl = json['image_url'];
    if (imageUrl != null && imageUrl.isNotEmpty) {
      if (!imageUrl.startsWith('http')) {
        final baseUrlWithoutApi = constants.baseUrl.replaceAll('/api', '');
        imageUrl = '$baseUrlWithoutApi/$imageUrl';
      }
      if (kDebugMode) {
        debugPrint('Final Image URL: $imageUrl');
      }
    }

    return PostModel(
      // safeInt untuk field int
      idKonten: safeInt(json['id_konten']),
      idAuthor: safeInt(json['id_author']),

      judulId: json['judul_id'] ?? '',
      judulEn: json['judul_en'] ?? '',
      descriptionId: json['description_id'] ?? '',
      descriptionEn: json['description_en'] ?? '',
      imageUrl: imageUrl,
      status: json['status'] ?? 'draft',
      authorName: json['author']?['name'],
      categoryNamesId: namesId.isEmpty ? null : namesId,
      categoryNamesEn: namesEn.isEmpty ? null : namesEn,
      categoryIds: ids.isEmpty ? null : ids,
    );
  }

  // method untuk mengubah PostModel menjadi Map agar bisa dikirim ke PostEditScreen
  Map<String, dynamic> toMap() {
    if (kDebugMode) {
      print('=== POST MODEL TO MAP ===');
      print('categoryIds: $categoryIds');
      print('categoryNamesId: $categoryNamesId');
      print('categoryNamesEn: $categoryNamesEn');
    }

    final result = {
      'id': idKonten,
      'id_author': idAuthor,
      'judul_id': judulId,
      'judul_en': judulEn,
      'description_id': descriptionId,
      'description_en': descriptionEn,
      'image_url': imageUrl ?? '',
      'status': status,
      'authorName': authorName ?? '',
      'categories': categoryIds ?? [],
    };

    if (kDebugMode) {
      print('toMap result: $result');
    }
    return result;
  }
}