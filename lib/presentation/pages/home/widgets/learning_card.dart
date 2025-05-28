import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lacquer/features/flashcard/dtos/card_dto.dart';

class LearningCard extends StatefulWidget {
  final CardDto card;
  const LearningCard({super.key, required this.card});
  @override
  State<LearningCard> createState() => _LearningCardState();
}

class _LearningCardState extends State<LearningCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  void _flipCard() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    _isFront = !_isFront;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 90),
        child: GestureDetector(
          onTap: _flipCard,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final angle = _controller.value * pi;
              final isUnder = angle > (pi / 2);

              return Transform(
                alignment: Alignment.center,
                transform:
                    Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(angle),
                child:
                    isUnder
                        ? Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(pi),
                          child: _buildBack(widget.card),
                        )
                        : _buildFront(widget.card),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFront(CardDto card) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: (size.width - 50),
      height: (size.height - 180),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        card.word ?? '',
        style: TextStyle(fontSize: 24, color: Colors.black),
      ),
    );
  }

  Widget _buildBack(CardDto card) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: (size.width - 50),
      height: (size.height - 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: const Text(
        'Back',
        style: TextStyle(fontSize: 24, color: Colors.black),
      ),
    );
  }
}
