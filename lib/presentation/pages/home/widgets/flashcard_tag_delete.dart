import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lacquer/features/flashcard/bloc/flashcard_bloc.dart';
import 'package:lacquer/features/flashcard/bloc/flashcard_event.dart';

class FlashcardTagDelete extends StatefulWidget {
  final String tagId;
  final String title;
  const FlashcardTagDelete({
    super.key,
    required this.tagId,
    required this.title,
  });

  @override
  State<FlashcardTagDelete> createState() => _FlashcardTagDeleteState();
}

class _FlashcardTagDeleteState extends State<FlashcardTagDelete> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Delete tag',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: 300,
        child: RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 16,
              color: DefaultTextStyle.of(context).style.color,
            ),
            children: <TextSpan>[
              TextSpan(text: 'Are you sure want to delete tag "'),
              TextSpan(
                text: widget.title,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: '"?.\nThis will move all decks into '),
              TextSpan(
                text: '"Others"',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: ' tag.'),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            textStyle: Theme.of(context).textTheme.labelLarge,
          ),
          child: const Text('No'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          style: TextButton.styleFrom(
            textStyle: Theme.of(context).textTheme.labelLarge,
          ),
          child: const Text('Yes'),
          onPressed: () {
            context.read<FlashcardBloc>().add(DeleteTagRequested(widget.tagId));
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
