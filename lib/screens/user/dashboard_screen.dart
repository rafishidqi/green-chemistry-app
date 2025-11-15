import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/post_provider.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/post_card.dart';
import '../../screens/posts/post_form_screen.dart';
import '../../models/post_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch postingan user saat pertama kali masuk
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PostProvider>(context, listen: false).fetchUserPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Saya')),
      drawer: const CustomDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Ambil provider sebelum async operation
          final postProvider = Provider.of<PostProvider>(context, listen: false);

          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PostFormScreen()),
          ).then((_) {
            // Refresh list setelah kembali dari create
            postProvider.fetchUserPosts();
          });
        },
        child: const Icon(Icons.add),
      ),
      body: Consumer<PostProvider>(
        builder: (context, postProvider, _) {
          if (postProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (postProvider.posts.isEmpty) {
            return const Center(child: Text('Kamu belum membuat postingan.'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              await Provider.of<PostProvider>(context, listen: false)
                  .fetchUserPosts();
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: postProvider.posts.length,
              itemBuilder: (context, index) {
                PostModel post = postProvider.posts[index];
                return PostCard(post: post, showEditButton: true);
              },
            ),
          );
        },
      ),
    );
  }
}
