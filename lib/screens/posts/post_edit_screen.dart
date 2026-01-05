import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';
import '../../providers/translate_provider.dart';
import '../../config/constants.dart' as constants;
import '../../config/translate.dart';

class PostEditScreen extends StatefulWidget {
  final Map<String, dynamic> postData;

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

    // Debug: Print semua data post
    debugPrint('=== POST EDIT DEBUG ===');
    debugPrint('Full postData: ${widget.postData}');
    debugPrint('Categories raw: ${widget.postData['categories']}');
    debugPrint('Categories type: ${widget.postData['categories'].runtimeType}');
    
    // Inisialisasi kategori terpilih dari data post
    final categoriesData = widget.postData['categories'];
    
    if (categoriesData is List && categoriesData.isNotEmpty) {
      debugPrint('Categories list length: ${categoriesData.length}');
      for (int i = 0; i < categoriesData.length; i++) {
        debugPrint('Category $i: ${categoriesData[i]} (${categoriesData[i].runtimeType})');
      }
      
      // Data dari PostModel.toMap() sudah berupa List<int>
      _selectedCategories = categoriesData
          .where((id) => id is int && id > 0)
          .cast<int>()
          .toList();
      
      debugPrint('Selected categories after parsing: $_selectedCategories');
    } else {
      debugPrint('Categories data is empty or not a List');
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
    // Ambil token sebelum async operation
    final authToken = Provider.of<AuthProvider>(context, listen: false).token;

    final prefs = await SharedPreferences.getInstance();
    // Pastikan Anda mendapatkan token dengan benar dari AuthProvider atau SharedPreferences
    final token = authToken ?? prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse('${constants.baseUrl}/categories'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('=== CATEGORIES FROM API ===');
        debugPrint('API Categories: ${data['data']}');
        setState(() {
          _categories = data['data'];
          debugPrint('Selected categories in setState: $_selectedCategories');
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
      final idToUpdate = widget.postData['id'];

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
          'categories': _selectedCategories,
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final localization = Provider.of<TranslateProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: isSmallScreen
                  ? Container(
                      width: double.infinity,
                      height: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    AppTranslate.translate('edit_post', localization.currentLanguage),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => Navigator.pop(context),
                                    icon: const Icon(Icons.close, color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ..._buildFormFields(),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.all(24),
                        constraints: const BoxConstraints(maxWidth: 500),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      AppTranslate.translate('edit_post', localization.currentLanguage),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => Navigator.pop(context),
                                      icon: const Icon(Icons.close, color: Colors.grey),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  height: 3,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ..._buildFormFields(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
    );
  }

  List<Widget> _buildFormFields() {
    return [
      Text(
        'Judul',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey[700],
        ),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: _judulIdController,
        decoration: InputDecoration(
          hintText: 'Masukkan judul postingan',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        validator: (val) => val == null || val.isEmpty ? 'Judul wajib diisi' : null,
      ),
      const SizedBox(height: 20),

      Text(
        'Judul (English)',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey[700],
        ),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: _judulEnController,
        decoration: InputDecoration(
          hintText: 'Enter title in English',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
      const SizedBox(height: 20),

      Text(
        'Deskripsi',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey[700],
        ),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: _descIdController,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: 'Masukkan deskripsi postingan',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        validator: (val) => val == null || val.isEmpty ? 'Deskripsi wajib diisi' : null,
      ),
      const SizedBox(height: 20),

      Text(
        'Deskripsi (English)',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey[700],
        ),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: _descEnController,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: 'Enter description in English',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
      const SizedBox(height: 20),

      Text(
        'URL Gambar',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey[700],
        ),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: _imageUrlController,
        decoration: InputDecoration(
          hintText: 'https://example.com/image.jpg',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
      const SizedBox(height: 20),

      Text(
        'Kategori',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey[700],
        ),
      ),
      const SizedBox(height: 12),
      if (_categories.isEmpty)
        const Text('Memuat kategori...')
      else
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((cat) {
            final id = cat['id_kategori'];
            final indo = cat['kategori_id'] ?? '';
            final eng = cat['kategori_en'] ?? '';
            final displayName = (indo.isNotEmpty && eng.isNotEmpty)
                ? '$indo ($eng)'
                : (indo.isNotEmpty ? indo : (eng.isNotEmpty ? eng : 'Tanpa nama'));

            int categoryId = 0;
            if (id is int) {
              categoryId = id;
            } else if (id is String) {
              categoryId = int.tryParse(id) ?? 0;
            }

            final isSelected = _selectedCategories.contains(categoryId);
            
            // Debug untuk setiap kategori
            debugPrint('Category: $displayName, ID: $categoryId, Selected: $isSelected, SelectedList: $_selectedCategories');

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedCategories.remove(categoryId);
                  } else {
                    if (categoryId > 0) {
                      _selectedCategories.add(categoryId);
                    }
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue[100] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey[300]!,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected)
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                    Text(
                      displayName,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.blue[700] : Colors.grey[600],
                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      const SizedBox(height: 32),

      Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: Colors.grey[300]!),
              ),
              child: const Text(
                'Batal',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _loading ? null : _updatePost,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _loading ? 'Menyimpan...' : 'Simpan',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    ];
  }


}