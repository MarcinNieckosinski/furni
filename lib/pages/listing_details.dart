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
      appBar: AppBar(
        title: Text(data['title'] ?? 'Szczegóły'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              data['title'] ?? '',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('📦 Kategoria: ${data['category'] ?? 'brak'}'),
            const SizedBox(height: 12),
            Text(
              '💰 Cena: ${data['price'] ?? 'n/a'} zł',
              style: const TextStyle(fontSize: 20, color: Colors.green),
            ),
            const SizedBox(height: 12),
            Text(
              data['description'] ?? '',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              '📷 Zdjęcia',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildImageGallery(data['category'], listingDoc.id),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGallery(String category, String listingId) {
    return FutureBuilder<List<String>>(
      future: _fetchImageUrls(category, listingId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('Brak zdjęć do wyświetlenia');
        } else {
          final urls = snapshot.data!;
          return SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: urls.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) => ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  urls[index],
                  width: 160,
                  height: 160,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.broken_image, size: 80, color: Colors.grey),
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Future<List<String>> _fetchImageUrls(String category, String listingId) async {
    final storage = FirebaseStorage.instance;
    final List<String> urls = [];

    for (int i = 0; i < 8; i++) {
      final path = 'listings/$category/$listingId/${listingId}_image_$i.jpg';
      try {
        final url = await storage.ref(path).getDownloadURL();
        urls.add(url);
      } catch (_) {
        break; // kończymy iterację, gdy zdjęcia się kończą
      }
    }

    return urls;
  }
}
