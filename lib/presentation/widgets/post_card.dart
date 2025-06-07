import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final VoidCallback onTap;
  final Function(String) onReaction;
  final VoidCallback? onOptions;

  const PostCard({
    super.key,
    required this.post,
    required this.onTap,
    required this.onReaction,
    this.onOptions,
  });

  @override
  Widget build(BuildContext context) {
    final owner = post['owner'] as Map<String, dynamic>?;
    final reactions = post['reactions'] as List<dynamic>? ?? [];
    final emojiCounts = post['emojiCounts'] as Map<String, dynamic>? ?? {};
    final totalReactions = post['totalReactions'] ?? reactions.length;
    final imageUrl = post['imageUrl'];
    final caption = post['caption'];
    final createdAt = post['createdAt'];
    final visibleTo = post['visibleTo'] as List<dynamic>? ?? [];

    // Get top 3 most used emojis
    final topEmojis = emojiCounts.entries
        .toList()
        ..sort((a, b) => b.value.compareTo(a.value));
    final displayEmojis = topEmojis.take(3).toList();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with owner info and options
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: owner?['avatar']?.isNotEmpty == true
                        ? NetworkImage(owner!['avatar'])
                        : const AssetImage('assets/images/boy.png')
                            as ImageProvider,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          owner?['username'] ?? 'Unknown',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            Text(
                              _formatDate(createdAt),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                            if (visibleTo.isNotEmpty) ...[
                              const SizedBox(width: 4),
                              Icon(
                                Icons.lock,
                                size: 10,
                                color: Colors.grey[600],
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (onOptions != null)
                    GestureDetector(
                      onTap: onOptions,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.more_horiz,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Image
            if (imageUrl != null)
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 150,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                              size: 32,
                            ),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 150,
                          color: Colors.grey[200],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

            // Caption and Reactions Footer
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Caption
                  if (caption != null) ...[
                    Text(
                      caption,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Reactions Summary
                  if (displayEmojis.isNotEmpty || totalReactions > 0)
                    Row(
                      children: [
                        // Top emojis
                        if (displayEmojis.isNotEmpty) ...[
                          ...displayEmojis.map((entry) => Padding(
                                padding: const EdgeInsets.only(right: 2),
                                child: Text(
                                  entry.key,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              )),
                          const SizedBox(width: 4),
                        ],

                        // Total reactions count
                        if (totalReactions > 0) ...[
                          Text(
                            totalReactions.toString(),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (totalReactions > 1) ...[
                            const SizedBox(width: 2),
                            const Text(
                              'reactions',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ] else ...[
                            const SizedBox(width: 2),
                            const Text(
                              'reaction',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ],

                        const Spacer(),

                        // Quick reaction button
                        GestureDetector(
                          onTap: () => onReaction('❤️'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('❤️', style: TextStyle(fontSize: 12)),
                                const SizedBox(width: 2),
                                Icon(
                                  Icons.add,
                                  size: 12,
                                  color: Colors.red[600],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays}d';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m';
      } else {
        return 'now';
      }
    } catch (e) {
      return '';
    }
  }
} 