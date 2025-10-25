import 'package:flutter/foundation.dart';

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
  final List<String>? categoryNames; // Diganti namanya agar lebih jelas (List of Names)
  final List<int>? categoryIds;       // TAMBAHAN: Untuk menyimpan ID Integer

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
    this.categoryNames,
    this.categoryIds,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    // Fungsi helper untuk konversi aman ke int (Mengatasi error "Lingkungan" di field ID)
    int safeInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) {
        return value;
      } else if (value is String) {
        return int.tryParse(value) ?? 0;
      }
      return 0; // Default jika tipe data tidak terduga
    }

    final List<dynamic>? categoriesData = json['categories'] as List<dynamic>?;

    // Inisialisasi list untuk ID dan Nama Kategori
    List<int> ids = [];
    List<String> names = [];

    if (categoriesData != null) {
      for (var cat in categoriesData) {
        if (cat is Map) {
          // Hanya ambil ID asli dari API, jangan gunakan hashCode
          dynamic idValue = cat['id_kategori'];
          String? name = cat['kategori_id'] ?? cat['kategori_en'];

          // Parse ID hanya jika ada nilai asli dari API
          int? id;
          if (idValue is String) {
            id = int.tryParse(idValue);
          } else if (idValue is int) {
            id = idValue;
          }

          // Tambahkan ke list hanya jika ID valid dari API
          if (name != null && id != null && id > 0) {
            ids.add(id);
            names.add(name);
          }
        }
      }
    }

    return PostModel(
      // Menerapkan safeInt pada field yang bertipe int
      idKonten: safeInt(json['id_konten']),
      idAuthor: safeInt(json['id_author']),
      
      judulId: json['judul_id'] ?? '',
      judulEn: json['judul_en'] ?? '',
      descriptionId: json['description_id'] ?? '',
      descriptionEn: json['description_en'] ?? '',
      imageUrl: json['image_url'],
      status: json['status'] ?? 'draft',
      authorName: json['author']?['name'],
      categoryNames: names.isEmpty ? null : names,
      categoryIds: ids.isEmpty ? null : ids, // Menggunakan list ID
    );
  }

  // method untuk mengubah PostModel menjadi Map agar bisa dikirim ke PostEditScreen
  Map<String, dynamic> toMap() {
    if (kDebugMode) {
      print('=== POST MODEL TO MAP ===');
      print('categoryIds: $categoryIds');
      print('categoryNames: $categoryNames');
    }
    
    final result = {
      'id': idKonten, // Di mapping ke 'id' di PostEditScreen
      'id_author': idAuthor,
      'judul_id': judulId,
      'judul_en': judulEn,
      'description_id': descriptionId,
      'description_en': descriptionEn,
      'image_url': imageUrl ?? '',
      'status': status,
      'authorName': authorName ?? '',
      // 🟢 PERBAIKAN KRITIS: Kirim List<int> (ID kategori) untuk inisialisasi di PostEditScreen
      'categories': categoryIds ?? [], // Sekarang mengirim List<int>
    };
    
    if (kDebugMode) {
      print('toMap result: $result');
    }
    return result;
  }
}