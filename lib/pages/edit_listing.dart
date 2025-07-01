import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:furniapp/models/category_model.dart';
import 'package:furniapp/pages/home.dart';
import 'package:image_picker/image_picker.dart';

class EditListingPage extends StatefulWidget {
  final DocumentSnapshot listingDoc;

  const EditListingPage({super.key, required this.listingDoc});

  @override
  State<EditListingPage> createState() => _EditListingPageState();
}

class _EditListingPageState extends State<EditListingPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  CategoryModel? _selectedCategory;

  List<String> existingImages = [];
  List<String> imagesToRemove = [];
  List<File> newImages = [];

  final ImagePicker _picker = ImagePicker();
  late final String listingId;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final data = widget.listingDoc.data() as Map<String, dynamic>;
    _titleController.text = data['title'] ?? '';
    _descController.text = data['description'] ?? '';
    _priceController.text = data['price'] ?? '';
    listingId = widget.listingDoc.id;

    _selectedCategory = CategoryModel.getCategories().firstWhere(
      (cat) => cat.name == data['category'],
      orElse: () => CategoryModel.getCategories().first,
    );

    _loadExistingImages(data['category'], listingId);
  }

  Future<void> _loadExistingImages(String category, String listingId) async {
    for (int i = 0; i < 8; i++) {
      final ref = FirebaseStorage.instance.ref(
        'listings/$category/$listingId/${listingId}_image_$i.jpg',
      );
      try {
        final url = await ref.getDownloadURL();
        setState(() => existingImages.add(url));
      } catch (_) {
        break;
      }
    }
  }

  Future<void> _pickNewImage() async {
    final total = existingImages.length + newImages.length;
    if (total >= 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maksymalna liczba zdjęć to 8')),
      );
      return;
    }

    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => newImages.add(File(picked.path)));
    }
  }

  Future<void> _replaceImageAt(int index, {required bool isExisting}) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        final file = File(picked.path);
        if (isExisting) {
          imagesToRemove.add(existingImages[index]);
          existingImages.removeAt(index);
          newImages.insert(index, file);
        } else {
          newImages[index] = file;
        }
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate() || _selectedCategory == null) return;

    setState(() => _isSaving = true);

    final category = _selectedCategory!.name;
    final docRef = FirebaseFirestore.instance
        .collection('listings')
        .doc(listingId);

    try {
      await docRef.update({
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'price': _priceController.text.trim(),
        'category': category,
      });

      final storage = FirebaseStorage.instance;

      for (final url in imagesToRemove) {
        try {
          final ref = storage.refFromURL(url);
          await ref.delete();
        } catch (_) {}
      }

      for (int i = 0; i < newImages.length; i++) {
        final image = newImages[i];
        final ref = storage.ref(
          'listings/$category/$listingId/${listingId}_image_${existingImages.length + i}.jpg',
        );
        await ref.putFile(image);
        final url = await ref.getDownloadURL();
        existingImages.add(url);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ogłoszenie zaktualizowane!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } catch (e) {
      debugPrint('Błąd przy zapisie: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Błąd podczas zapisu zmian')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(title: const Text('Edytuj ogłoszenie')),
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
                    onChanged:
                        (value) => setState(() => _selectedCategory = value),
                    decoration: const InputDecoration(labelText: 'Kategoria'),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Zdjęcia ogłoszenia',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (int i = 0; i < existingImages.length; i++)
                        Stack(
                          children: [
                            GestureDetector(
                              onTap: () => _replaceImageAt(i, isExisting: true),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  existingImages[i],
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
                                    () => setState(() {
                                      imagesToRemove.add(existingImages[i]);
                                      existingImages.removeAt(i);
                                    }),
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
                      for (int i = 0; i < newImages.length; i++)
                        GestureDetector(
                          onTap: () => _replaceImageAt(i, isExisting: false),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              newImages[i],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      GestureDetector(
                        onTap: () {
                          final total =
                              existingImages.length + newImages.length;
                          if (total < 8) {
                            _pickNewImage();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Maksymalna liczba zdjęć to 8'),
                              ),
                            );
                          }
                        },
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
                    onPressed: _saveChanges,
                    child: const Text('Zapisz zmiany'),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_isSaving)
          Positioned.fill(
            child: Container(
              color: Colors.black45,
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}
