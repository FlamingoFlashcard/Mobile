import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:lacquer/config/router.dart';
import 'package:lacquer/config/theme.dart';
import 'package:lacquer/features/flashcard/bloc/flashcard_bloc.dart';
import 'package:lacquer/features/flashcard/bloc/flashcard_event.dart';
import 'package:lacquer/features/flashcard/bloc/flashcard_state.dart';
import 'package:lacquer/presentation/pages/home/widgets/learning_card_list.dart';

class LearningFlashcardPage extends StatefulWidget {
  final String deckId;

  const LearningFlashcardPage({super.key, required this.deckId});

  @override
  State<LearningFlashcardPage> createState() => _LearningFlashcardPageState();
}

class _LearningFlashcardPageState extends State<LearningFlashcardPage> {
  @override
  void initState() {
    super.initState();
    context.read<FlashcardBloc>().add(LoadDeckByIdRequested(widget.deckId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.lightbeige,
      body: BlocBuilder<FlashcardBloc, FlashcardState>(
        builder: (context, state) {
          if (state.status == FlashcardStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.status == FlashcardStatus.failure) {
            return Center(
              child: Text('Error: ${state.errorMessage ?? 'Unknown error'}'),
            );
          } else if (state.status == FlashcardStatus.success &&
              state.selectedDeck != null) {
            final deck = state.selectedDeck!;
            return Stack(
              children: [
                _buildAppBar(context, deck.title),
                Column(
                  children: [
                    Expanded(child: LearningCardList(cards: deck.cards ?? [])),
                    const SizedBox(height: 20),
                    if (deck.cards == null || deck.cards!.isEmpty)
                      const Text('No cards available in this deck'),
                  ],
                ),
              ],
            );
          }
          return const Center(child: Text('No deck data available'));
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, String? title) {
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
                    title ?? '',
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
    );
  }
}
