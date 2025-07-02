import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:furniapp/pages/listing_details.dart';

class CategoryListingsPage extends StatelessWidget {
  final String categoryName;

  const CategoryListingsPage({super.key, required this.categoryName});

  Future<String?> _getFirstImageUrl(String listingId) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('listings')
          .doc(listingId)
          .collection('images')
          .orderBy('position')
          .limit(1)
          .get();

      if (snap.docs.isNotEmpty) {
        return snap.docs.first['url'] as String;
      }
    } catch (e) {
      debugPrint('Błąd ładowania miniatury: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final query = FirebaseFirestore.instance
        .collection('listings')
        .where('category', isEqualTo: categoryName)
        .orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(title: Text('Kategoria: $categoryName')),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('Brak ogłoszeń w tej kategorii'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final title = data['title'] ?? '';
              final price = data['price'] ?? '';
              final city = data['userCity'] ?? '';

              return FutureBuilder<String?>(
                future: _getFirstImageUrl(doc.id),
                builder: (context, imgSnap) {
                  final imageUrl = imgSnap.data;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                imageUrl,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(Icons.image_not_supported, size: 100),
                      title: Text(title),
                      subtitle: Text('Cena: $price PLN \nMiejscowość: $city'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ListingDetailsPage(listingDoc: doc),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
