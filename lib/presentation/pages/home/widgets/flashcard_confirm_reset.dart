import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lacquer/features/flashcard/bloc/flashcard_bloc.dart';
import 'package:lacquer/features/flashcard/bloc/flashcard_event.dart';

class FlashcardConfirmReset extends StatefulWidget {
  final String id;
  final String title;
  final bool isDone;
  const FlashcardConfirmReset({
    super.key,
    required this.id,
    required this.title,
    required this.isDone,
  });

  @override
  State<FlashcardConfirmReset> createState() => _FlashcardConfirmResetState();
}

class _FlashcardConfirmResetState extends State<FlashcardConfirmReset> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Reset statistics',
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
              TextSpan(
                text: 'Are you sure want to reset statistics of topic "',
              ),
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
            if (widget.isDone == true) {
              context.read<FlashcardBloc>().add(
                FinishDeckRequested(deckId: widget.id),
              );
            }
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
