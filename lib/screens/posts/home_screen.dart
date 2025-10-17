import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/post_provider.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/post_card.dart';
import '../../models/post_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PostProvider>(context, listen: false).fetchAllPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Beranda')),
      drawer: const CustomDrawer(),
      body: Consumer<PostProvider>(
        builder: (context, postProvider, _) {
          if (postProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (postProvider.posts.isEmpty) {
            return const Center(child: Text('Belum ada postingan'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              await Provider.of<PostProvider>(context, listen: false)
                  .fetchAllPosts();
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: postProvider.posts.length,
              itemBuilder: (context, index) {
                PostModel post = postProvider.posts[index];
                return PostCard(post: post); // 🔹 Pakai komponen PostCard
              },
            ),
          );
        },
      ),
    );
  }
}
