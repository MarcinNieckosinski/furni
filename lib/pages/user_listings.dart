import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:furniapp/pages/listing_details.dart';

class UserListingsPage extends StatelessWidget {
  const UserListingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Brak zalogowanego użytkownika')),
      );
    }

    final listingsRef = FirebaseFirestore.instance
        .collection('listings')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Twoje ogłoszenia'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: listingsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Błąd: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nie masz jeszcze ogłoszeń'));
          }

          final docs = snapshot.data!.docs;

          return ListView.separated(
            itemCount: docs.length,
            padding: const EdgeInsets.symmetric(vertical: 12),
            separatorBuilder: (_, __) => const Divider(height: 0),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              return ListTile(
                leading: const Icon(Icons.chair, size: 30, color: Colors.blue),
                title: Text(data['title'] ?? 'Bez tytułu'),
                subtitle: Text(data['category'] ?? ''),
                trailing: Text('${data['price']} zł'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ListingDetailsPage(listingDoc: docs[index]),
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
