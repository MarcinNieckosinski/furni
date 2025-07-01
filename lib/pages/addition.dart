import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:furniapp/models/category_model.dart';
import 'package:furniapp/pages/home.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class AdditionPage extends StatefulWidget {
  const AdditionPage({super.key});

  @override
  State<AdditionPage> createState() => _AdditionPageState();
}

class _AdditionPageState extends State<AdditionPage> {
  bool _isUploading = false;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();

  List<File?> chosenImages = List.generate(8, (_) => null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Text(
                      'Dodaj ogłoszenie',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    furnitureTitle(),
                    const SizedBox(height: 20),
                    categoriesDropdown(),
                    const SizedBox(height: 20),
                    furnitureDescription(),
                    const SizedBox(height: 20),
                    furniturePrice(),
                    const SizedBox(height: 20),
                    yourPhotosText(),
                    const SizedBox(height: 20),
                    yourPhotos(),
                    const SizedBox(height: 20),
                    addFurnitureButton(),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
          if (_isUploading)
            Container(
              color: Colors.black.withValues(alpha: .5),
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  DropdownMenu categoriesDropdown() {
    return DropdownMenu<CategoryModel>(
      initialSelection: CategoryModel.getCategories()[0],
      dropdownMenuEntries:
          CategoryModel.getCategories()
              .map(
                (category) =>
                    DropdownMenuEntry(label: category.name, value: category),
              )
              .toList(),
      onSelected: (value) {
        debugPrint(value.toString());
      },
      width: 320,
      hintText: 'Wybierz kategorię',
      controller: _categoryController,
    );
  }

  OutlinedButton addFurnitureButton() {
    return OutlinedButton(
      onPressed: () {
        _addListing(
          FirebaseAuth.instance.currentUser!.uid,
          _titleController.text,
          _descriptionController.text,
          _priceController.text,
          _categoryController.text,
        );
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: BorderSide(color: Colors.black.withValues(alpha: 0.3), width: 1),
        fixedSize: Size(320, 70),
      ),
      child: Text('Dodaj ogłoszenie', style: TextStyle(fontSize: 20)),
    );
  }

  SizedBox furniturePrice() {
    return SizedBox(
      width: 320,
      child: TextField(
        controller: _priceController,
        decoration: InputDecoration(
          labelText: 'Cena',
          border: OutlineInputBorder(),
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
        ],
        keyboardType: TextInputType.number,
      ),
    );
  }

  SizedBox furnitureTitle() {
    return SizedBox(
      width: 320,
      child: TextField(
        controller: _titleController,
        decoration: InputDecoration(
          labelText: 'Tytuł ogłoszenia (max. 30 znaków)',
          border: OutlineInputBorder(),
        ),
        inputFormatters: [LengthLimitingTextInputFormatter(30)],
      ),
    );
  }

  SizedBox furnitureDescription() {
    return SizedBox(
      width: 320,
      child: TextField(
        controller: _descriptionController,
        decoration: InputDecoration(
          labelText: 'Opis ogłoszenia \n\n(max. 3000 znaków)',
          border: OutlineInputBorder(),
        ),
        maxLines: 5,
        inputFormatters: [LengthLimitingTextInputFormatter(3000)],
      ),
    );
  }

  GridView yourPhotos() {
    return GridView.builder(
      itemCount: 8,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
      ),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final image = chosenImages[index];
        return GestureDetector(
          onTap:
              () async => {
                if (image == null)
                  {await requestStoragePermission(), _pickImageForIndex(index)}
                else
                  {
                    setState(() {
                      chosenImages[index] = null; // Remove the image
                    }),
                  },
              },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.3),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child:
                image != null
                    ? Image.file(image, fit: BoxFit.cover)
                    : Icon(
                      Icons.add_a_photo_rounded,
                      color: Colors.black.withValues(alpha: 0.5),
                      size: 50,
                    ),
          ),
        );
      },
    );
  }

  void _pickImageForIndex(int index) async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        chosenImages[index] = File(pickedFile.path);
      });
    } else {
      Fluttertoast.showToast(
        msg: 'Nie wybrano zdjęcia',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Text yourPhotosText() {
    return Text(
      'Twoje zdjęcia',
      style: TextStyle(
        color: Colors.black.withValues(alpha: 0.5),
        fontSize: 20,
      ),
    );
  }

  Future<void> _addListing(
    String userId,
    String title,
    String description,
    String price,
    String category,
  ) async {
    try {
      if (title.isEmpty ||
          description.isEmpty ||
          price.isEmpty ||
          category.isEmpty) {
        Fluttertoast.showToast(
          msg: 'Wszystkie pola są wymagane!',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return;
      }
      if (double.tryParse(price) == null) {
        Fluttertoast.showToast(
          msg: 'Cena musi być liczbą!',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return;
      }

      setState(() {
        _isUploading = true;
      });

      await FirebaseFirestore.instance
          .collection('listings')
          .add({
            'userId': userId,
            'title': title,
            'description': description,
            'price': price,
            'category': category,
            'createdAt': FieldValue.serverTimestamp(),
          })
          .then((DocumentReference docRef) async {
            final listingId = docRef.id;

            for (int i = 0; i < chosenImages.length; i++) {
              if (chosenImages[i] != null) {
                final imageFile = chosenImages[i]!;
                final fileName = '${listingId}_image_$i.jpg';
                debugPrint(fileName);
                final storageRef = FirebaseStorage.instance.ref().child(
                  'listings/$category/$listingId/$fileName',
                );
                await storageRef.putFile(imageFile);
                debugPrint('Image uploaded: $fileName');
                final imageUrl = await storageRef.getDownloadURL();
                await docRef.collection('images').add({'url': imageUrl});
              }
            }
          });

      setState(() {
        _isUploading = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
      Fluttertoast.showToast(
        msg: 'Ogłoszenie dodane pomyślnie!',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      debugPrint('Listing added successfully');
    } catch (e) {
      debugPrint('Error adding listing: $e');
    }
  }

  Future<void> requestStoragePermission() async {
    final status =
        await Permission.photos
            .request(); // lub Permission.storage dla starszych wersji

    if (status.isGranted) {
      print('✅ Uprawnienie przyznane');
    } else if (status.isDenied) {
      print('❌ Uprawnienie odrzucone');
    } else if (status.isPermanentlyDenied) {
      openAppSettings(); // otwiera ustawienia aplikacji
    }
  }
}
