import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lacquer/config/router.dart';
import 'package:lacquer/features/flashcard/bloc/flashcard_bloc.dart';
import 'package:lacquer/features/flashcard/bloc/flashcard_event.dart';
import 'package:lacquer/features/flashcard/dtos/card_dto.dart';
import 'package:lacquer/presentation/pages/home/widgets/learning_card.dart';

class LearningCardList extends StatefulWidget {
  final String deckId;
  final List<CardDto> cards;
  final Function(double)? onScrollProgress;
  final double speechRate;
  final String selectedAccent;
  final bool isDone;

  const LearningCardList({
    super.key,
    required this.deckId,
    required this.cards,
    this.onScrollProgress,
    required this.speechRate,
    required this.selectedAccent,
    required this.isDone,
  });

  @override
  State<LearningCardList> createState() => _LearningCardListState();
}

class _LearningCardListState extends State<LearningCardList> {
  late final PageController _pageController;
  int _highestPageReached = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  void _onPageChanged(int index) {
    if (index > _highestPageReached) {
      _highestPageReached = index;
      final maxPages = widget.cards.length;
      final progress = maxPages > 0 ? index / maxPages : 0.0;
      widget.onScrollProgress?.call(progress.clamp(0.0, 1.0));
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasCards = widget.cards.isNotEmpty;
    final totalPages = hasCards ? widget.cards.length + 1 : 0;

    return PageView.builder(
      controller: _pageController,
      itemCount: totalPages,
      onPageChanged: _onPageChanged,
      itemBuilder: (context, index) {
        if (index < widget.cards.length) {
          return LearningCard(
            card: widget.cards[index],
            speechRate: widget.speechRate,
            selectedAccent: widget.selectedAccent,
          );
        } else {
          return _buildCompletionCard(context, widget.deckId, widget.isDone);
        }
      },
    );
  }
}

Widget _buildCompletionCard(BuildContext context, String deckId, bool isDone) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
          const SizedBox(height: 24),
          const Text(
            '🎉 Congratulations!',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'You have completed the deck.',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              if (isDone != true) {
                context.read<FlashcardBloc>().add(
                  FinishDeckRequested(deckId: deckId),
                );
              }
              context.go(RouteName.flashcards);
            },
            icon: const Icon(Icons.check),
            label: const Text('Got it'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              backgroundColor: Colors.green,
              textStyle: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    ),
  );
}
