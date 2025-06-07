import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lacquer/features/flashcard/dtos/get_deck_dto.dart';
import 'package:lacquer/presentation/pages/home/widgets/flashcard_tag_delete.dart';
import 'package:lacquer/presentation/pages/home/widgets/flashcard_tag_edit.dart';
import 'package:lacquer/presentation/pages/home/widgets/flashcard_topic.dart';

class FlashcardTag extends StatelessWidget {
  final String tagId;
  final String title;
  final List<GetDeckDto> decks;

  const FlashcardTag({
    super.key,
    required this.tagId,
    required this.title,
    required this.decks,
  });

  void _showOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 20),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 20,
                          color: DefaultTextStyle.of(context).style.color,
                        ),
                        children: <TextSpan>[
                          TextSpan(text: 'Tag Name: '),
                          TextSpan(
                            text: title,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "${decks.length} decks",
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(thickness: 1, indent: 2),
                ListTile(
                  leading: const Icon(
                    FontAwesomeIcons.pen,
                    color: Colors.black,
                    size: 16,
                  ),
                  title: const Text('Edit Tag'),
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder:
                          (context) =>
                              FlashcardTagEdit(tagId: tagId, title: title),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    FontAwesomeIcons.trash,
                    color: Colors.black,
                    size: 16,
                  ),
                  title: const Text('Delete Tag'),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) =>
                              FlashcardTagDelete(tagId: tagId, title: title),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                onPressed: () => _showOptionsBottomSheet(context),
                icon: const Icon(
                  FontAwesomeIcons.ellipsis,
                  color: Colors.black,
                ),
              ),
            ],
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
                imagePath: decks[index].img ?? 'assets/images/lacquerBlack.png',
                isDone: decks[index].isDone ?? false,
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
