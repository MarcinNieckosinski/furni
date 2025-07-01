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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<CategoryModel> categories = [];
  Future<List<LatestSectionsModel>> latest = Future.value([]);

  void initState() {
    super.initState();
    _getInitialInfo();
  }

  void _getCategories() {
    categories = CategoryModel.getCategories();
  }

  void _getLatestSections() {
    latest = LatestSectionsModel.getLatestSections();
  }

  void _getInitialInfo() {
    _getCategories();
    _getLatestSections();
  }

  @override
  Widget build(BuildContext context) {
    _getInitialInfo();

    return Scaffold(
      appBar: appBar(),
      backgroundColor: Colors.white,
      drawer: drawer(),
      body: FutureBuilder<List<LatestSectionsModel>>(
        future: latest,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('❌ Błąd: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Brak ogłoszeń.'));
          } else {
            final sections = snapshot.data!;
            return ListView(
              children: [
                searchField(),
                const SizedBox(height: 40),
                categoriesSection(categories),
                const SizedBox(height: 40),
                for (var section in sections) latestSection(section),
                const Center(child: Text('Furni \u00a9 by MINT')),
              ],
            );
          }
        },
      ),
    );
  }

  Drawer drawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.7),
            ),
            child: Column(
              children: [
                Image(
                  image: AssetImage('assets/images/Portrait_Placeholder.png'),
                  height: 80,
                ),
                Text(
                  'Gościnny Gość',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ],
            ),
          ),
          ListTile(
            title: Center(child: Text('Strona główna')),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
          ),
          ListTile(
            title: Center(child: Text('Zaloguj się')),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
          ListTile(
            title: Center(child: Text('Zarejestruj się')),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RegisterPage()),
              );
            },
          ),
          ListTile(
            title: Center(child: Text('Dodaj ogłoszenie')),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdditionPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
