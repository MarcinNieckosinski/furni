import 'dart:async';
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
import 'package:furniapp/pages/listing_details.dart';
import 'package:furniapp/pages/login.dart';
import 'package:furniapp/pages/register.dart';
import 'package:furniapp/pages/user_listings.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  List<CategoryModel> categories = CategoryModel.getCategories();
  Future<List<LatestSectionsModel>> latestSectionsFuture =
      LatestSectionsModel.getLatestSections();

  List<DocumentSnapshot> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounce;

  User? currentUser;
  String loginName = 'Gość';

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) _fetchLoginName(currentUser!.uid);

    _searchController.addListener(() {
      final query = _searchController.text.trim().toLowerCase();
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 400), () {
        _performSearch(query);
      });
    });
  }

  Future<void> _fetchLoginName(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      setState(() => loginName = doc['login'] ?? 'Gość');
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    final words =
        query.split(RegExp(r'\s+')).where((w) => w.length > 1).toList();
    if (words.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);
    final allDocs = <DocumentSnapshot>[];

    for (final word in words) {
      final snap =
          await FirebaseFirestore.instance
              .collection('listings')
              .where('keywords', arrayContains: word)
              .orderBy('createdAt', descending: true)
              .limit(20)
              .get();
      allDocs.addAll(snap.docs);
    }

    final unique = {for (final doc in allDocs) doc.id: doc}.values.toList();

    setState(() {
      _searchResults = unique;
      _isSearching = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSearching = _searchController.text.isNotEmpty;

    return Scaffold(
      appBar: appBar(),
      backgroundColor: Colors.white,
      drawer: _buildDrawer(),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 30),
        children: [
          SearchField(controller: _searchController, onChanged: (_) {}),
          const SizedBox(height: 10),
          if (isSearching)
            _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('Brak wyników wyszukiwania.'),
                  ),
                )
                : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final doc = _searchResults[index];
                    final data = doc.data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(data['title'] ?? ''),
                      subtitle: Text(
                        '${data['price']} PLN • ${data['city'] ?? ''}',
                      ),
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ListingDetailsPage(listingDoc: doc),
                          ),
                        );
                      },
                    );
                  },
                )
          else ...[
            const SizedBox(height: 40),
            categoriesSection(categories, context),
            const SizedBox(height: 40),
            FutureBuilder<List<LatestSectionsModel>>(
              future: latestSectionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('❌ Błąd: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Brak ogłoszeń.'));
                }

                final sections = snapshot.data!;
                return Column(
                  children: [
                    for (var section in sections) latestSection(section),
                    const Center(child: Text('Furni © by MINT')),
                  ],
                );
              },
            ),
          ],
        ],
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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          }),
          if (isLoggedIn) ...[
            _drawerItem('Twoje ogłoszenia', Icons.list, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserListingsPage()),
              );
            }),
            _drawerItem('Dodaj ogłoszenie', Icons.add_circle_outline, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdditionPage()),
              );
            }),
            _drawerItem('Wyloguj', Icons.logout, _handleLogout),
          ] else ...[
            _drawerItem('Zaloguj się', Icons.login, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            }),
            _drawerItem('Zarejestruj się', Icons.person_add, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterPage()),
              );
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
}
