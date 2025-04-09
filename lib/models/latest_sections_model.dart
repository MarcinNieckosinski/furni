import 'package:flutter/material.dart';
import 'package:furniapp/models/latest_model.dart';

class LatestSectionsModel {
  Color color;
  String name;
  List<LatestModel> latest;

  LatestSectionsModel({
    required this.color,
    required this.name,
    required this.latest,
  });

  static List<LatestSectionsModel> getLatestSections() {
    List<LatestSectionsModel> latestSections = [];

    latestSections.add(LatestSectionsModel(
      color: const Color(0xFF00FA8C),
      name: 'do salonu',
      latest: LatestModel.getLatest(),
    ));

    latestSections.add(LatestSectionsModel(
      color: const Color(0xFFFAAA00),
      name: 'do sypialni',
      latest: LatestModel.getLatest(),
    ));

    latestSections.add(LatestSectionsModel(
      color: const Color(0xFFB2BA55),
      name: 'kuchenne i jadalniane',
      latest: LatestModel.getLatest(),
    ));

    latestSections.add(LatestSectionsModel(
      color: const Color.fromARGB(255, 217, 228, 95),
      name: 'do łazienki',
      latest: LatestModel.getLatest(),
    ));

    latestSections.add(LatestSectionsModel(
      color: const Color(0xFF01DDFB),
      name: 'biurowe',
      latest: LatestModel.getLatest(),
    ));

    latestSections.add(LatestSectionsModel(
      color: const Color(0xFFFA6C00),
      name: 'dziecięce i młodzieżowe',
      latest: LatestModel.getLatest(),
    ));

    latestSections.add(LatestSectionsModel(
      color: const Color(0xFF3798A5),
      name: 'ogrodowe',
      latest: LatestModel.getLatest(),
    ));

    latestSections.add(LatestSectionsModel(
      color: const Color(0xFF3D7A5F),
      name: 'dekoracje i dodatki',
      latest: LatestModel.getLatest(),
    ));

    return latestSections;
  }
}
