import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Padding additionField() {
  return Padding(
    padding: const EdgeInsets.all(10),
    child: Column(
      children: [
        Text('Dodaj ogłoszenie',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            )),
        const SizedBox(height: 20),
        furnitureTitle(),
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
        addFurnitureButton()
      ],
    ),
  );
}

OutlinedButton addFurnitureButton() {
  return OutlinedButton(
        onPressed: () {},
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
