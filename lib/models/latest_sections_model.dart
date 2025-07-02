import 'package:flutter/material.dart';
import 'package:furniapp/models/latest_model.dart';

class LatestSectionsModel {
  final Color color;
  final String name;
  final List<LatestModel> latest;
  bool get hasListings => latest.isNotEmpty;

  LatestSectionsModel({
    required this.color,
    required this.name,
    required this.latest,
  });

  static Future<List<LatestSectionsModel>> getLatestSections() async {
    final categories = _getCategoryList();

    final latestSections = await Future.wait(categories.map((category) async {
      final listings = await fetchLatest(category);
      final color = _getColorForCategory(category);

      return LatestSectionsModel(
        color: color,
        name: category,
        latest: listings,
      );
    }));

    return latestSections.where((s) => s.hasListings).toList();
  }

  static List<String> _getCategoryList() => const [
        'do salonu',
        'do sypialni',
        'kuchenne i jadalniane',
        'do łazienki',
        'biurowe',
        'dziecięce i młodzieżowe',
        'ogrodowe',
        'dekoracje i dodatki',
      ];

  static Color _getColorForCategory(String category) {
    const colorMap = {
      'do salonu': Color(0xFF00FA8C),
      'do sypialni': Color(0xFFFAAA00),
      'kuchenne i jadalniane': Color(0xFFB2BA55),
      'do łazienki': Color.fromARGB(255, 217, 228, 95),
      'biurowe': Color(0xFF01DDFB),
      'dziecięce i młodzieżowe': Color(0xFFFA6C00),
      'ogrodowe': Color(0xFF3798A5),
      'dekoracje i dodatki': Color(0xFF3D7A5F),
    };
    return colorMap[category] ?? Colors.grey;
  }
}
