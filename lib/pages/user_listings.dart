import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
    _fetchListings();
  }

  void _fetchListings() {
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

  void _confirmDelete(DocumentSnapshot listingDoc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Usuń ogłoszenie'),
        content: const Text('Czy na pewno chcesz usunąć to ogłoszenie?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Anuluj'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _deleteListing(listingDoc);
            },
            child: const Text('Usuń', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteListing(DocumentSnapshot listingDoc) async {
    final id = listingDoc.id;
    final firestore = FirebaseFirestore.instance;
    final storage = FirebaseStorage.instance;

    try {
      // Usuń zdjęcia z subkolekcji
      final imagesSnap = await firestore.collection('listings').doc(id).collection('images').get();
      for (final doc in imagesSnap.docs) {
        final url = doc['url'] as String;
        try {
          final ref = storage.refFromURL(url);
          await ref.delete();
        } catch (_) {}
        await doc.reference.delete(); // usuń metadane
      }

      // Usuń ogłoszenie
      await firestore.collection('listings').doc(id).delete();

      if (mounted) {
        _fetchListings();
        setState(() {}); // odśwież widok
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ogłoszenie zostało usunięte')),
        );
      }
    } catch (e) {
      debugPrint('Błąd usuwania ogłoszenia: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nie udało się usunąć ogłoszenia')),
      );
    }
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
              final listingId = listing.id;
              final title = listing['title'] ?? '';
              final price = listing['price'] ?? '';

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
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
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
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDelete(listing),
                          ),
                        ],
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
