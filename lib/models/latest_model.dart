class LatestModel {
  String name;
  String imagePath;
  String shortDescription;
  String price;
  String city;
  String date;

  LatestModel({
    required this.name,
    required this.imagePath,
    required this.shortDescription,
    required this.price,
    required this.city,
    required this.date,
  });

  static List<LatestModel> getLatest() {
    List<LatestModel> latestModels = [
    LatestModel(
      name: 'Meble testowe',
      imagePath: 'assets/temporary/tempor.jpg',
      shortDescription: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
      price: '6000 PLN',
      city: 'New York',
      date: '2023-10-01',
    ),
    LatestModel(
      name: 'Inne meble testowe',
      imagePath: 'assets/temporary/tempor.jpg',
      shortDescription: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
      price: '350 PLN',
      city: 'Los Angeles',
      date: '2023-10-02',
    ),
    LatestModel(
      name: 'Ostatnie meble',
      imagePath: 'assets/temporary/tempor.jpg',
      shortDescription: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
      price: '22 PLN',
      city: 'Chicago',
      date: '2023-10-03',
    ),
    LatestModel(
      name: 'jeszcze jedne meble',
      imagePath: 'assets/temporary/tempor.jpg',
      shortDescription: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
      price: '220000 PLN',
      city: 'Żółć',
      date: '2025-11-03',
    ),
    LatestModel(
      name: 'Ostatnio ostatnie meble',
      imagePath: 'assets/temporary/tempor.jpg',
      shortDescription: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
      price: '11111 PLN',
      city: 'Wręczyca',
      date: '2023-10-03',
    ),
  ];

    return latestModels;
  }
}
