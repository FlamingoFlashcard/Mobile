import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ReviseCardInstructionsDialog extends StatelessWidget {
  const ReviseCardInstructionsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.info_outline,
              size: 48,
              color: Colors.amber,
              semanticLabel: 'Instructions',
            ),
            const SizedBox(height: 16),
            const Text(
              'How to Revise Flashcards',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Column(
                  children: [
                    Icon(FontAwesomeIcons.leftLong),
                    const SizedBox(height: 8),
                    Text(
                      'Swipe Left to mark\n a card as known',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  children: [
                    Icon(FontAwesomeIcons.rightLong),
                    const SizedBox(height: 8),
                    Text(
                      'Swipe Right to mark\n a card as forgotten',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Semantics(
              button: true,
              label: 'Close instructions',
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text(
                  'Got it',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  backgroundColor: Colors.green,
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
