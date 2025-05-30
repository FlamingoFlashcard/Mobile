class FlashcardTopicModel {
  final String title;
  final int cardCount;
  final String imagePath;

  const FlashcardTopicModel({
    required this.title,
    required this.cardCount,
    required this.imagePath,
  });
}

final List<FlashcardTopicModel> cuisine = [
  FlashcardTopicModel(
    title: "Luna New Year Cuisine",
    cardCount: 10,
    imagePath: "assets/images/mamCom.jpg",
  ),

  FlashcardTopicModel(
    title: "Breakfast",
    cardCount: 12,
    imagePath: "assets/images/mamCom.jpg",
  ),

  FlashcardTopicModel(
    title: "Cakes and Pastries",
    cardCount: 15,
    imagePath: "assets/images/mamCom.jpg",
  ),
];

final List<FlashcardTopicModel> animal = [
  FlashcardTopicModel(
    title: "Luna New Year Cuisine",
    cardCount: 10,
    imagePath: "assets/images/mamCom.jpg",
  ),

  FlashcardTopicModel(
    title: "Street foods",
    cardCount: 12,
    imagePath: "assets/images/mamCom.jpg",
  ),
];
