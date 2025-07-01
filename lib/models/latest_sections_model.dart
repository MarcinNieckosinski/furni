import 'package:flutter/material.dart';
import 'package:furniapp/models/latest_model.dart';

class LatestSectionsModel {
  final Color color;
  final String name;
  final List<LatestModel> latest;

  LatestSectionsModel({
    required this.color,
    required this.name,
    required this.latest,
  });

  static Future<List<LatestSectionsModel>> getLatestSections() async {
    List<String> categories = [
      'do salonu',
      'do sypialni',
      'kuchenne i jadalniane',
      'do łazienki',
      'biurowe',
      'dziecięce i młodzieżowe',
      'ogrodowe',
      'dekoracje i dodatki',
    ];
    List<LatestSectionsModel> latestSections = [];

    for (var category in categories) {
      final latestListings = await fetchLatest(category);
      final color = _getColorForCategory(category);
      latestSections.add(LatestSectionsModel(
        color: color,
        name: category,
        latest: latestListings,
      ));
    }

    return latestSections;
  }

  static Color _getColorForCategory(String category) {
    final map = {
      'do salonu': Color(0xFF00FA8C),
      'do sypialni': Color(0xFFFAAA00),
      'kuchenne i jadalniane': Color(0xFFB2BA55),
      'do łazienki': Color.fromARGB(255, 217, 228, 95),
      'biurowe': Color(0xFF01DDFB),
      'dziecięce i młodzieżowe': Color(0xFFFA6C00),
      'ogrodowe': Color(0xFF3798A5),
      'dekoracje i dodatki': Color(0xFF3D7A5F),
    };
    return map[category] ?? Colors.grey;
  }
}
