import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lacquer/config/theme.dart';

class LearningFlashcardPage extends StatelessWidget {
  final String title;
  final List<String> cards;
  const LearningFlashcardPage({
    super.key,
    required this.title,
    required this.cards,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.lightbeige,
      body: Stack(
        children: [
          _buildAppBar(title),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            // children: [HorizontalLearningCardList(flashcardItems: cards)],
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(String title) {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: CustomTheme.cinnabar,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.only(top: 30),
      child: Row(
        children: [
          SizedBox(width: 10),
          IconButton(
            icon: Icon(FontAwesomeIcons.arrowLeft, color: Colors.white),
            onPressed: null,
          ),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 15),
          IconButton(
            icon: Icon(FontAwesomeIcons.plus, color: Colors.white),
            onPressed: null,
          ),
          SizedBox(width: 10),
        ],
      ),
    );
  }
}
