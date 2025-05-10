import 'package:flutter/material.dart';

class FlashcardConfirmDelete extends StatefulWidget {
  const FlashcardConfirmDelete({super.key});

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
        child: const Text(
          'Are you sure want to delete topic...?',
          style: TextStyle(fontSize: 16),
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
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
