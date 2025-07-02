import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

class ListingDetailsPage extends StatefulWidget {
  final DocumentSnapshot listingDoc;

  const ListingDetailsPage({super.key, required this.listingDoc});

  @override
  State<ListingDetailsPage> createState() => _ListingDetailsPageState();
}

class _ListingDetailsPageState extends State<ListingDetailsPage> {
  final _pageController = PageController();
  List<String> imageUrls = [];
  bool isLoading = true;

  String ownerLogin = '';
  String ownerPhone = '';
  String ownerCity = '';

  @override
  void initState() {
    super.initState();
    _loadImagesAndOwnerDetails();
  }

  Future<void> _loadImagesAndOwnerDetails() async {
    final data = widget.listingDoc.data() as Map<String, dynamic>;
    final listingId = widget.listingDoc.id;
    final userId = data['userId'] as String?;

    try {
      final imagesSnap = await FirebaseFirestore.instance
          .collection('listings')
          .doc(listingId)
          .collection('images')
          .orderBy('position')
          .get();

      setState(() {
        imageUrls = imagesSnap.docs.map((doc) => doc['url'] as String).toList();
      });

      if (userId != null) {
        final userSnap = await FirebaseFirestore.instance.collection('users').doc(userId).get();
        if (userSnap.exists) {
          final userData = userSnap.data()!;
          setState(() {
            ownerLogin = userData['login'] ?? '';
            ownerPhone = userData['phone'] ?? '';
            ownerCity = userData['city'] ?? '';
          });
        }
      }
    } catch (e) {
      debugPrint('Błąd ładowania danych szczegółowych: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _callSeller(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nie można wykonać połączenia')),
      );
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🖼️ Galeria zdjęć
                  if (imageUrls.isNotEmpty) ...[
                    SizedBox(
                      height: 250,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: imageUrls.length,
                        itemBuilder: (_, index) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              imageUrls[index],
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder: (_, child, progress) =>
                                  progress != null
                                      ? const Center(child: CircularProgressIndicator())
                                      : child,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.broken_image, size: 80),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: SmoothPageIndicator(
                        controller: _pageController,
                        count: imageUrls.length,
                        effect: const WormEffect(
                          dotHeight: 8,
                          dotWidth: 8,
                          activeDotColor: Colors.blue,
                        ),
                      ),
                    ),
                  ] else
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(child: Text('Brak zdjęć')),
                    ),

                  const SizedBox(height: 20),
                  Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text('Kategoria: $category', style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 20),

                  Text(
                    description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Cena: $price PLN',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),

                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 10),
                  const Text(
                    'Dane sprzedającego',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (ownerLogin.isNotEmpty)
                    Text('👤 Login: $ownerLogin', style: const TextStyle(fontSize: 16)),
                  if (ownerCity.isNotEmpty)
                    Text('📍 Miejscowość: $ownerCity', style: const TextStyle(fontSize: 16)),
                  if (ownerPhone.isNotEmpty)
                    GestureDetector(
                      onTap: () => _callSeller(ownerPhone),
                      child: Text(
                        '📞 Zadzwoń: $ownerPhone',
                        style: const TextStyle(fontSize: 16, color: Colors.blue),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
