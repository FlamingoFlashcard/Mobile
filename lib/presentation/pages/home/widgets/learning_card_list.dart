import 'package:flutter/material.dart';
import 'package:lacquer/features/flashcard/dtos/card_dto.dart';
import 'package:lacquer/presentation/pages/home/widgets/learning_card.dart';

class LearningCardList extends StatefulWidget {
  final List<CardDto> cards;

  const LearningCardList({super.key, required this.cards});

  @override
  State<LearningCardList> createState() => _LearningCardListState();
}

class _LearningCardListState extends State<LearningCardList> {
  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      itemCount: widget.cards.length,
      itemBuilder: (context, index) {
        return LearningCard(card: widget.cards[index]);
      },
    );
  }
}
