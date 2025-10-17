
class ApiService {
  static Future<List<Map<String, dynamic>>> getPosts() async {
    await Future.delayed(const Duration(seconds: 1)); // simulasi loading

    return [
      {
        'id_konten': 1,
        'id_author': 1,
        'judul_id': 'Dampak Limbah Plastik Terhadap Lingkungan',
        'judul_en': 'The Impact of Plastic Waste on the Environment',
        'description_id':
            'Limbah plastik menjadi salah satu penyebab utama pencemaran laut. Solusi alternatif seperti bioplastik semakin dikembangkan.',
        'description_en':
            'Plastic waste has become a major cause of ocean pollution. Alternative solutions like bioplastics are being developed.',
        'image_url': null,
        'status': 'published',
        'author': {'name': 'Admin'},
        'categories': [
          {'nama_kategori': 'Lingkungan'},
          {'nama_kategori': 'Sains'}
        ]
      },
      {
        'id_konten': 2,
        'id_author': 2,
        'judul_id': 'Inovasi Energi Hijau di Indonesia',
        'judul_en': 'Green Energy Innovations in Indonesia',
        'description_id':
            'Energi terbarukan seperti panel surya dan turbin angin mulai banyak diterapkan di kawasan timur Indonesia.',
        'description_en':
            'Renewable energy such as solar panels and wind turbines are increasingly implemented in eastern Indonesia.',
        'image_url': null,
        'status': 'published',
        'author': {'name': 'Green Team'},
        'categories': [
          {'nama_kategori': 'Energi'},
          {'nama_kategori': 'Teknologi'}
        ]
      },
    ];
  }
}
