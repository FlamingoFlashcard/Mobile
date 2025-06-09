import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lacquer/config/router.dart';
import 'package:lacquer/features/flashcard/dtos/card_dto.dart';
import 'package:lacquer/presentation/pages/home/widgets/revise_card.dart';
import 'dart:math';

class ReviseCardList extends StatefulWidget {
  final String deckId;
  final List<CardDto> cards;
  final Function(double)? onScrollProgress;
  final double speechRate;
  final String selectedAccent;

  const ReviseCardList({
    super.key,
    required this.deckId,
    required this.cards,
    this.onScrollProgress,
    required this.speechRate,
    required this.selectedAccent,
  });

  @override
  State<ReviseCardList> createState() => _ReviseCardListState();
}

class _ReviseCardListState extends State<ReviseCardList>
    with SingleTickerProviderStateMixin {
  List<CardDto> _cardStack = [];
  Offset _dragOffset = Offset.zero;
  double _rotation = 0.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _cardStack = List.from(widget.cards);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
      _rotation = _dragOffset.dx / 300;
      _isDragging = true;
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    final threshold = 150;
    final draggedRight = _dragOffset.dx > threshold;
    final draggedLeft = _dragOffset.dx < -threshold;

    if (draggedRight || draggedLeft) {
      final card = _cardStack.last;
      setState(() {
        _cardStack.removeLast();
        _dragOffset = Offset.zero;
        _rotation = 0.0;
        _isDragging = false;
      });

      if (draggedRight) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() {
            _cardStack.insert(0, card);
          });
        });
      }

      final initialCount = widget.cards.length;
      final remainingCount = _cardStack.length;
      final progress =
          initialCount > 0
              ? (initialCount - remainingCount) / initialCount
              : 0.0;
      widget.onScrollProgress?.call(progress.clamp(0.0, 1.0));
    } else {
      setState(() {
        _dragOffset = Offset.zero;
        _rotation = 0.0;
        _isDragging = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cardStack.isEmpty) {
      return _buildCompletionCard(context, widget.deckId);
    }

    return Stack(
      children:
          List.generate(min(3, _cardStack.length), (index) {
            final cardIndex = _cardStack.length - 1 - index;
            final card = _cardStack[cardIndex];
            final isTopCard = index == 0;

            final offset = isTopCard ? _dragOffset : Offset.zero;
            final angle = isTopCard ? _rotation : 0.0;

            final transform = Transform.translate(
              offset: offset,
              child: Transform.rotate(
                angle: angle,
                child: ReviseCard(
                  card: card,
                  speechRate: widget.speechRate,
                  selectedAccent: widget.selectedAccent,
                ),
              ),
            );

            return Positioned(
              top: index * 10.0,
              left: 0,
              right: 0,
              child:
                  isTopCard
                      ? Stack(
                        children: [
                          if (_isDragging)
                            Positioned.fill(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      color:
                                          _dragOffset.dx < -50
                                              ? Colors.red
                                              : Colors.red,
                                      child: Center(
                                        child: Text(
                                          'Forget',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  Expanded(
                                    child: Container(
                                      color:
                                          _dragOffset.dx > 50
                                              ? Colors.green
                                              : Colors.green,
                                      child: Center(
                                        child: Text(
                                          'Remember',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          GestureDetector(
                            onPanUpdate: _handleDragUpdate,
                            onPanEnd: _handleDragEnd,
                            child: transform,
                          ),
                        ],
                      )
                      : Transform.scale(
                        scale: 1 - (index * 0.03),
                        child: transform,
                      ),
            );
          }).reversed.toList(),
    );
  }
}

Widget _buildCompletionCard(BuildContext context, String deckId) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
          const SizedBox(height: 24),
          const Text(
            '🎉 Congratulations!',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'You have completed the deck.',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              context.go(RouteName.flashcards);
            },
            icon: const Icon(Icons.check),
            label: const Text('Got it'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              backgroundColor: Colors.green,
              textStyle: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    ),
  );
}
