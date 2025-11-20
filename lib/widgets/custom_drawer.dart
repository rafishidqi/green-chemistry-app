import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/post_provider.dart';
import '../providers/translate_provider.dart';
import '../config/translate.dart';
import '../screens/posts/home_screen.dart';
import '../screens/user/dashboard_screen.dart';
import '../screens/auth/login_screen.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // Mulai animasi saat drawer dibuka
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final localization = Provider.of<TranslateProvider>(context);

    return Drawer(
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            // Header dengan animasi fade-in
            FadeTransition(
              opacity: _animationController,
              child: Container(
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
                        // Tombol Language Indicator dengan animasi
                        GestureDetector(
                          onTap: () => localization.toggleLanguage(),
                          child: ScaleTransition(
                            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                              CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
                            ),
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
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 🏠 Beranda (All Posts) dengan animasi
            _buildAnimatedListTile(
              delay: 0,
              icon: Icons.home,
              title: AppTranslate.translate('home', localization.currentLanguage),
              onTap: () {
                Provider.of<PostProvider>(context, listen: false).fetchAllPosts();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              },
            ),

            const Divider(),

            // 🔐 Login / Dashboard dengan animasi
            if (!auth.isLoggedIn)
              _buildAnimatedListTile(
                delay: 1,
                icon: Icons.login,
                title: AppTranslate.translate('login', localization.currentLanguage),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
              )
            else
              _buildAnimatedListTile(
                delay: 1,
                icon: Icons.dashboard,
                title: AppTranslate.translate('dashboard', localization.currentLanguage),
                onTap: () {
                  Provider.of<PostProvider>(context, listen: false).fetchUserPosts();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DashboardScreen()),
                  );
                },
              ),

            const Spacer(),

            // 🚪 Logout jika sudah login dengan animasi
            if (auth.isLoggedIn)
              _buildAnimatedListTile(
                delay: 2,
                icon: Icons.logout,
                title: AppTranslate.translate('logout', localization.currentLanguage),
                isLogout: true,
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
      ),
    );
  }

  // Helper method untuk membuat ListTile dengan animasi staggered
  Widget _buildAnimatedListTile({
    required int delay,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    final delayedAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          delay * 0.1,
          delay * 0.1 + 0.3,
          curve: Curves.easeOut,
        ),
      ),
    );

    return FadeTransition(
      opacity: delayedAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.3, 0.0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              delay * 0.1,
              delay * 0.1 + 0.3,
              curve: Curves.easeOutCubic,
            ),
          ),
        ),
        child: ListTile(
          leading: Icon(icon, color: isLogout ? Colors.red : null),
          title: Text(
            title,
            style: isLogout ? const TextStyle(color: Colors.red) : null,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
