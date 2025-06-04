import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      final maxPages = widget.cards.length - 1;
      final progress = maxPages > 0 ? index / maxPages : 0.0;
      widget.onScrollProgress?.call(progress.clamp(0.0, 1.0));

      if (index == widget.cards.length - 1 &&
          widget.cards.isNotEmpty &&
          !widget.isDone) {
        context.read<FlashcardBloc>().add(
          FinishDeckRequested(deckId: widget.deckId),
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.cards.length,
      onPageChanged: _onPageChanged,
      itemBuilder: (context, index) {
        return LearningCard(
          card: widget.cards[index],
          speechRate: widget.speechRate,
          selectedAccent: widget.selectedAccent,
        );
      },
    );
  }
}
