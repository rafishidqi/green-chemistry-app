import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/category_model.dart';
import '../../config/constants.dart' as constants;

class CategoryProvider with ChangeNotifier {
  List<CategoryModel> _categories = [];

  List<CategoryModel> get categories => _categories;

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('${constants.baseUrl}/api/categories'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _categories = (data['data'] as List)
            .map((item) => CategoryModel.fromJson(item))
            .toList();
        notifyListeners();
      } else {
        throw Exception('Gagal memuat kategori');
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      rethrow;
    }
  }
}
