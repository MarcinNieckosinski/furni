import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:furniapp/models/category_model.dart';
import 'package:furniapp/pages/home.dart';

class AdditionPage extends StatefulWidget {
  const AdditionPage({super.key});

  @override
  State<AdditionPage> createState() => _AdditionPageState();
}

class _AdditionPageState extends State<AdditionPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  CategoryModel? _selectedCategory;
  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedImages = [];
  bool _isUploading = false;

  List<String> _generateKeywords(List<String> texts) {
  final allWords = <String>{};

  for (final text in texts) {
    final words = text.toLowerCase().split(RegExp(r'\s+'));
    allWords.addAll(words.where((w) => w.length > 2));
  }

  return allWords.toList();
}

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null && _selectedImages.length < 8) {
      setState(() {
        _selectedImages.add(File(picked.path));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maksymalna liczba zdjęć to 8')),
      );
    }
  }

  Future<void> _saveListing() async {
    if (!_formKey.currentState!.validate() || _selectedCategory == null) return;

    setState(() => _isUploading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Brak użytkownika');

      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final title = _titleController.text.trim();
      final description = _descController.text.trim();
      final city = userData['city'] ?? '';
      final category = _selectedCategory!.name;

      final keywords = _generateKeywords([title, description, city, category]);

      final listingRef = await FirebaseFirestore.instance
          .collection('listings')
          .add({
            'title': _titleController.text.trim(),
            'description': _descController.text.trim(),
            'price': _priceController.text.trim(),
            'category': _selectedCategory!.name,
            'userId': user.uid,
            'userLogin': userData['login'],
            'userPhone': userData['phone'],
            'userCity': userData['city'],
            'keywords': keywords,
            'createdAt': FieldValue.serverTimestamp(),
          });

      final listingId = listingRef.id;
      final storage = FirebaseStorage.instance;
      final imagesRef = listingRef.collection('images');

      for (int i = 0; i < _selectedImages.length; i++) {
        final imageFile = _selectedImages[i];
        final ref = storage.ref(
          'listings/${_selectedCategory!.name}/$listingId/${listingId}_image_$i.jpg',
        );
        await ref.putFile(imageFile);
        final url = await ref.getDownloadURL();

        await imagesRef.add({
          'url': url,
          'position': i,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Ogłoszenie dodane!')));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } catch (e) {
      debugPrint('Błąd przy dodawaniu ogłoszenia: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Błąd podczas dodawania ogłoszenia')),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(title: const Text('Dodaj ogłoszenie')),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Tytuł'),
                      validator:
                          (val) =>
                              val == null || val.trim().isEmpty
                                  ? 'Podaj tytuł'
                                  : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descController,
                      maxLines: 5,
                      decoration: const InputDecoration(labelText: 'Opis'),
                      validator:
                          (val) =>
                              val == null || val.trim().isEmpty
                                  ? 'Podaj opis'
                                  : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Cena'),
                      validator:
                          (val) =>
                              val == null || val.trim().isEmpty
                                  ? 'Podaj cenę'
                                  : null,
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<CategoryModel>(
                      value: _selectedCategory,
                      items:
                          CategoryModel.getCategories()
                              .map(
                                (cat) => DropdownMenuItem(
                                  value: cat,
                                  child: Text(cat.name),
                                ),
                              )
                              .toList(),
                      onChanged: (val) => setState(() => _selectedCategory = val),
                      decoration: const InputDecoration(labelText: 'Kategoria'),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Zdjęcia (max 8)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (int i = 0; i < _selectedImages.length; i++)
                          Stack(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  final picked = await _picker.pickImage(
                                    source: ImageSource.gallery,
                                  );
                                  if (picked != null) {
                                    setState(
                                      () =>
                                          _selectedImages[i] = File(picked.path),
                                    );
                                  }
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    _selectedImages[i],
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap:
                                      () => setState(
                                        () => _selectedImages.removeAt(i),
                                      ),
                                  child: const CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.black54,
                                    child: Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        if (_selectedImages.length < 8)
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.add_a_photo,
                                size: 32,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _saveListing,
                      child: const Text('Dodaj ogłoszenie'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isUploading)
            Positioned.fill(
              child: Container(
                color: Colors.black45,
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
