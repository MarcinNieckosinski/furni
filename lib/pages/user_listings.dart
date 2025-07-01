import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:furniapp/pages/edit_listing.dart';
import 'package:furniapp/pages/listing_details.dart';

class UserListingsPage extends StatefulWidget {
  const UserListingsPage({super.key});

  @override
  State<UserListingsPage> createState() => _UserListingsPageState();
}

class _UserListingsPageState extends State<UserListingsPage> {
  late Future<QuerySnapshot> _listingsFuture;

  @override
  void initState() {
    super.initState();
    _listingsFuture = FirebaseFirestore.instance
        .collection('listings')
        .orderBy('createdAt', descending: true)
        .get();
  }

  Future<String?> _getFirstImageUrl(String listingId) async {
    try {
      final imagesSnap = await FirebaseFirestore.instance
          .collection('listings')
          .doc(listingId)
          .collection('images')
          .orderBy('position')
          .limit(1)
          .get();

      if (imagesSnap.docs.isNotEmpty) {
        return imagesSnap.docs.first['url'] as String;
      }
    } catch (e) {
      debugPrint('Błąd ładowania miniatury: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Moje ogłoszenia')),
      body: FutureBuilder<QuerySnapshot>(
        future: _listingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Brak ogłoszeń.'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final listing = docs[index];
              final title = listing['title'] ?? '';
              final price = listing['price'] ?? '';
              final listingId = listing.id;

              return FutureBuilder<String?>(
                future: _getFirstImageUrl(listingId),
                builder: (context, imgSnapshot) {
                  final imageUrl = imgSnapshot.data;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                imageUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(Icons.image_not_supported, size: 60),
                      title: Text(title),
                      subtitle: Text('Cena: $price PLN'),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditListingPage(listingDoc: listing),
                            ),
                          );
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ListingDetailsPage(listingDoc: listing),
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
