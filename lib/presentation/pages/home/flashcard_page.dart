import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:lacquer/config/theme.dart';
import 'package:lacquer/presentation/utils/card_list.dart';
import 'package:lacquer/presentation/widgets/flashcard_category.dart';
import 'package:lacquer/presentation/widgets/flashcard_topic_create.dart';

class FlashcardPage extends StatelessWidget {
  const FlashcardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.lightbeige,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [_buildAppBar(context), _buildSearchBar()],
            ),
            const SizedBox(height: 80),
            FlashcardCategory(title: "Traditional Cuisine", cards: cuisine),
            FlashcardCategory(title: "Festivals", cards: cuisine),
            FlashcardCategory(title: "Landscape", cards: cuisine),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(8),
        bottomRight: Radius.circular(8),
      ),
      child: Container(
        height: 170,
        color: CustomTheme.mainColor1,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Row(
          children: [
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(FontAwesomeIcons.arrowLeft, color: Colors.white),
              onPressed: () {
                context.go('/');
              },
            ),
            Expanded(
              child: Center(
                child: Text(
                  'Flashcards',
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            IconButton(
              icon: const Icon(FontAwesomeIcons.plus, color: Colors.white),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const FlashcardTopicCreate(),
                );
              },
            ),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Positioned(
      left: 16,
      right: 16,
      top: 130,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CustomTheme.lightbeige,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color.fromRGBO(0, 0, 0, 0.1),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Search Flashcards",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  hintText: "Search topic you want",
                  hintStyle: TextStyle(color: Colors.black),
                  prefixIcon: const Icon(
                    FontAwesomeIcons.magnifyingGlass,
                    color: Colors.grey,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 252, 246, 227),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
