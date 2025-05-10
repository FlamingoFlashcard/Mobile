import 'package:flutter/material.dart';
import 'package:lacquer/config/theme.dart';

class HomeItem extends StatefulWidget {
  final String imagePath;
  final String title;
  final Color backgroundColor;
  final VoidCallback onTap;

  const HomeItem({
    super.key,
    required this.imagePath,
    required this.title,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  State<HomeItem> createState() => _HomeItemState();
}

class _HomeItemState extends State<HomeItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 180,
        height: 250,
        decoration: BoxDecoration(
          color:
              _isPressed
                  ? widget.backgroundColor.withAlpha(
                    (0.7 * 255).round().toInt(),
                  )
                  : widget.backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(widget.imagePath, width: 100, height: 100),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              decoration: BoxDecoration(
                color: CustomTheme.lightbeige,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromRGBO(0, 0, 0, 0.15),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
