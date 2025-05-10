import 'package:flutter/material.dart';
import 'package:lacquer/config/theme.dart';
import 'package:lacquer/presentation/pages/home/widgets/flashcard_options.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class FlashcardTopic extends StatefulWidget {
  final String title;
  final int cardCount;
  final String imagePath;

  const FlashcardTopic({
    super.key,
    required this.title,
    required this.cardCount,
    required this.imagePath,
  });

  @override
  FlashcardTopicState createState() => FlashcardTopicState();
}

class FlashcardTopicState extends State<FlashcardTopic> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => const FlashcardOptionDialog(),
        );
      },

      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Material(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 350,
            height: 200,
            decoration: BoxDecoration(
              color: CustomTheme.mainColor3,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color.fromRGBO(0, 0, 0, 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              "${widget.cardCount} cards",
                              style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          CircularPercentIndicator(
                            radius: 20.0,
                            lineWidth: 4.0,
                            percent: 0.8,
                            center: const Text(
                              "80%",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                              ),
                            ),
                            backgroundColor: Colors.grey.shade300,
                            progressColor: Colors.green,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Colors.transparent, Colors.white],
                        stops: [0.0, 0.3],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.dstIn,
                    child: Image.asset(
                      widget.imagePath,
                      width: 190,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
