import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class LatestModel {
  final String name;
  final String imagePath;
  final String shortDescription;
  final String price;
  final String city;
  final String date;
  final String id;

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

  final latest = await Future.wait(querySnapshot.docs.map((doc) async {
    final data = doc.data();
    final listingId = doc.id;
    final itemCategory = data['category'] ?? 'default';

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('listings/$itemCategory/$listingId/${listingId}_image_0.jpg');

    debugPrint('Fetching image from: ${storageRef.fullPath}');

    String imageUrl;
    try {
      imageUrl = await storageRef.getDownloadURL();
    } catch (e) {
      imageUrl = 'assets/temporary/tempor.jpg'; // fallback na wypadek błędu
    }

    return LatestModel(
      name: data['title'] ?? 'Brak nazwy',
      imagePath: imageUrl,
      shortDescription: data['shortDescription'] ?? 'No Description',
      price: data['price'] != null ? '${data['price']} PLN' : 'Price not available',
      city: data['userCity'] ?? 'Unknown City',
      date: (data['createdAt'] as Timestamp)
          .toDate()
          .toIso8601String()
          .split('T')[0], // yyyy-MM-dd
      id: listingId,
    );
  }));

  return latest;
}
