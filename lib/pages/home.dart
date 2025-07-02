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
  bool _showFilters = false;
  String? _selectedCity;
  String? _selectedCategory;
  RangeValues _priceRange = const RangeValues(0, 10000);
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

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
    final words =
        query
            .trim()
            .toLowerCase()
            .split(RegExp(r'\s+'))
            .where((w) => w.isNotEmpty)
            .toList();

    final selectedCity =
        _cityController.text.trim().isEmpty
            ? null
            : _cityController.text.trim();

    final hasFilters =
        selectedCity != null ||
        _selectedCategory != null ||
        _priceRange != const RangeValues(0, 10000);

    if (words.isEmpty && !hasFilters) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);
    final allDocs = <DocumentSnapshot>[];

    try {
      if (words.isEmpty) {
        // 🔍 Brak frazy — pobierz najnowsze ogłoszenia i przefiltruj lokalnie
        final snap =
            await FirebaseFirestore.instance
                .collection('listings')
                .orderBy('createdAt', descending: true)
                .limit(50)
                .get();

        allDocs.addAll(snap.docs.where(_filterDoc));
      } else {
        // 🔍 Szukaj według słów kluczowych + filtruj lokalnie
        for (final word in words) {
          final snap =
              await FirebaseFirestore.instance
                  .collection('listings')
                  .where('keywords', arrayContains: word)
                  .orderBy('createdAt', descending: true)
                  .limit(20)
                  .get();

          allDocs.addAll(snap.docs.where(_filterDoc));
        }
      }

      final unique = {for (var doc in allDocs) doc.id: doc}.values.toList();

      setState(() {
        _searchResults = unique;
        _isSearching = false;
      });
    } catch (e) {
      debugPrint('Błąd wyszukiwania: $e');
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  bool _filterDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final cityInput = _cityController.text.trim().toLowerCase();
    final cityMatch =
        cityInput.isEmpty ||
        (data['userCity']?.toString().toLowerCase().contains(cityInput) ??
            false);

    final categoryMatch =
        _selectedCategory == null || data['category'] == _selectedCategory;
    final rawPrice = data['price'];
    double price = 0.0;

    if (rawPrice is num) {
      price = rawPrice.toDouble();
    } else if (rawPrice is String) {
      price = double.tryParse(rawPrice.replaceAll(',', '.')) ?? 0.0;
    }

    final priceMatch = price >= _priceRange.start && price <= _priceRange.end;
    return cityMatch && categoryMatch && priceMatch;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _cityController.dispose();
    super.dispose();
  }

  Widget _buildDropdown<T>({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButton<String>(
      hint: Text(label),
      value: value,
      items:
          items
              .map(
                (item) =>
                    DropdownMenuItem<String>(value: item, child: Text(item)),
              )
              .toList(),
      onChanged: onChanged,
    );
  }

  Future<void> _handleRefresh() async {
    FocusScope.of(context).unfocus();

    // Odśwież dane na podstawie aktualnej frazy i filtrów
    final query = _searchController.text.trim();
    await _performSearch(query);

    // Możesz też dodać logikę do odświeżania kategorii/sekcji:
    latestSectionsFuture = LatestSectionsModel.getLatestSections();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final hasQuery = _searchController.text.trim().isNotEmpty;
    final hasFilters =
        _selectedCity != null ||
        _selectedCategory != null ||
        _priceRange != const RangeValues(0, 10000);
    final hasActiveSearch = hasQuery || hasFilters;

    return SafeArea(
      child: Scaffold(
        appBar: appBar(),
        backgroundColor: Colors.white,
        drawer: _buildDrawer(),
        body: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 30),
            children: [
              SearchField(controller: _searchController, onChanged: (_) {}),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => setState(() => _showFilters = !_showFilters),
                  icon: Icon(
                    _showFilters ? Icons.filter_alt_off : Icons.filter_alt,
                  ),
                  label: Text(_showFilters ? 'Ukryj filtry' : 'Pokaż filtry'),
                ),
              ),
              if (_showFilters)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Filtry',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          SizedBox(
                            width: 200,
                            child: TextField(
                              controller: _cityController,
                              decoration: const InputDecoration(
                                labelText: 'Miasto',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
      
                          _buildDropdown<String>(
                            label: 'Kategoria',
                            value: _selectedCategory,
                            items: categories.map((c) => c.name).toList(),
                            onChanged: (val) => _selectedCategory = val,
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      const Text('Cena'),
                      RangeSlider(
                        values: _priceRange,
                        min: 0,
                        max: 10000,
                        divisions: 20,
                        labels: RangeLabels(
                          '${_priceRange.start.toInt()} zł',
                          '${_priceRange.end.toInt()} zł',
                        ),
                        onChanged: (range) => setState(() => _priceRange = range),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _selectedCity = null;
                                _selectedCategory = null;
                                _priceRange = const RangeValues(0, 10000);
                                _cityController.clear();
                              });
                            },
                            icon: const Icon(Icons.clear),
                            label: const Text('Wyczyść filtry'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              setState(() {
                                _selectedCity =
                                    _cityController.text.trim().isEmpty
                                        ? null
                                        : _cityController.text.trim();
                              });
                              _performSearch(_searchController.text.trim());
                            },
                            icon: const Icon(Icons.filter_alt),
                            label: const Text('Zastosuj filtry'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
      
              const SizedBox(height: 10),
              if (hasActiveSearch)
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
                                builder:
                                    (_) => ListingDetailsPage(listingDoc: doc),
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
        ),
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
