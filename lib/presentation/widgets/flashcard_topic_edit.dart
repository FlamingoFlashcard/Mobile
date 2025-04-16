import 'package:flutter/material.dart';

class FlashcardTopicEdit extends StatefulWidget {
  const FlashcardTopicEdit({super.key});

  @override
  State<FlashcardTopicEdit> createState() => _FlashcardTopicEditState();
}

class _FlashcardTopicEditState extends State<FlashcardTopicEdit> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Edit topic title',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: 300,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: TextFormField(
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Enter new title',
            ),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            textStyle: Theme.of(context).textTheme.labelLarge,
          ),
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          style: TextButton.styleFrom(
            textStyle: Theme.of(context).textTheme.labelLarge,
          ),
          child: const Text('OK'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
