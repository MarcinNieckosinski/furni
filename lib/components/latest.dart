import 'package:flutter/material.dart';
import 'package:furniapp/models/latest_sections_model.dart';

Widget latestSection(LatestSectionsModel latestSection) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Text(
          latestSection.name,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      const SizedBox(height: 15),
      SizedBox(
        height: 240,
        child: ListView.separated(
          itemCount: latestSection.latest.length,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          separatorBuilder: (_, __) => const SizedBox(width: 15),
          itemBuilder: (context, index) {
            final item = latestSection.latest[index];
            return Container(
              width: 200,
              decoration: BoxDecoration(
                color: latestSection.color.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🖼️ Zdjęcie pobrane z internetu lub lokalne fallback
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: item.imagePath.startsWith('http')
                          ? Image.network(
                              item.imagePath,
                              height: 100,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                            )
                          : Image.asset(item.imagePath),
                    ),
                  ),
                  Center(
                    child: Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: Text(
                      item.price,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: Text(
                      '${item.city} | ${item.date}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 40),
    ],
  );
}