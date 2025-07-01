import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:furniapp/components/appbar.dart';
import 'package:furniapp/components/categories.dart';
import 'package:furniapp/components/latest.dart';
import 'package:furniapp/components/searchfield.dart';
import 'package:furniapp/models/category_model.dart';
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
  late final List<CategoryModel> categories;
  Future<List<LatestSectionsModel>> latestSectionsFuture = LatestSectionsModel.getLatestSections();

  User? currentUser;
  String loginName = 'Gość';

  @override
  void initState() {
    super.initState();
    categories = CategoryModel.getCategories();
    latestSectionsFuture = LatestSectionsModel.getLatestSections();
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _fetchLoginName(currentUser!.uid);
    }
  }

  Future<void> _fetchLoginName(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
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
        future: latestSectionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('❌ Błąd: ${snapshot.error}'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        latestSectionsFuture = LatestSectionsModel.getLatestSections();
                      });
                    },
                    child: const Text('Spróbuj ponownie'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Brak ogłoszeń.'));
          }

          final sections = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.only(bottom: 30),
            children: [
              searchField(),
              const SizedBox(height: 40),
              categoriesSection(categories, context),
              const SizedBox(height: 40),
              for (var section in sections) latestSection(section),
              const Center(child: Text('Furni © by MINT')),
            ],
          );
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
          _drawerItem('Strona główna', Icons.home, () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
          }),
          if (isLoggedIn) ...[
            _drawerItem('Twoje ogłoszenia', Icons.list, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const UserListingsPage()));
            }),
            _drawerItem('Dodaj ogłoszenie', Icons.add_circle_outline, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdditionPage()));
            }),
            _drawerItem('Wyloguj', Icons.logout, _handleLogout),
          ] else ...[
            _drawerItem('Zaloguj się', Icons.login, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
            }),
            _drawerItem('Zarejestruj się', Icons.person_add, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage()));
            }),
          ],
        ],
      ),
    );
  }

  Widget _drawerHeader() {
    return DrawerHeader(
      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.7)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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

  Widget _drawerItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Czy na pewno chcesz się wylogować?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Anuluj')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Wyloguj')),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
    }
  }
}
