import 'package:flutter/material.dart';
import 'package:lacquer/features/flashcard/dtos/card_dto.dart';
import 'card_item.dart';

class CardItemList extends StatelessWidget {
  final List<CardDto> cards;
  final Set<String> selectedCardIds;
  final bool isMultiSelectMode;
  final void Function(CardDto card) onCardTap;
  final void Function(CardDto card) onCardLongPress;

  const CardItemList({
    super.key,
    required this.cards,
    required this.selectedCardIds,
    required this.isMultiSelectMode,
    required this.onCardTap,
    required this.onCardLongPress,
  });

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) {
      return const Center(child: Text('No cards available.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12.0),
      itemCount: cards.length,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final card = cards[index];
        final isSelected = selectedCardIds.contains(card.id);
        return GestureDetector(
          onTap: () => onCardTap(card),
          onLongPress: () => onCardLongPress(card),
          child: CardItem(
            card: card,
            isSelected: isSelected,
            isMultiSelectMode: isMultiSelectMode,
          ),
        );
      },
    );
  }
}
