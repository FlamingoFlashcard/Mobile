import 'package:flutter/material.dart';
import 'package:lacquer/presentation/pages/home/widgets/flashcard_options.dart';

class FlashcardTopic extends StatefulWidget {
  final String id;
  final String title;
  final int cardCount;
  final List<String> tags;
  final String imagePath;
  final bool isDone;

  const FlashcardTopic({
    super.key,
    required this.id,
    required this.title,
    required this.cardCount,
    required this.tags,
    required this.imagePath,
    required this.isDone,
  });

  @override
  FlashcardTopicState createState() => FlashcardTopicState();
}

class FlashcardTopicState extends State<FlashcardTopic> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder:
              (context) => FlashcardOptionDialog(
                id: widget.id,
                title: widget.title,
                tags: widget.tags,
                imagePath: widget.imagePath,
              ),
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
            width: size.width - 30,
            height: 200,
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
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  widget.isDone ? Colors.green.shade100 : null,
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              widget.isDone ? Icons.check_circle : null,
                              color:
                                  widget.isDone ? Colors.green.shade700 : null,
                              size: 24,
                            ),
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
                    child: _buildImage(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (widget.imagePath.startsWith('http')) {
      return SizedBox(
        width: 190,
        height: 180,
        child: Image.network(
          widget.imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              'assets/images/lacquerBlack.png',
              fit: BoxFit.cover,
              width: 190,
              height: 180,
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
        ),
      );
    } else {
      return SizedBox(
        width: 190,
        height: 180,
        child: Image.asset(
          widget.imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading asset: $error');
            return Image.asset(
              'assets/images/lacquerBlack.png',
              fit: BoxFit.cover,
              width: 190,
              height: 180,
            );
          },
        ),
      );
    }
  }
}
