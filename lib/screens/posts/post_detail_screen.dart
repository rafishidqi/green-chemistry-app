import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/post_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../providers/translate_provider.dart';
import '../../config/translate.dart';
import 'post_edit_screen.dart';

class PostDetailScreen extends StatefulWidget {
  final PostModel post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  bool _showFullDescription = false;

  void _navigateToEditScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PostEditScreen(postData: widget.post.toMap()),
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus postingan "${widget.post.judulId}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _handleDelete();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _handleDelete() async {
    final postId = widget.post.idKonten;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Menghapus postingan...')),
    );

    try {
      await Provider.of<PostProvider>(context, listen: false).deletePost(postId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Postingan berhasil dihapus!')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus: ${e.toString()}')),
      );
    }
  }

  void _toggleDescription() {
    setState(() {
      _showFullDescription = !_showFullDescription;
    });
  }

  double _calculateTitleHeight(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isExtraSmall = size.width < 320;
    final isSmall = size.width < 360;
    final isTablet = size.width >= 600;
    
    final titleSize = isTablet
        ? 28.0
        : isExtraSmall
            ? 18.0
            : (isSmall ? 20.0 : 24.0);
    
    // Hitung tinggi judul berdasarkan panjang teks
    final textPainter = TextPainter(
      text: TextSpan(
        text: widget.post.judulId,
        style: TextStyle(
          fontSize: titleSize,
          fontWeight: FontWeight.bold,
          height: 1.3,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout(maxWidth: size.width - 32); // padding kiri kanan
    return textPainter.size.height;
  }



  @override
  Widget build(BuildContext context) {
    // Debug logging untuk image URL
    debugPrint('=== POST DETAIL DEBUG ===');
    debugPrint('Post ID: ${widget.post.idKonten}');
    debugPrint('Image URL: ${widget.post.imageUrl}');
    debugPrint('Image URL is empty: ${widget.post.imageUrl?.isEmpty ?? true}');
    debugPrint('Image URL is null: ${widget.post.imageUrl == null}');

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final localization = Provider.of<TranslateProvider>(context);
    final currentUserId = authProvider.userId ?? 0;
    final isOwner = widget.post.idAuthor == currentUserId;

    // Responsiveness - Breakpoints
    final size = MediaQuery.of(context).size;
    final isExtraSmall = size.width < 320;
    final isSmall = size.width < 360;
    final isTablet = size.width >= 600;

    // Dynamic sizing - gambar memenuhi layar
    final heroHeight = size.height;
    final titleSize = isTablet
        ? 28.0
        : isExtraSmall
            ? 18.0
            : (isSmall ? 20.0 : 24.0);
    final descSize = isTablet
        ? 16.0
        : isExtraSmall
            ? 12.0
            : (isSmall ? 13.0 : 14.0);
    final bodyPad = EdgeInsets.all(isExtraSmall ? 12 : (isSmall ? 14 : 16));
    final chipFont = isTablet ? 13.0 : (isExtraSmall ? 10.0 : 12.0);
    final badgeTop = isTablet ? 88.0 : (isExtraSmall ? 70.0 : 80.0);
    final authorIconSize = isExtraSmall ? 30.0 : 36.0;
    final authorTextSize = isExtraSmall ? 11.0 : 13.0;
    final authorSubtextSize = isExtraSmall ? 10.0 : 12.0;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  // Hero Image - memenuhi layar
                  if (widget.post.imageUrl != null && widget.post.imageUrl!.isNotEmpty)
                    Image.network(
                      widget.post.imageUrl!,
                      width: double.infinity,
                      height: heroHeight,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: heroHeight,
                        color: Colors.grey[300],
                        alignment: Alignment.center,
                        child: const Icon(Icons.broken_image, size: 64, color: Colors.grey),
                      ),
                    )
                  else
                    Container(
                      height: heroHeight,
                      width: double.infinity,
                      color: Colors.grey[300],
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
                    ),

                  // Overlay gradient
                  Container(
                    height: heroHeight,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.2),
                          Colors.black.withValues(alpha: isSmall ? 0.7 : 0.6),
                        ],
                      ),
                    ),
                  ),

                  // AppBar dengan warna putih
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      title: const Text(
                        'Detail Berita',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      iconTheme: const IconThemeData(color: Colors.white),
                      actions: [
                        if (isOwner)
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white),
                            onPressed: _navigateToEditScreen,
                          ),
                        if (isOwner)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.white),
                            onPressed: _confirmDelete,
                          ),
                      ],
                    ),
                  ),

                  // Badge kategori - Tampilkan hanya 3 kategori pertama
                  if (widget.post.categoryNamesId != null && widget.post.categoryNamesId!.isNotEmpty)
                    Positioned(
                      top: badgeTop,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Label "Kategori"
                          Text(
                            AppTranslate.translate('category', localization.currentLanguage),
                            style: TextStyle(
                              fontSize: isExtraSmall ? 10 : 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Kategori badges (max 3)
                          Wrap(
                            spacing: isExtraSmall ? 3 : (isSmall ? 4 : 5),
                            runSpacing: isExtraSmall ? 2 : (isSmall ? 2.5 : 3),
                            children: List.generate(
                              widget.post.categoryNamesId!.take(3).length, // Hanya 3 kategori
                              (index) {
                                final namesId = widget.post.categoryNamesId;
                                final namesEn = widget.post.categoryNamesEn;

                                final nameId = namesId != null && index < namesId.length ? namesId[index] : '';
                                final nameEn = namesEn != null && index < namesEn.length ? namesEn[index] : '';
                                final categoryName = '$nameId ($nameEn)';

                                return Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isExtraSmall ? 8 : 12,
                                    vertical: isExtraSmall ? 4 : 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    categoryName,
                                    style: TextStyle(
                                      fontSize: chipFont,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Author info tetap di bawah (tidak bergerak)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: bodyPad,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Row(
                              children: [
                                Container(
                                  width: authorIconSize,
                                  height: authorIconSize,
                                  decoration: BoxDecoration(
                                    color: Colors.red[400],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.newspaper,
                                    color: Colors.white,
                                    size: isExtraSmall ? 16 : 20,
                                  ),
                                ),
                                SizedBox(width: isExtraSmall ? 8 : 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.post.authorName ?? 'Tidak diketahui',
                                        style: TextStyle(
                                          fontSize: authorTextSize,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      Text(
                                        'Penulis',
                                        style: TextStyle(
                                          fontSize: authorSubtextSize,
                                          color: Colors.white.withValues(alpha: 0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Status badge
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isExtraSmall ? 6 : 8,
                              vertical: isExtraSmall ? 3 : 4,
                            ),
                            decoration: BoxDecoration(
                              color: widget.post.status == 'published'
                                  ? Colors.green[400]
                                  : widget.post.status == 'pending'
                                      ? Colors.orange[400]
                                      : Colors.grey[400],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              widget.post.status.toUpperCase(),
                              style: TextStyle(
                                fontSize: isExtraSmall ? 9 : 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Konten utama (judul + deskripsi)
                  Builder(
                    builder: (context) {
                      final size = MediaQuery.of(context).size;
                      final titleHeight = _calculateTitleHeight(context);
                      
                      // Hitung tinggi deskripsi penuh
                      final textPainter = TextPainter(
                        text: TextSpan(
                          text: widget.post.descriptionId.isNotEmpty
                              ? widget.post.descriptionId
                              : '(Tidak ada deskripsi)',
                          style: TextStyle(
                            fontSize: descSize,
                            height: 1.6,
                          ),
                        ),
                        maxLines: null,
                        textDirection: TextDirection.ltr,
                      );
                      textPainter.layout(maxWidth: size.width - 32);
                      
                      final fullDescHeight = textPainter.size.height;
                      final totalContentHeight = titleHeight + fullDescHeight + 12;
                      final maxAllowedHeight = size.height * 0.5;
                      
                      // Jika konten tidak melebihi setengah layar, tampilkan semua
                      final isContentShort = totalContentHeight <= maxAllowedHeight;
                      
                      if (isContentShort) {
                        // SESUAIKAN NILAI INI UNTUK MENGATUR POSISI KONTEN PENDEK
                        // Semakin kecil nilai, semakin dekat dengan author info
                        final shortContentBottom = 80.0; // <-- UBAH NILAI INI
                        
                        // Tampilkan semua konten tanpa tombol
                        return Positioned(
                          bottom: shortContentBottom,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: bodyPad,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.post.judulId,
                                  style: TextStyle(
                                    fontSize: titleSize,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  widget.post.descriptionId.isNotEmpty
                                      ? widget.post.descriptionId
                                      : '(Tidak ada deskripsi)',
                                  style: TextStyle(
                                    fontSize: descSize,
                                    color: Colors.white,
                                    height: 1.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        // Konten panjang - tampilkan dengan logika expand/collapse
                        if (_showFullDescription) {
                          // Mode expanded - naik sampai setengah layar
                          return Positioned(
                            bottom: 80,
                            height: maxAllowedHeight,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: bodyPad,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    localization.isEnglish ? widget.post.judulEn : widget.post.judulId,
                                    style: TextStyle(
                                      fontSize: titleSize,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Text(
                                        localization.isEnglish
                                            ? (widget.post.descriptionEn.isNotEmpty
                                                ? widget.post.descriptionEn
                                                : '(No description)')
                                            : (widget.post.descriptionId.isNotEmpty
                                                ? widget.post.descriptionId
                                                : '(Tidak ada deskripsi)'),
                                        style: TextStyle(
                                          fontSize: descSize,
                                          color: Colors.white,
                                          height: 1.6,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: _toggleDescription,
                                    child: Text(
                                      AppTranslate.translate('see_less', localization.currentLanguage),
                                      style: TextStyle(
                                        fontSize: descSize,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          // Mode preview - tampilkan 2 baris dengan tombol
                          return Positioned(
                            bottom: 80,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: bodyPad,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    localization.isEnglish ? widget.post.judulEn : widget.post.judulId,
                                    style: TextStyle(
                                      fontSize: titleSize,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  GestureDetector(
                                    onTap: _toggleDescription,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          localization.isEnglish
                                              ? (widget.post.descriptionEn.isNotEmpty
                                                  ? widget.post.descriptionEn
                                                  : '(No description)')
                                              : (widget.post.descriptionId.isNotEmpty
                                                  ? widget.post.descriptionId
                                                  : '(Tidak ada deskripsi)'),
                                          style: TextStyle(
                                            fontSize: descSize,
                                            color: Colors.white,
                                            height: 1.5,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          AppTranslate.translate('see_more', localization.currentLanguage),
                                          style: TextStyle(
                                            fontSize: descSize,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
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
                    },
                  ),


                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
