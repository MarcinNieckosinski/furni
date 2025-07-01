import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class LatestModel {
  String name;
  String imagePath;
  String shortDescription;
  String price;
  String city;
  String date;
  String id;

  LatestModel({
    required this.name,
    required this.imagePath,
    required this.shortDescription,
    required this.price,
    required this.city,
    required this.date,
    required this.id,
  });
}

Future<List<LatestModel>> fetchLatest(String category) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('listings')
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .limit(5)
        .get();
    
    List<LatestModel> latest = [];

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final listingId = doc.id;
      final category = data['category'] ?? 'default';

      final storageRef = FirebaseStorage.instance.ref().child('listings/$category/$listingId/${listingId}_image_0.jpg');

      debugPrint('Fetching image from: ${storageRef.fullPath}');

      String imageUrl;
      try {
        imageUrl = await storageRef.getDownloadURL();
      } catch (e) {
        imageUrl = 'assets/temporary/tempor.jpg'; // Fallback image
      }

      latest.add(LatestModel(
        name: data['title'] ?? 'Brak nazwy',
        imagePath: imageUrl,
        shortDescription: data['shortDescription'] ?? 'No Description',
        price: data['price'] != null ? '${data['price']} PLN' : 'Price not available',
        city: data['city'] ?? 'Unknown City',
        date: (data['createdAt'] as Timestamp).toDate().toString().split(' ')[0], // Format date
        id: listingId,
      ));
    }

    return latest;
  }
