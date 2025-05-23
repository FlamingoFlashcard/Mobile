import 'package:flutter/material.dart';
import 'package:lacquer/features/flashcard/dtos/get_deck_dto.dart';
import 'package:lacquer/presentation/pages/home/widgets/flashcard_topic.dart';

class FlashcardTag extends StatelessWidget {
  final String title;
  final List<GetDeckDto> decks;

  const FlashcardTag({super.key, required this.title, required this.decks});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.separated(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            scrollDirection: Axis.horizontal,
            separatorBuilder: (context, _) => const SizedBox(width: 12),
            itemCount: decks.length,
            itemBuilder: (context, index) {
              return FlashcardTopic(
                id: decks[index].id,
                title: decks[index].title,
                cardCount: decks[index].cards?.length ?? 0,
                tags: decks[index].tags,
                imagePath:
                    decks[index].img ?? 'assets/images/default_topic_image.JPG',
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
