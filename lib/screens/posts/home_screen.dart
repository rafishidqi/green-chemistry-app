import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../providers/post_provider.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/post_card.dart';
import '../../models/post_model.dart';
import '../../screens/posts/post_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? _selectedCategoryId; // Filter kategori yang dipilih (null = semua)
  int _currentCarouselIndex = 0; // Index carousel saat ini
  late PageController _pageController; // Controller untuk PageView
  Timer? _carouselTimer; // Timer untuk auto-scroll carousel

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PostProvider>(context, listen: false).fetchAllPosts();
      _startAutoScroll(); // Mulai auto-scroll carousel
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _carouselTimer?.cancel(); // Batalkan timer saat dispose
    super.dispose();
  }

  // Fungsi untuk memulai auto-scroll carousel
  void _startAutoScroll() {
    _carouselTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        _currentCarouselIndex = (_currentCarouselIndex + 1) % 5; // Loop ke 5 berita
        _pageController.animateToPage(
          _currentCarouselIndex,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _showSearchDialog(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cari Berita'),
        content: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: 'Masukkan kata kunci...',
            prefixIcon: Icon(Icons.search),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (searchController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                _performSearch(context, searchController.text.trim());
              }
            },
            child: const Text('Cari'),
          ),
        ],
      ),
    );
  }

  void _performSearch(BuildContext context, String query) {
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    
    final filteredPosts = postProvider.posts.where((post) {
      return post.judulId.toLowerCase().contains(query.toLowerCase());
    }).toList();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hasil Pencarian "$query"'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: filteredPosts.isEmpty
              ? const Center(child: Text('Tidak ada berita ditemukan'))
              : ListView.builder(
                  itemCount: filteredPosts.length,
                  itemBuilder: (context, index) {
                    final post = filteredPosts[index];
                    return ListTile(
                      title: Text(
                        post.judulId,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text('Oleh: ${post.authorName ?? 'Unknown'}'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PostDetailScreen(post: post),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
        ],
      ),
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
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                // 🔹 CAROUSEL HORIZONTAL (5 berita terbaru)
                _buildCarousel(postProvider.posts),

                // 🔹 TAB FILTER KATEGORI
                _buildCategoryTabs(postProvider.posts),

                // 🔹 DAFTAR POST (filtered berdasarkan kategori)
                _buildFilteredPostList(postProvider.posts),
              ],
            ),
          );
        },
      ),
    );
  }

  // 🔹 Widget untuk Carousel Horizontal (5 berita terbaru)
  Widget _buildCarousel(List<PostModel> posts) {
    // Ambil maksimal 5 post terbaru
    final carouselPosts = posts.take(5).toList();

    if (carouselPosts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Text(
            'Berita Sensor Dan Kimia Hijau ',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
          ),
        ),
        SizedBox(
          height: 280,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentCarouselIndex = index;
              });
              // Reset timer ketika user manual scroll
              _carouselTimer?.cancel();
              _startAutoScroll();
            },
            itemCount: carouselPosts.length,
            itemBuilder: (context, index) {
              final post = carouselPosts[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PostDetailScreen(post: post),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Gambar latar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: post.imageUrl != null && post.imageUrl!.isNotEmpty
                            ? Image.network(
                                post.imageUrl!,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  color: Colors.grey[300],
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.broken_image,
                                      size: 64, color: Colors.grey),
                                ),
                              )
                            : Container(
                                color: Colors.grey[300],
                                alignment: Alignment.center,
                                child: const Icon(Icons.image,
                                    size: 64, color: Colors.grey),
                              ),
                      ),

                      // Overlay gradient (bawah lebih gelap)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.7),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Badge kategori + Judul + Author (bawah)
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Badge kategori
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 5, 93, 165),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                post.categoryNames?.first ?? 'News',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Judul
                            Text(
                              post.judulId,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                height: 1.3,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),

                            // Author
                            Text(
                              'Dibuat Oleh: ${post.authorName ?? 'Unknown'}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // Dot indicator
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              carouselPosts.length,
              (index) => GestureDetector(
                onTap: () {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
                child: Container(
                  width: _currentCarouselIndex == index ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: _currentCarouselIndex == index
                        ? Color.fromARGB(255, 2, 63, 114)
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 🔹 Widget untuk Tab Filter Kategori (dinamis dari data)
  Widget _buildCategoryTabs(List<PostModel> posts) {
    // Kumpulkan semua kategori unik dari posts
    final Set<int> categoryIds = {};
    final Map<int, String> categoryMap = {};

    for (var post in posts) {
      if (post.categoryIds != null && post.categoryNames != null) {
        for (int i = 0; i < post.categoryIds!.length; i++) {
          categoryIds.add(post.categoryIds![i]);
          categoryMap[post.categoryIds![i]] = post.categoryNames![i];
        }
      }
    }

    final categories = categoryIds.toList();

    if (categories.isEmpty) {
      // Tampilkan pesan jika tidak ada kategori
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Text(
          'Tidak ada kategori tersedia',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Row(
          children: [
            // Tombol "Semua" untuk menampilkan semua post
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategoryId = null;
                });
              },
              child: Column(
                children: [
                  Text(
                    'Semua',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: _selectedCategoryId == null
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: _selectedCategoryId == null
                          ? Colors.black
                          : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_selectedCategoryId == null)
                    Container(
                      height: 3,
                      width: 40,
                      color: Color.fromARGB(255, 2, 63, 114),
                    )
                  else
                    Container(
                      height: 3,
                      width: 40,
                      color: Colors.transparent,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            // Tombol kategori
            for (final categoryId in categories)
              Padding(
                padding: const EdgeInsets.only(right: 24),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategoryId = categoryId;
                    });
                  },
                  child: Column(
                    children: [
                      Text(
                        categoryMap[categoryId] ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: _selectedCategoryId == categoryId
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: _selectedCategoryId == categoryId
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_selectedCategoryId == categoryId)
                        Container(
                          height: 3,
                          width: 40,
                          color: Color.fromARGB(255, 2, 63, 114),
                        )
                      else
                        Container(
                          height: 3,
                          width: 40,
                          color: Colors.transparent,
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 🔹 Widget untuk menampilkan post yang sudah di-filter
  Widget _buildFilteredPostList(List<PostModel> posts) {
    // Filter post berdasarkan kategori yang dipilih
    List<PostModel> filteredPosts = posts;

    if (_selectedCategoryId != null) {
      filteredPosts = posts
          .where((post) =>
              post.categoryIds != null &&
              post.categoryIds!.contains(_selectedCategoryId))
          .toList();
    }

    if (filteredPosts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: Text('Tidak ada berita untuk kategori ini')),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: filteredPosts.length,
      itemBuilder: (context, index) {
        PostModel post = filteredPosts[index];
        return PostCard(post: post);
      },
    );
  }
}
