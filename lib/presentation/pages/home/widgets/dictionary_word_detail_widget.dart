import 'package:flutter/material.dart';
import 'package:lacquer/features/dictionary/dtos/search_result_dto.dart';

class DictionaryWordWidget extends StatefulWidget {
  final Vocabulary word;
  final bool isFavorite;
  final Function(Vocabulary word, bool isFavorite) onFavoriteToggle;
  final VoidCallback? onBack; // <-- Added

  const DictionaryWordWidget({
    super.key,
    required this.word,
    this.isFavorite = false,
    required this.onFavoriteToggle,
    this.onBack, // <-- Added
  });

  @override
  State<DictionaryWordWidget> createState() => _DictionaryWordWidgetState();
}

class _DictionaryWordWidgetState extends State<DictionaryWordWidget>
    with SingleTickerProviderStateMixin {
  late bool _isFavorite;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    // Trigger animation
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    // Call the callback function
    widget.onFavoriteToggle(widget.word, _isFavorite);

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavorite
              ? '${widget.word.word} added to favorites!'
              : '${widget.word.word} removed from favorites!',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _isFavorite ? Colors.green : Colors.grey[600],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with word, difficulty, favorite button, and back button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getDifficultyColor(widget.word.difficulty).withOpacity(0.8),
                  _getDifficultyColor(widget.word.difficulty).withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button
                    if (widget.onBack != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: GestureDetector(
                          onTap: widget.onBack,
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    Expanded(
                      child: Text(
                        widget.word.word,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.word.difficulty.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Favorite button
                        AnimatedBuilder(
                          animation: _scaleAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _scaleAnimation.value,
                              child: GestureDetector(
                                onTap: _toggleFavorite,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                if (widget.word.pronunciation.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.volume_up,
                        color: Colors.white70,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.word.pronunciation,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Images section
                if (widget.word.img.isNotEmpty) ...[
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.word.img.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(right: 12),
                          width: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[100],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              widget.word.img[index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey,
                                    size: 40,
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Word types and definitions
                if (widget.word.wordTypes.isNotEmpty) ...[
                  const Text(
                    'Definitions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...widget.word.wordTypes.map((wordType) => _buildWordTypeCard(wordType)),
                ],

                // Examples section
                if (widget.word.examples.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Examples',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...widget.word.examples.map((example) => _buildExampleCard(example)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordTypeCard(WordType wordType) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              wordType.type,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.blue,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...wordType.definitions.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${entry.key + 1}. ',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),

          // Examples for this word type
          if (wordType.examples.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Examples:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            ...wordType.examples.map((example) => _buildInlineExample(example)),
          ],
        ],
      ),
    );
  }

  Widget _buildExampleCard(Example example) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'EN',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  example.english,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'VI',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  example.vietnamese,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInlineExample(Example example) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ${example.english}',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
              height: 1.3,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              example.vietnamese,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black38,
                fontStyle: FontStyle.italic,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
      case 'beginner':
        return Colors.green;
      case 'medium':
      case 'intermediate':
        return Colors.orange;
      case 'hard':
      case 'advanced':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}