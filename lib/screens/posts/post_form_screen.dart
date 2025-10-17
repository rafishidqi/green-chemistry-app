import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';
import '../../config/constants.dart' as constants;

class PostFormScreen extends StatefulWidget {
  const PostFormScreen({super.key});

  @override
  State<PostFormScreen> createState() => _PostFormScreenState();
}

class _PostFormScreenState extends State<PostFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  final _judulIdController = TextEditingController();
  final _judulEnController = TextEditingController();
  final _descIdController = TextEditingController();
  final _descEnController = TextEditingController();
  final _imageUrlController = TextEditingController();

  List<dynamic> _categories = [];
  List<int> _selectedCategories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengambil kategori')),
      );
    }
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    setState(() => _loading = true);

    try {
      final response = await http.post(
        Uri.parse('${constants.baseUrl}/posts'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json', // WAJIB ADA INI
        },
        body: jsonEncode({
          'judul_id': _judulIdController.text,
          'judul_en': _judulEnController.text,
          'description_id': _descIdController.text,
          'description_en': _descEnController.text,
          'image_url': _imageUrlController.text,
          'categories': _selectedCategories, // kirim array langsung
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Postingan berhasil dikirim!')),
        );
        Navigator.pop(context);
      } else {
        final error = json.decode(response.body);
        debugPrint('Error response: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error['message'] ?? 'Gagal mengirim postingan')),
        );
      }
    } catch (e) {
      debugPrint('Error submit post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan saat mengirim postingan')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Postingan Baru'),
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
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    if (_categories.isEmpty)
                      const Text('Memuat kategori...')
                    else
                      Wrap(
                        spacing: 10,
                        children: _categories.map((cat) {
                          final id = cat['id_kategori'];
                          final indo = cat['kategori_id'] ?? '';
                          final eng = cat['kategori_en'] ?? '';
                          final displayName = (indo.isNotEmpty && eng.isNotEmpty)
                              ? '$indo ($eng)'
                              : (indo.isNotEmpty ? indo : (eng.isNotEmpty ? eng : 'Tanpa nama'));

                          final isSelected = _selectedCategories.contains(id);

                          return FilterChip(
                            label: Text(displayName),
                            selected: isSelected,
                            onSelected: (bool selected) {
                              setState(() {
                                if (selected) {
                                  _selectedCategories.add(id);
                                } else {
                                  _selectedCategories.remove(id);
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
                        icon: const Icon(Icons.send),
                        label: Text(_loading ? 'Mengirim...' : 'Kirim Postingan'),
                        onPressed: _loading ? null : _submitPost,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
