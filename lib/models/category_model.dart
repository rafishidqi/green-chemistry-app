class CategoryModel {
  final int id;
  final String nameId;  // Nama kategori dalam Bahasa Indonesia
  final String nameEn;  // Nama kategori dalam Bahasa Inggris

  CategoryModel({
    required this.id,
    required this.nameId,
    required this.nameEn,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id_kategori'],
      nameId: json['kategori_id'] ?? 'Tanpa nama',
      nameEn: json['kategori_en'] ?? 'No name',
    );
  }

  // Helper method untuk mendapatkan nama berdasarkan bahasa
  String getName(String languageCode) {
    return languageCode == 'en' ? nameEn : nameId;
  }

  // Helper method untuk mendapatkan nama bilingual (Indonesia - English)
  String getDisplayName() {
    return '$nameId - $nameEn';
  }
}
