// File: post_provider.dart

import 'package:flutter/foundation.dart';
import '../models/post_model.dart';
import '../services/post_service.dart'; // Pastikan import PostService benar

class PostProvider extends ChangeNotifier {
  List<PostModel> _posts = [];
  bool _isLoading = false;

  List<PostModel> get posts => _posts;
  bool get isLoading => _isLoading;

  // 1. Ambil postingan user login
  Future<void> fetchUserPosts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _posts = await PostService.getUserPosts();
    } catch (e) {
      // Menggunakan kDebugMode untuk print hanya saat debug
      if (kDebugMode) {
        print('Error fetching user posts: $e');
      }
      _posts = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // 2. Ambil semua postingan
  Future<void> fetchAllPosts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _posts = await PostService.getAllPosts();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching all posts: $e');
      }
      _posts = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // 🟢 3. FUNGSI BARU: Hapus Postingan
  Future<void> deletePost(int postId) async {
    try {
      // A. Panggil PostService untuk menghapus dari backend
      await PostService.deletePost(postId); 

      // B. Hapus dari list lokal (_posts) dan update UI
      _posts.removeWhere((post) => post.idKonten == postId);
      notifyListeners();
      
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting post: $e');
      }
      // Lemparkan error agar PostDetailScreen bisa menangkap dan menampilkan SnackBar
      rethrow; 
    }
  }
}