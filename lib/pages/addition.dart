import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:furniapp/models/category_model.dart';
import 'package:furniapp/pages/home.dart';

class AdditionPage extends StatefulWidget {
  const AdditionPage({super.key});

  @override
  State<AdditionPage> createState() => _AdditionPageState();
}

class _AdditionPageState extends State<AdditionPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Text(
                  'Dodaj ogłoszenie',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                addPhotosButton(),
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
    );
  }

  DropdownMenu categoriesDropdown() {
  return DropdownMenu<CategoryModel>(
    initialSelection: CategoryModel.getCategories()[0],
    dropdownMenuEntries: CategoryModel.getCategories()
        .map((category) => DropdownMenuEntry(
              label: category.name,
              value: category,
            ))
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
          _addListing('userId', _titleController.text, _descriptionController.text, _priceController.text, _categoryController.text);
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          side: BorderSide(color: Colors.black.withValues(alpha: 0.3), width: 1),
          fixedSize: Size(320, 70),
        ),
        child: Text(
          'Dodaj ogłoszenie',
          style: TextStyle(fontSize: 20)),
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

Column yourPhotos() {
  return Column(
    children: [
      Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.2), width: 1),
                ),
                child: Image(
                  image: AssetImage('assets/images/placeholder.jpg'),
                  height: 140,
                  width: 140,
                  opacity: const AlwaysStoppedAnimation(0.5),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.2), width: 1),
                ),
                child: Image(
                  image: AssetImage('assets/images/placeholder.jpg'),
                  height: 140,
                  width: 140,
                  opacity: const AlwaysStoppedAnimation(0.5),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.2), width: 1),
                ),
                child: Image(
                  image: AssetImage('assets/images/placeholder.jpg'),
                  height: 140,
                  width: 140,
                  opacity: const AlwaysStoppedAnimation(0.5),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.2), width: 1),
                ),
                child: Image(
                  image: AssetImage('assets/images/placeholder.jpg'),
                  height: 140,
                  width: 140,
                  opacity: const AlwaysStoppedAnimation(0.5),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.2), width: 1),
                ),
                child: Image(
                  image: AssetImage('assets/images/placeholder.jpg'),
                  height: 140,
                  width: 140,
                  opacity: const AlwaysStoppedAnimation(0.5),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.2), width: 1),
                ),
                child: Image(
                  image: AssetImage('assets/images/placeholder.jpg'),
                  height: 140,
                  width: 140,
                  opacity: const AlwaysStoppedAnimation(0.5),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.2), width: 1),
                ),
                child: Image(
                  image: AssetImage('assets/images/placeholder.jpg'),
                  height: 140,
                  width: 140,
                  opacity: const AlwaysStoppedAnimation(0.5),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.2), width: 1),
                ),
                child: Image(
                  image: AssetImage('assets/images/placeholder.jpg'),
                  height: 140,
                  width: 140,
                  opacity: const AlwaysStoppedAnimation(0.5),
                ),
              ),
            ],
          ),
    ],
  );
}

Text yourPhotosText() {
  return Text(
    'Twoje zdjęcia',
    style: TextStyle(color: Colors.black.withValues(alpha: 0.5), fontSize: 20),
  );
}

OutlinedButton addPhotosButton() {
  return OutlinedButton(
    onPressed: () {
      debugPrint('received');
    },
    style: OutlinedButton.styleFrom(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      side: BorderSide(color: Colors.black.withValues(alpha: 0.3), width: 1),
      fixedSize: Size(320, 200),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_a_photo_rounded,
          color: Colors.black.withValues(alpha: 0.5),
          size: 50,
        ),
        Text(
          'Dodaj zdjęcia',
          style: TextStyle(
            color: Colors.black.withValues(alpha: 0.5),
            fontSize: 20,
          ),
        ),
        Text(
          'maksymalnie 8 zdjęć',
          style: TextStyle(
            color: Colors.black.withValues(alpha: 0.4),
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}

Future<void> _addListing(String userId, String title, String description, String price, String category) async {
  try {
    if (title.isEmpty || description.isEmpty || price.isEmpty || category.isEmpty) {
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
    
    await FirebaseFirestore.instance.collection('listings').add({
      'userId': userId,
      'title': title,
      'description': description,
      'price': price,
      'category': category,
      'createdAt': FieldValue.serverTimestamp(),
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
}
