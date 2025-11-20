class AppTranslate {
  static const Map<String, Map<String, String>> translations = {
    'id': {
      // Drawer
      'welcome': 'Selamat Datang',
      'registered': 'Terdaftar',
      'not_logged_in': 'Belum login',
      'visitor': 'Pengunjung',
      'home': 'Beranda',
      'login': 'Login',
      'dashboard': 'Dashboard',
      'logout': 'Logout',
      'language': 'EN/ID',

      // Home Screen
      'all_posts': 'Semua Postingan',
      'no_posts': 'Tidak ada postingan',
      'news_title': 'Berita Sensor Dan Kimia Hijau',
      'all_categories': 'Semua',
      'no_categories': 'Tidak ada kategori tersedia',

      // Post Detail
      'see_more': 'Lihat Selengkapnya',
      'see_less': 'Lihat Lebih Sedikit',
      'edit': 'Edit',
      'delete': 'Hapus',
      'confirm_delete': 'Apakah Anda yakin ingin menghapus postingan ini?',
      'cancel': 'Batal',
      'deleted_success': 'Postingan berhasil dihapus',
      'category': 'Kategori',

      // Post Form
      'create_post': 'Buat Postingan',
      'edit_post': 'Edit Postingan',
      'created_by': 'Dibuat Oleh',
      'title_id': 'Judul (Indonesia)',
      'title_en': 'Judul (Inggris)',
      'description_id': 'Deskripsi (Indonesia)',
      'description_en': 'Deskripsi (Inggris)',
      'select_category': 'Pilih Kategori',
      'select_image': 'Pilih Gambar',
      'upload_image': 'Unggah Gambar',
      'save': 'Simpan',
      'submit': 'Kirim',
      'loading': 'Memuat...',
      'error': 'Terjadi kesalahan',
      'success': 'Berhasil',

      // Auth
      'email': 'Email',
      'password': 'Kata Sandi',
      'confirm_password': 'Konfirmasi Kata Sandi',
      'name': 'Nama',
      'register': 'Daftar',
      'sign_in': 'Masuk',
      'sign_up': 'Buat Akun',
      'forgot_password': 'Lupa Kata Sandi?',
      'dont_have_account': 'Belum punya akun?',
      'already_have_account': 'Sudah punya akun?',

      // Categories
      'cat_green_chemistry': 'Kimia Hijau',
      'cat_renewable_energy': 'Energi Terbarukan',
      'cat_environment': 'Lingkungan',
      'cat_biotechnology': 'Bioteknologi',
      'cat_materials': 'Material',
      'cat_food_technology': 'Teknologi Pangan',
      'cat_nanotechnology': 'Nanoteknologi',
      'cat_environmental_engineering': 'Rekayasa Lingkungan',
      'cat_green_pharmacy': 'Farmasi Hijau',
      'cat_waste_management': 'Pengelolaan Limbah',
      'cat_clean_water_technology': 'Teknologi Air Bersih',
    },
    'en': {
      // Drawer
      'welcome': 'Welcome',
      'registered': 'Registered',
      'not_logged_in': 'Not logged in',
      'visitor': 'Visitor',
      'home': 'Home',
      'login': 'Login',
      'dashboard': 'Dashboard',
      'logout': 'Logout',
      'language': 'EN/ID',

      // Home Screen
      'all_posts': 'All Posts',
      'no_posts': 'No posts available',
      'news_title': 'Sensor and Green Chemistry News',
      'all_categories': 'All',
      'no_categories': 'No categories available',

      // Post Detail
      'see_more': 'See More',
      'see_less': 'See Less',
      'edit': 'Edit',
      'delete': 'Delete',
      'confirm_delete': 'Are you sure you want to delete this post?',
      'cancel': 'Cancel',
      'deleted_success': 'Post deleted successfully',
      'category': 'Category',

      // Post Form
      'create_post': 'Create Post',
      'edit_post': 'Edit Post',
      'created_by': 'Created By',
      'title_id': 'Title (Indonesian)',
      'title_en': 'Title (English)',
      'description_id': 'Description (Indonesian)',
      'description_en': 'Description (English)',
      'select_category': 'Select Category',
      'select_image': 'Select Image',
      'upload_image': 'Upload Image',
      'save': 'Save',
      'submit': 'Submit',
      'loading': 'Loading...',
      'error': 'An error occurred',
      'success': 'Success',

      // Auth
      'email': 'Email',
      'password': 'Password',
      'confirm_password': 'Confirm Password',
      'name': 'Name',
      'register': 'Register',
      'sign_in': 'Sign In',
      'sign_up': 'Sign Up',
      'forgot_password': 'Forgot Password?',
      'dont_have_account': "Don't have an account?",
      'already_have_account': 'Already have an account?',

      // Categories
      'cat_green_chemistry': 'Green Chemistry',
      'cat_renewable_energy': 'Renewable Energy',
      'cat_environment': 'Environment',
      'cat_biotechnology': 'Biotechnology',
      'cat_materials': 'Materials',
      'cat_food_technology': 'Food Technology',
      'cat_nanotechnology': 'Nanotechnology',
      'cat_environmental_engineering': 'Environmental Engineering',
      'cat_green_pharmacy': 'Green Pharmacy',
      'cat_waste_management': 'Waste Management',
      'cat_clean_water_technology': 'Clean Water Technology',
    },
  };

  static String translate(String key, String languageCode) {
    return translations[languageCode]?[key] ?? key;
  }
}

