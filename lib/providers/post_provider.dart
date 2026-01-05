// File: post_provider.dart

import 'package:flutter/foundation.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';

class PostProvider extends ChangeNotifier {
  List<PostModel> _posts = [];
  bool _isLoading = false;

  List<PostModel> get posts => _posts;
  bool get isLoading => _isLoading;

  // Post User yang login
  Future<void> fetchUserPosts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _posts = await PostService.getUserPosts();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user posts: $e');
      }
      _posts = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Post Semua
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

  // Hapus Postingan
  Future<void> deletePost(int postId) async {
    try {
      await PostService.deletePost(postId); 

      _posts.removeWhere((post) => post.idKonten == postId);
      notifyListeners();
      
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting post: $e');
      }
      rethrow; 
    }
  }
}