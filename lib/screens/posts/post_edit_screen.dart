import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';
import '../../config/constants.dart' as constants;

class PostEditScreen extends StatefulWidget {
  final Map<String, dynamic> postData; // data post yang mau diedit

  const PostEditScreen({super.key, required this.postData});

  @override
  State<PostEditScreen> createState() => _PostEditScreenState();
}

class _PostEditScreenState extends State<PostEditScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  late TextEditingController _judulIdController;
  late TextEditingController _judulEnController;
  late TextEditingController _descIdController;
  late TextEditingController _descEnController;
  late TextEditingController _imageUrlController;

  List<dynamic> _categories = [];
  List<int> _selectedCategories = []; 

  @override
  void initState() {
    super.initState();
    
    // Inisialisasi Controller
    _judulIdController = TextEditingController(text: widget.postData['judul_id']);
    _judulEnController = TextEditingController(text: widget.postData['judul_en']);
    _descIdController = TextEditingController(text: widget.postData['description_id']);
    _descEnController = TextEditingController(text: widget.postData['description_en']);
    _imageUrlController = TextEditingController(text: widget.postData['image_url']);

    // PERBAIKAN: Mengamankan inisialisasi kategori dari data yang diterima (Line 42)
    final categoriesData = widget.postData['categories'];

    if (categoriesData is List) {
        // Konversi aman List<dynamic> ke List<int>
        _selectedCategories = categoriesData
            .map((e) => e is int ? e : int.tryParse(e.toString())) 
            .where((id) => id != null) 
            .cast<int>() 
            .toList();
    } else {
        _selectedCategories = [];
    }

    _fetchCategories();
  }
  
  // Dispose Controllers
  @override
  void dispose() {
    _judulIdController.dispose();
    _judulEnController.dispose();
    _descIdController.dispose();
    _descEnController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    final prefs = await SharedPreferences.getInstance();
    // Pastikan Anda mendapatkan token dengan benar dari AuthProvider atau SharedPreferences
    final token = Provider.of<AuthProvider>(context, listen: false).token ?? prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse('${constants.baseUrl}/categories'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _categories = data['data'];
        });
      } else {
        throw Exception('Gagal mengambil kategori');
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengambil kategori')),
        );
      }
    }
  }

  Future<void> _updatePost() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    setState(() => _loading = true);

    try {
      final idToUpdate = widget.postData['id']; // Mengambil ID post dari data yang dikirim

      final response = await http.put(
        Uri.parse('${constants.baseUrl}/posts/$idToUpdate'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'judul_id': _judulIdController.text,
          'judul_en': _judulEnController.text,
          'description_id': _descIdController.text,
          'description_en': _descEnController.text,
          'image_url': _imageUrlController.text,
          'categories': _selectedCategories, // List<int> yang aman
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Postingan berhasil diperbarui!')),
          );
          Navigator.pop(context, true);
        }
      } else {
        final error = json.decode(response.body);
        debugPrint('Error response: ${response.body}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error['message'] ?? 'Gagal memperbarui postingan')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error update post: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Terjadi kesalahan saat memperbarui postingan')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Postingan'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul (Indonesia)
                    TextFormField(
                      controller: _judulIdController,
                      decoration: const InputDecoration(
                        labelText: 'Judul (Bahasa Indonesia) *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Judul wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),

                    // Judul (English)
                    TextFormField(
                      controller: _judulEnController,
                      decoration: const InputDecoration(
                        labelText: 'Judul (English)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Deskripsi (Indonesia)
                    TextFormField(
                      controller: _descIdController,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi (Bahasa Indonesia) *',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Deskripsi wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),

                    // Deskripsi (English)
                    TextFormField(
                      controller: _descEnController,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi (English)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                    ),
                    const SizedBox(height: 16),

                    // URL Gambar
                    TextFormField(
                      controller: _imageUrlController,
                      decoration: const InputDecoration(
                        labelText: 'URL Gambar (opsional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 🔹 Pilihan Kategori
                    const Text(
                      'Kategori:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    if (_categories.isEmpty)
                      const Text('Memuat kategori...')
                    else
                      Wrap(
                        spacing: 10,
                        children: _categories.map((cat) {
                          // Ambil ID kategori dari API response
                          final id = cat['id_kategori']; 
                          final indo = cat['kategori_id'] ?? '';
                          final eng = cat['kategori_en'] ?? '';
                          final displayName = (indo.isNotEmpty && eng.isNotEmpty)
                              ? '$indo ($eng)'
                              : (indo.isNotEmpty ? indo : (eng.isNotEmpty ? eng : 'Tanpa nama'));

                          // Konversi ID ke int secara aman untuk FilterChip
                          int categoryId = 0;
                          if (id is int) {
                            categoryId = id;
                          } else if (id is String) {
                            categoryId = int.tryParse(id) ?? 0;
                          }

                          final isSelected = _selectedCategories.contains(categoryId);

                          return FilterChip(
                            label: Text(displayName),
                            selected: isSelected,
                            onSelected: (bool selected) {
                              setState(() {
                                if (selected) {
                                  // Pastikan hanya ID > 0 yang ditambahkan
                                  if (categoryId > 0) { 
                                    _selectedCategories.add(categoryId);
                                  }
                                } else {
                                  _selectedCategories.remove(categoryId);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 24),

                    // Tombol Submit
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: Text(_loading ? 'Menyimpan...' : 'Simpan Perubahan'),
                        onPressed: _loading ? null : _updatePost,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}