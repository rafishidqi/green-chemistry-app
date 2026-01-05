import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/post_model.dart';
import '../screens/posts/post_detail_screen.dart';
import '../screens/posts/post_edit_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/translate_provider.dart';
import '../config/translate.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final bool showEditButton;

  const PostCard({super.key, required this.post, this.showEditButton = false});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final localization = Provider.of<TranslateProvider>(context);
    final currentUserId = authProvider.userId ?? 0;

    final isOwner = post.idAuthor == currentUserId;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PostDetailScreen(post: post),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // THUMBNAIL (Kiri)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: post.imageUrl != null && post.imageUrl!.isNotEmpty
                  ? Image.network(
                      post.imageUrl!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[300],
                        alignment: Alignment.center,
                        child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                      ),
                    )
                  : Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[300],
                      alignment: Alignment.center,
                      child: const Icon(Icons.image, size: 40, color: Colors.grey),
                    ),
            ),

            const SizedBox(width: 12),

            // KONTEN (Kanan)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul
                  Text(
                    localization.isEnglish ? post.judulEn : post.judulId,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Deskripsi
                  Text(
                    localization.isEnglish ? post.descriptionEn : post.descriptionId,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Tombol Edit hanya jika pemilik post dan showEditButton true
                  if (isOwner && showEditButton)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        icon: const Icon(Icons.edit, size: 16),
                        label: Text(AppTranslate.translate('edit', localization.currentLanguage)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PostEditScreen(postData: post.toMap()),
                            ),
                          ).then((_) {
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
