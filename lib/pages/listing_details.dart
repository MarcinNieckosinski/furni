import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ListingDetailsPage extends StatefulWidget {
  final DocumentSnapshot listingDoc;

  const ListingDetailsPage({super.key, required this.listingDoc});

  @override
  State<ListingDetailsPage> createState() => _ListingDetailsPageState();
}

class _ListingDetailsPageState extends State<ListingDetailsPage> {
  List<String> imageUrls = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    try {
      final docId = widget.listingDoc.id;
      final imagesSnap =
          await FirebaseFirestore.instance
              .collection('listings')
              .doc(docId)
              .collection('images')
              .orderBy('position') // lub orderBy('createdAt')
              .get();

      setState(() {
        imageUrls = imagesSnap.docs.map((doc) => doc['url'] as String).toList();
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Błąd podczas ładowania zdjęć: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.listingDoc.data() as Map<String, dynamic>;
    final title = data['title'] ?? '';
    final description = data['description'] ?? '';
    final price = data['price'] ?? '';
    final category = data['category'] ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Szczegóły ogłoszenia')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (imageUrls.isNotEmpty)
                      SizedBox(
                        height: 250,
                        child: PageView.builder(
                          itemCount: imageUrls.length,
                          itemBuilder: (context, index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                imageUrls[index],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                loadingBuilder:
                                    (_, child, progress) =>
                                        progress != null
                                            ? const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            )
                                            : child,
                                errorBuilder:
                                    (_, __, ___) => const Icon(
                                      Icons.broken_image,
                                      size: 80,
                                    ),
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 20),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Kategoria: $category',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    Text(description),
                    const SizedBox(height: 20),
                    Text(
                      'Cena: $price PLN',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
    );
  }
}
