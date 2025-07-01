import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class ListingDetailsPage extends StatelessWidget {
  final DocumentSnapshot listingDoc;

  const ListingDetailsPage({super.key, required this.listingDoc});

  @override
  Widget build(BuildContext context) {
    final data = listingDoc.data() as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(title: Text(data['title'] ?? 'Szczegóły')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data['title'] ?? '',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('Kategoria: ${data['category']}'),
            const SizedBox(height: 12),
            Text(
              'Cena: ${data['price']} zł',
              style: const TextStyle(fontSize: 20, color: Colors.green),
            ),
            const SizedBox(height: 12),
            Text(
              data['description'] ?? '',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Zdjęcia',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            FutureBuilder<List<String>>(
              future: fetchImageUrls(data['category'], listingDoc.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return const Text('Brak zdjęć do wyświetlenia');
                } else {
                  final urls = snapshot.data!;
                  return SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: urls.length,
                      itemBuilder:
                          (context, index) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                urls[index],
                                width: 160,
                                height: 160,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<List<String>> fetchImageUrls(String category, String listingId) async {
    final List<String> imageUrls = [];
    final storage = FirebaseStorage.instance;

    for (int i = 0; i < 8; i++) {
      final path = 'listings/$category/$listingId/${listingId}_image_$i.jpg';
      try {
        final url = await storage.ref(path).getDownloadURL();
        imageUrls.add(url);
      } catch (e) {
        break; // przerywamy, gdy nie ma więcej zdjęć
      }
    }

    return imageUrls;
  }
}
