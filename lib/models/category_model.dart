import 'package:flutter/material.dart';

class CategoryModel {
  String name;
  String iconPath;
  Color boxColor;

  CategoryModel({
    required this.name,
    required this.iconPath,
    required this.boxColor,
  });

  static List<CategoryModel> getCategories() {
    List<CategoryModel> categories = [];

    categories.add(CategoryModel(
      name: 'do salonu',
      iconPath: 'assets/icons/living-room.svg',
      boxColor: const Color(0xFF00FA8C),
    ));

    categories.add(CategoryModel(
      name: 'do sypialni',
      iconPath: 'assets/icons/bedroom.svg',
      boxColor: const Color(0xFFFAAA00),
    ));

    categories.add(CategoryModel(
      name: 'kuchenne i jadalniane',
      iconPath: 'assets/icons/kitchen.svg',
      boxColor: const Color(0xFFB2BA55),
    ));

    categories.add(CategoryModel(
      name: 'do łazienki',
      iconPath: 'assets/icons/bathroom.svg',
      boxColor: const Color.fromARGB(255, 217, 228, 95),
    ));

    categories.add(CategoryModel(
      name: 'biurowe',
      iconPath: 'assets/icons/office.svg',
      boxColor: const Color(0xFF01DDFB),
    ));

    categories.add(CategoryModel(
      name: 'dziecięce i młodzieżowe',
      iconPath: 'assets/icons/kid.svg',
      boxColor: const Color(0xFFFA6C00),
    ));

    categories.add(CategoryModel(
      name: 'ogrodowe',
      iconPath: 'assets/icons/garden.svg',
      boxColor: const Color(0xFF3798A5),
    ));

    categories.add(CategoryModel(
      name: 'dekoracje i dodatki',
      iconPath: 'assets/icons/pillow.svg',
      boxColor: const Color(0xFF3D7A5F),
    ));

    return categories;
  }
}