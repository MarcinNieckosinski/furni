import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:furniapp/components/appbar.dart';
import 'package:furniapp/components/categories.dart';
import 'package:furniapp/components/latest.dart';
import 'package:furniapp/models/category_model.dart';
import 'package:furniapp/components/searchfield.dart';
import 'package:furniapp/models/latest_sections_model.dart';
import 'package:furniapp/pages/addition.dart';
import 'package:furniapp/pages/login.dart';
import 'package:furniapp/pages/register.dart';
import 'package:furniapp/pages/user_listings.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<CategoryModel> categories = [];
  Future<List<LatestSectionsModel>> latest = Future.value([]);
  User? currentUser;
  String loginName = 'Gość';

  @override
  void initState() {
    super.initState();
    categories = CategoryModel.getCategories();
    latest = LatestSectionsModel.getLatestSections();
    currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      _fetchLoginName(currentUser!.uid);
    }
  }

  Future<void> _fetchLoginName(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      setState(() {
        loginName = doc.data()?['login'] ?? 'Gość';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      backgroundColor: Colors.white,
      drawer: _buildDrawer(),
      body: FutureBuilder<List<LatestSectionsModel>>(
        future: latest,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('❌ Błąd: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Brak ogłoszeń.'));
          } else {
            final sections = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.only(bottom: 30),
              children: [
                searchField(),
                const SizedBox(height: 40),
                categoriesSection(categories),
                const SizedBox(height: 40),
                for (var section in sections) latestSection(section),
                const Center(child: Text('Furni © by MINT')),
              ],
            );
          }
        },
      ),
    );
  }

  Drawer _buildDrawer() {
    final isLoggedIn = currentUser != null;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _drawerHeader(),
          _drawerItem('Strona główna', () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          }),
          if (!isLoggedIn)
            _drawerItem('Zaloguj się', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            }),
          if (!isLoggedIn)
            _drawerItem('Zarejestruj się', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterPage()),
              );
            }),
          if (isLoggedIn)
            _drawerItem('Twoje ogłoszenia', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserListingsPage()),
              );
            }),
          if (isLoggedIn)
            _drawerItem('Dodaj ogłoszenie', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdditionPage()),
              );
            }),
          if (isLoggedIn) _drawerItem('Wyloguj', _handleLogout),
        ],
      ),
    );
  }

  Widget _drawerHeader() {
    return DrawerHeader(
      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.7)),
      child: Column(
        children: [
          const Image(
            image: AssetImage('assets/images/Portrait_Placeholder.png'),
            height: 80,
          ),
          const SizedBox(height: 8),
          Text(
            loginName,
            style: const TextStyle(color: Colors.white, fontSize: 24),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Czy na pewno chcesz się wylogować?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Anuluj'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Wyloguj'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    }
  }

  Widget _drawerItem(String title, VoidCallback onTap) {
    return ListTile(title: Center(child: Text(title)), onTap: onTap);
  }
}
