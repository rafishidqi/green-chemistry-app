import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/post_provider.dart';
import '../screens/posts/home_screen.dart';
import '../screens/user/dashboard_screen.dart';
import '../screens/auth/login_screen.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              auth.isLoggedIn ? auth.userName ?? "User" : "Pengunjung",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(auth.isLoggedIn ? "Terdaftar" : "Belum login"),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.green),
            ),
            decoration: const BoxDecoration(color: Colors.green),
          ),

          // 🏠 Beranda (All Posts)
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Beranda'),
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
              title: const Text('Login'),
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
              title: const Text('Dashboard'),
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
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
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
