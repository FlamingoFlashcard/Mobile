import 'package:flutter/material.dart';
import 'package:lacquer/config/theme.dart';

class FlashcardTagCreate extends StatefulWidget {
  const FlashcardTagCreate({super.key});

  @override
  State<FlashcardTagCreate> createState() => _FlashcardTagCreateState();
}

class _FlashcardTagCreateState extends State<FlashcardTagCreate> {
  final TextEditingController _titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text(
        'Create New Tag',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: CustomTheme.mainColor1,
        ),
        textAlign: TextAlign.center,
      ),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Enter tag title',
                ),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.black,
            textStyle: Theme.of(context).textTheme.labelLarge,
          ),
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: CustomTheme.primaryColor,
            textStyle: Theme.of(context).textTheme.labelLarge,
          ),
          child: const Text('Create'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
