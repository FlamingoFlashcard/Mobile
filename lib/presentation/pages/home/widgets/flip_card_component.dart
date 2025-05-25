import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';

class FlipCardComp extends StatelessWidget {
  final String frontText;
  final String backText;
  final String imagePath;
  final String pronunciation;

  const FlipCardComp({
    super.key,
    required this.frontText,
    required this.backText,
    required this.imagePath,
    required this.pronunciation,
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 4,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    imagePath,
                    width: 270,
                    height: 270,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 50),
                  Text(
                    frontText,
                    style: TextStyle(fontSize: 50),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      back: SizedBox(
        height: 500,
        child: Card(
          color: const Color.fromARGB(255, 253, 245, 221),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 4,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    backText,
                    style: TextStyle(fontSize: 50),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    pronunciation,
                    style: TextStyle(
                      fontSize: 40,
                      color: const Color.fromARGB(133, 0, 0, 0),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
