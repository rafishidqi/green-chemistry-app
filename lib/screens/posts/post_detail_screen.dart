import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/post_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart'; // 💡 PASTIKAN INI ADA
import 'post_edit_screen.dart';
// Note: Kita mengasumsikan PostEditScreen dan model lainnya sudah ada

// 1. UBAH MENJADI STATEFULWIDGET
class PostDetailScreen extends StatefulWidget {
  final PostModel post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {

  // Fungsi navigasi ke edit screen
  void _navigateToEditScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PostEditScreen(postData: widget.post.toMap()),
      ),
    ).then((result) {
      // Jika Anda memiliki fetch detail untuk refresh, panggil di sini
    });
  }

  // 2. FUNGSI KONFIRMASI DELETE
  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus postingan "${widget.post.judulId}"?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Tutup dialog
            },
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Tutup dialog konfirmasi
              _handleDelete(); // Lanjutkan proses hapus
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // 3. FUNGSI HANDLE PROSES PENGHAPUSAN ASINKRON
  void _handleDelete() async {
    final postId = widget.post.idKonten; 

    // Tampilkan SnackBar loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Menghapus postingan...')),
    );

    try {
      // Panggil provider untuk menghapus
      await Provider.of<PostProvider>(context, listen: false).deletePost(postId);
      
      // Beri notifikasi sukses dan kembali ke list
      if (mounted) {
        // Sembunyikan SnackBar loading dan tampilkan SnackBar sukses
        ScaffoldMessenger.of(context).hideCurrentSnackBar(); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Postingan berhasil dihapus!')),
        );
        // Kembali ke list/DashboardScreen
        Navigator.of(context).pop(); 
      }
    } catch (e) {
      // Tampilkan error jika gagal
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus: ${e.toString()}')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Ambil userId dari AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.userId ?? 0;

    // Cek apakah post ini milik user login
    final isOwner = widget.post.idAuthor == currentUserId;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post.judulId),
        backgroundColor: Colors.blueAccent,
        actions: [
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _navigateToEditScreen,
            ),
            
          // 🟢 TOMBOL DELETE BARU
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.delete),
              color: Colors.white, 
              onPressed: _confirmDelete, // Panggil konfirmasi
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar (jika ada)
            if (widget.post.imageUrl != null && widget.post.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.post.imageUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image, size: 64, color: Colors.grey),
                  ),
                ),
              )
            else
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
              ),
            const SizedBox(height: 16),

            // Judul
            Text(
              widget.post.judulId,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Penulis dan Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Penulis: ${widget.post.authorName ?? 'Tidak diketahui'}",
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  widget.post.status.toUpperCase(),
                  style: TextStyle(
                    color: widget.post.status == 'published'
                        ? Colors.green
                        : widget.post.status == 'pending'
                            ? Colors.orange
                            : Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Deskripsi
            Text(
              widget.post.descriptionId.isNotEmpty
                  ? widget.post.descriptionId
                  : '(Tidak ada deskripsi)',
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),

            // Kategori
            if (widget.post.categoryNames != null && widget.post.categoryNames!.isNotEmpty)
              Wrap(
                spacing: 8,
                children: widget.post.categoryNames!
                    .map((category) => Chip(
                          label: Text(category),
                          backgroundColor: Colors.blue[50],
                        ))
                    .toList(),
              )
            else
              const Text(
                '(Tidak ada kategori)',
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}