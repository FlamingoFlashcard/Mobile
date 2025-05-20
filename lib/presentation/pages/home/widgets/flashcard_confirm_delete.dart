import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lacquer/features/flashcard/bloc/flashcard_bloc.dart';
import 'package:lacquer/features/flashcard/bloc/flashcard_event.dart';

class FlashcardConfirmDelete extends StatefulWidget {
  final String id;
  final String title;
  const FlashcardConfirmDelete({
    super.key,
    required this.id,
    required this.title,
  });

  @override
  State<FlashcardConfirmDelete> createState() => _FlashcardConfirmDeleteState();
}

class _FlashcardConfirmDeleteState extends State<FlashcardConfirmDelete> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Delete topic',
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
              TextSpan(text: 'Are you sure want to delete topic "'),
              TextSpan(
                text: widget.title,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: '"?'),
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
            context.read<FlashcardBloc>().add(DeleteDeckRequested(widget.id));
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
