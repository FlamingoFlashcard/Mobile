import 'package:flutter/widgets.dart';

class HomeItemModel {
  final String imagePath;
  final String title;
  final Color backgroundColor;
  final String? route;

  HomeItemModel({
    required this.imagePath,
    required this.title,
    required this.backgroundColor,
    this.route,
  });
}

final List<HomeItemModel> homeItems = [
  HomeItemModel(
    imagePath: "assets/images/flashcardLogo.png",
    title: "Flashcard",
    backgroundColor: Color(0xFF4285F4),
    route: '/flashcards',
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
    route: '/dictionary',
  ),
  HomeItemModel(
    imagePath: "assets/images/flashcardLogo.png",
    title: "Quiz",
    backgroundColor: Color(0xFFEA4335),
  ),
];
