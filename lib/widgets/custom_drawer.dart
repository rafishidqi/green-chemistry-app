import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/post_provider.dart';
import '../providers/translate_provider.dart';
import '../config/translate.dart';
import '../screens/posts/home_screen.dart';
import '../screens/user/dashboard_screen.dart';
import '../screens/auth/login_screen.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final localization = Provider.of<TranslateProvider>(context);

    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(color: Color.fromARGB(255, 2, 63, 114)),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  AppTranslate.translate('welcome', localization.currentLanguage),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  auth.isLoggedIn ? auth.userName ?? "User" : AppTranslate.translate('visitor', localization.currentLanguage),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      auth.isLoggedIn
                        ? AppTranslate.translate('registered', localization.currentLanguage)
                        : AppTranslate.translate('not_logged_in', localization.currentLanguage),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    // Tombol Language Indicator
                    GestureDetector(
                      onTap: () => localization.toggleLanguage(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 1.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          localization.isEnglish ? 'EN' : 'ID',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 🏠 Beranda (All Posts)
          ListTile(
            leading: const Icon(Icons.home),
            title: Text(AppTranslate.translate('home', localization.currentLanguage)),
            onTap: () {
              Provider.of<PostProvider>(context, listen: false).fetchAllPosts();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            },
          ),

          const Divider(),

          // 🔐 Login / Dashboard
          if (!auth.isLoggedIn)
            ListTile(
              leading: const Icon(Icons.login),
              title: Text(AppTranslate.translate('login', localization.currentLanguage)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            )
          else
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: Text(AppTranslate.translate('dashboard', localization.currentLanguage)),
              onTap: () {
                Provider.of<PostProvider>(context, listen: false).fetchUserPosts();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DashboardScreen()),
                );
              },
            ),

          const Spacer(),

          // 🚪 Logout jika sudah login
          if (auth.isLoggedIn)
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(
                AppTranslate.translate('logout', localization.currentLanguage),
                style: const TextStyle(color: Colors.red),
              ),
              onTap: () {
                auth.logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
                );
              },
            ),
        ],
      ),
    );
  }
}
