import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';

class FlipCardComp extends StatelessWidget {
  final String frontText;
  final String backText;

  const FlipCardComp({
    super.key,
    required this.frontText,
    required this.backText,
  });

  @override
  Widget build(BuildContext context) {
    return FlipCard(
      fill: Fill.fillBack,
      direction: FlipDirection.HORIZONTAL,
      side: CardSide.FRONT,
      front: SizedBox(
        height: 500,
        child: Card(
          color: const Color.fromARGB(255, 253, 245, 221),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 4,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                frontText,
                style: TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
      back: SizedBox(
        height: 500,
        child: Card(
          color: const Color.fromARGB(255, 253, 245, 221),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 4,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                backText,
                style: TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
