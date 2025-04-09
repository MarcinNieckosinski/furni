import 'package:flutter/material.dart';
import 'package:furniapp/models/latest_sections_model.dart';

Column latestSection(LatestSectionsModel latestSection) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Text(
          latestSection.name,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      SizedBox(height: 15),
      SizedBox(
        height: 240,
        child: ListView.separated(
          itemCount: latestSection.latest.length,
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.only(left: 20, right: 20),
          separatorBuilder: (context, index) {
            return SizedBox(width: 15);
          },
          itemBuilder: (context, index) {
            return Container(
              width: 200,
              decoration: BoxDecoration(
                color: latestSection.color.withValues(alpha: .5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0, right: 6.0),
                    child: Image.asset(latestSection.latest[index].imagePath),
                  ),
                  Center(
                    child: Text(
                      latestSection.latest[index].name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: Text(
                      latestSection.latest[index].price,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: Text(
                      '${latestSection.latest[index].city} | ${latestSection.latest[index].date}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              )
            );
          },
        ),
      ),
      SizedBox(height: 40),
    ],
  );
}
