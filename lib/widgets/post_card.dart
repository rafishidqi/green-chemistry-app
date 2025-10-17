import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/post_model.dart';
import '../screens/posts/post_detail_screen.dart';
import '../screens/posts/post_edit_screen.dart';
import '../providers/auth_provider.dart';

class PostCard extends StatelessWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    // Ambil userId dari AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.userId ?? 0;

    // Cek apakah post ini milik user login
    final isOwner = post.idAuthor == currentUserId;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PostDetailScreen(post: post),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar (jika ada)
            if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image.network(
                  post.imageUrl!,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 180,
                    color: Colors.grey[300],
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image, size: 64, color: Colors.grey),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul
                  Text(
                    post.judulId,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Deskripsi singkat
                  Text(
                    post.descriptionId.length > 100
                        ? '${post.descriptionId.substring(0, 100)}...'
                        : post.descriptionId,
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                  const SizedBox(height: 8),

                  // Info tambahan: penulis + status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Penulis: ${post.authorName ?? 'Tidak diketahui'}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      Text(
                        post.status.toUpperCase(),
                        style: TextStyle(
                          color: post.status == 'published'
                              ? Colors.green
                              : post.status == 'pending'
                                  ? Colors.orange
                                  : Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  // Tombol Edit hanya jika pemilik post
                  if (isOwner)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Edit'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PostEditScreen(postData: post.toMap()),
                            ),
                          ).then((_) {
                            // opsional: refresh list jika perlu
                          });
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
