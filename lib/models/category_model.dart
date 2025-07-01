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
    return [
      CategoryModel(
        name: 'do salonu',
        iconPath: 'assets/icons/living-room.svg',
        boxColor: const Color(0xFF00FA8C),
      ),
      CategoryModel(
        name: 'do sypialni',
        iconPath: 'assets/icons/bedroom.svg',
        boxColor: const Color(0xFFFAAA00),
      ),
      CategoryModel(
        name: 'kuchenne i jadalniane',
        iconPath: 'assets/icons/kitchen.svg',
        boxColor: const Color(0xFFB2BA55),
      ),
      CategoryModel(
        name: 'do łazienki',
        iconPath: 'assets/icons/bathroom.svg',
        boxColor: const Color.fromARGB(255, 217, 228, 95),
      ),
      CategoryModel(
        name: 'biurowe',
        iconPath: 'assets/icons/office.svg',
        boxColor: const Color(0xFF01DDFB),
      ),
      CategoryModel(
        name: 'dziecięce i młodzieżowe',
        iconPath: 'assets/icons/kid.svg',
        boxColor: const Color(0xFFFA6C00),
      ),
      CategoryModel(
        name: 'ogrodowe',
        iconPath: 'assets/icons/garden.svg',
        boxColor: const Color(0xFF3798A5),
      ),
      CategoryModel(
        name: 'dekoracje i dodatki',
        iconPath: 'assets/icons/pillow.svg',
        boxColor: const Color(0xFF3D7A5F),
      ),
    ];
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryModel &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          iconPath == other.iconPath &&
          boxColor == other.boxColor;

  @override
  int get hashCode => name.hashCode ^ iconPath.hashCode ^ boxColor.hashCode;
}
