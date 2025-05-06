import 'package:flutter/widgets.dart';

class HomeItemModel {
  final String imagePath;
  final String title;
  final Color backgroundColor;

  HomeItemModel({
    required this.imagePath,
    required this.title,
    required this.backgroundColor,
  });
}

final List<HomeItemModel> homeItems = [
  HomeItemModel(
    imagePath: "assets/images/flashcardLogo.png",
    title: "Flashcard",
    backgroundColor: Color(0xFF4285F4),
  ),
  HomeItemModel(
    imagePath: "assets/images/translatorLogo.png",
    title: "Translator",
    backgroundColor: Color(0xFF34A853),
  ),
  HomeItemModel(
    imagePath: "assets/images/dictionaryLogo.png",
    title: "Dictionary",
    backgroundColor: Color(0xFFFBBC05),
  ),
  HomeItemModel(
    imagePath: "assets/images/flashcardLogo.png",
    title: "Quiz",
    backgroundColor: Color(0xFFEA4335),
  ),
];
