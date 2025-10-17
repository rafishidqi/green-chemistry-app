class CategoryModel {
  final int id;
  final String name;

  CategoryModel({required this.id, required this.name});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id_kategori'],
      name: json['kategori_id'] ?? json['kategori_en'] ?? 'Tanpa nama',
    );
  }
}
