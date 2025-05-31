import 'package:flutter/material.dart';
import 'package:lacquer/features/flashcard/dtos/card_dto.dart';
import 'package:lacquer/presentation/pages/home/widgets/learning_card.dart';

class LearningCardList extends StatefulWidget {
  final List<CardDto> cards;
  final Function(double)? onScrollProgress;

  const LearningCardList({
    super.key,
    required this.cards,
    this.onScrollProgress,
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
        return LearningCard(card: widget.cards[index]);
      },
    );
  }
}
