import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:lacquer/config/router.dart';
import 'package:go_router/go_router.dart';
import 'package:lacquer/config/router.dart';
import 'package:lacquer/config/theme.dart';

class LearningFlashcardPage extends StatefulWidget {
  final String deckId;

  const LearningFlashcardPage({super.key, required this.deckId});

  @override
  State<LearningFlashcardPage> createState() => _LearningFlashcardPageState();
}

class _LearningFlashcardPageState extends State<LearningFlashcardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.lightbeige,
      body: Stack(
        children: [
          _buildAppBar(context),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [Text('something')],
          ),
        ],
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
        height: 90,
        color: CustomTheme.mainColor1,
        padding: const EdgeInsets.only(top: 30),
        child: Center(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(
                  FontAwesomeIcons.arrowLeft,
                  color: Colors.white,
                ),
                onPressed: () {
                  context.go(RouteName.flashcards);
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
                onPressed: null,
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
