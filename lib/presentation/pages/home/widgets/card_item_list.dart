import 'package:flutter/material.dart';
import 'package:lacquer/features/flashcard/dtos/card_dto.dart';
import 'card_item.dart';

class CardItemList extends StatelessWidget {
  final List<CardDto> cards;

  const CardItemList({super.key, required this.cards});

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) {
      return const Center(child: Text('No cards available.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12.0),
      itemCount: cards.length,
      separatorBuilder: (context, index) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        return CardItem(card: cards[index]);
      },
    );
  }
}
