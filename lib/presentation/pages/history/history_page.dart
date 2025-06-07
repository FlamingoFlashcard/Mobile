import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../features/post/bloc/post_bloc.dart';
import '../../../features/post/bloc/post_event.dart';
import '../../../features/post/bloc/post_state.dart';
import '../../../features/friendship/bloc/friendship_bloc.dart';
import '../../../features/friendship/bloc/friendship_event.dart';
import '../../../features/friendship/bloc/friendship_state.dart';
import '../../../features/auth/data/constants.dart';
import '../../widgets/post_card.dart';
import '../../widgets/custom_loading_indicator.dart';
import '../../../services/post_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<dynamic> _posts = [];
  List<dynamic> _friends = [];
  List<DropdownItem> _dropdownItems = [];
  String? _currentUserId;
  String _selectedFilter = 'All';
  bool _isLoading = true; // Start with loading state

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    await _loadCurrentUser();
    _loadInitialData();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString(AuthDataConstants.userIdKey);
    });
  }

  void _loadInitialData() {
    // Load friends list for dropdown
    context.read<FriendshipBloc>().add(FriendshipEventGetFriends());
    // Load initial posts (all posts) - now currentUserId should be available
    _loadPosts();
  }

  void _buildDropdownItems() {
    final items = <DropdownItem>[
      DropdownItem(value: 'All', label: 'All Posts', icon: Icons.public),
      DropdownItem(value: 'Me', label: 'My Posts', icon: Icons.person),
    ];

    // Add friends to dropdown
    for (final friend in _friends) {
      final friendInfo = _getFriendDisplayInfo(friend);
      items.add(DropdownItem(
        value: friendInfo['id']!,
        label: friendInfo['username']!,
        icon: Icons.person_outline,
        avatarUrl: friendInfo['avatarUrl'],
      ));
    }

    setState(() {
      _dropdownItems = items;
    });
  }

  void _loadPosts() {
    if (_currentUserId == null) {
      print('⚠️ Cannot load posts: currentUserId is null');
      return;
    }

    print('📡 Loading posts for filter: $_selectedFilter');
    setState(() {
      _isLoading = true;
    });

    if (_selectedFilter == 'All') {
      context.read<PostBloc>().add(PostEventGetAllPosts());
    } else if (_selectedFilter == 'Me') {
      context.read<PostBloc>().add(
        PostEventGetUserPosts(userId: _currentUserId!),
      );
    } else {
      // Specific friend selected
      context.read<PostBloc>().add(
        PostEventGetUserPosts(userId: _selectedFilter),
      );
    }
  }

  String _getFriendUserId(dynamic friendship) {
    if (_currentUserId == null) return '';

    final requester = friendship['requester'];
    final recipient = friendship['recipient'];
    
    String requesterId;
    String recipientId;
    
    if (requester is Map) {
      requesterId = requester['_id'] ?? '';
    } else {
      requesterId = requester?.toString() ?? '';
    }
    
    if (recipient is Map) {
      recipientId = recipient['_id'] ?? '';
    } else {
      recipientId = recipient?.toString() ?? '';
    }

    return requesterId == _currentUserId ? recipientId : requesterId;
  }

  Map<String, String> _getFriendDisplayInfo(dynamic friendship) {
    if (_currentUserId == null) {
      return {
        'id': '',
        'username': 'Unknown',
        'email': '',
        'avatarUrl': '',
      };
    }

    final requester = friendship['requester'];
    final recipient = friendship['recipient'];

    Map<String, dynamic>? friendUser;
    
    if (requester is Map && requester['_id'] == _currentUserId) {
      friendUser = recipient is Map ? Map<String, dynamic>.from(recipient) : null;
    } else if (recipient is Map && recipient['_id'] == _currentUserId) {
      friendUser = requester is Map ? Map<String, dynamic>.from(requester) : null;
    } else if (requester is Map) {
      friendUser = Map<String, dynamic>.from(requester);
    } else if (recipient is Map) {
      friendUser = Map<String, dynamic>.from(recipient);
    }
    
    if (friendUser != null) {
      return {
        'id': friendUser['_id'] ?? '',
        'username': friendUser['username'] ?? 'Unknown',
        'email': friendUser['email'] ?? '',
        'avatarUrl': friendUser['avatar'] ?? '',
      };
    }
    
    final friendId = _getFriendUserId(friendship);
    return {
      'id': friendId,
      'username': 'User ${friendId.isNotEmpty && friendId.length >= 4 ? friendId.substring(friendId.length - 4) : friendId}',
      'email': '',
      'avatarUrl': '',
    };
  }

  Future<void> _downloadImage(String postId) async {
    try {
      // Use the post service to download the image
      final postService = PostService();
      await postService.downloadImage(postId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Download functionality triggered!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to download image'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showPostOptions(Map<String, dynamic> post) {
    final postId = post['_id'] ?? post['id'];
    final isPrivate = (post['visibleTo'] as List<dynamic>?)?.isNotEmpty ?? false;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Post Options',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildOptionTile(
              icon: Icons.public,
              title: 'Make Public',
              subtitle: 'Everyone can see this post',
              onTap: () {
                Navigator.pop(context);
                context.read<PostBloc>().add(
                  PostEventMakePostPublic(postId: postId),
                );
              },
              isSelected: !isPrivate,
            ),
            _buildOptionTile(
              icon: Icons.lock,
              title: 'Make Private',
              subtitle: 'Only selected friends can see',
              onTap: () {
                Navigator.pop(context);
                context.read<PostBloc>().add(
                  PostEventMakePostPrivate(postId: postId),
                );
              },
              isSelected: isPrivate,
            ),
            _buildOptionTile(
              icon: Icons.download,
              title: 'Download',
              subtitle: 'Save image to device',
              onTap: () {
                Navigator.pop(context);
                _downloadImage(postId);
              },
            ),
            _buildOptionTile(
              icon: Icons.delete,
              title: 'Delete',
              subtitle: 'Remove this post permanently',
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(postId);
              },
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isSelected = false,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive 
              ? Colors.red.withValues(alpha: 0.1)
              : isSelected 
                  ? Colors.blue.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isDestructive 
              ? Colors.red
              : isSelected 
                  ? Colors.blue
                  : Colors.grey[600],
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDestructive ? Colors.red : null,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: isSelected ? const Icon(Icons.check, color: Colors.blue) : null,
      onTap: onTap,
    );
  }

  void _showDeleteConfirmation(String postId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text(
          'Are you sure you want to delete this post? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<PostBloc>().add(
                PostEventDeletePost(postId: postId),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFCF6),
      body: MultiBlocListener(
        listeners: [
          BlocListener<PostBloc, PostState>(
            listener: (context, state) {
              if (state is PostGetAllPostsInProgress || 
                  state is PostGetUserPostsInProgress) {
                setState(() {
                  _isLoading = true;
                });
              } else {
                setState(() {
                  _isLoading = false;
                });
              }

              if (state is PostGetAllPostsSuccess) {
                setState(() {
                  _posts = state.posts;
                });
              } else if (state is PostGetUserPostsSuccess) {
                setState(() {
                  _posts = state.posts;
                });
              } else if (state is PostGetAllPostsFailure ||
                         state is PostGetUserPostsFailure) {
                final message = state is PostGetAllPostsFailure 
                    ? state.message 
                    : (state as PostGetUserPostsFailure).message;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to load posts: $message'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (state is PostAddReactionSuccess ||
                         state is PostUpdateReactionSuccess ||
                         state is PostRemoveReactionSuccess ||
                         state is PostMakePostPrivateSuccess ||
                         state is PostMakePostPublicSuccess) {
                // Refresh posts to show updates
                _loadPosts();
              } else if (state is PostDeletePostSuccess) {
                _loadPosts();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Post deleted successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
          BlocListener<FriendshipBloc, FriendshipState>(
            listener: (context, state) {
              if (state is FriendshipGetFriendsSuccess) {
                setState(() {
                  _friends = state.friends;
                });
                _buildDropdownItems();
                
                // Ensure posts are loaded if user ID is available but posts weren't loaded yet
                if (_currentUserId != null && _posts.isEmpty && !_isLoading) {
                  _loadPosts();
                }
              }
            },
          ),
        ],
        child: SafeArea(
          child: Column(
            children: [
              // Header with dropdown
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'History',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Filter Dropdown
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedFilter,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    items: _dropdownItems.map((item) {
                      return DropdownMenuItem<String>(
                        value: item.value,
                        child: Row(
                          children: [
                            if (item.avatarUrl?.isNotEmpty == true)
                              CircleAvatar(
                                radius: 12,
                                backgroundImage: NetworkImage(item.avatarUrl!),
                              )
                            else
                              Icon(item.icon, size: 20),
                            const SizedBox(width: 12),
                            Text(item.label),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedFilter = value;
                        });
                        _loadPosts();
                      }
                    },
                  ),
                ),
              ),

              // Posts Content
              Expanded(
                child: _isLoading
                    ? const Center(child: CustomLoadingIndicator())
                    : _posts.isEmpty
                        ? _buildEmptyState()
                        : _buildPostsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    String title;
    String subtitle;
    IconData icon;

    if (_selectedFilter == 'All') {
      title = 'No Posts Yet';
      subtitle = 'No posts from friends or yourself.';
      icon = Icons.public;
    } else if (_selectedFilter == 'Me') {
      title = 'No Posts Yet';
      subtitle = 'Start sharing moments with your friends!';
      icon = Icons.camera_alt_outlined;
    } else {
      final friend = _dropdownItems.firstWhere(
        (item) => item.value == _selectedFilter,
        orElse: () => DropdownItem(value: '', label: 'Friend', icon: Icons.person),
      );
      title = 'No Posts from ${friend.label}';
      subtitle = '${friend.label} hasn\'t shared anything yet.';
      icon = Icons.person_outline;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 64,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPostsList() {
    return RefreshIndicator(
      onRefresh: () async {
        _loadPosts();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _posts.length,
          itemBuilder: (context, index) {
            final post = _posts[index];
            final isMyPost = post['owner']?['_id'] == _currentUserId;
            
            return PostCard(
              post: post,
              onTap: () => _showPostDetails(post),
              onReaction: (emoji) => _handleReaction(post, emoji),
              onOptions: isMyPost ? () => _showPostOptions(post) : null,
            );
          },
        ),
      ),
    );
  }

  void _showPostDetails(Map<String, dynamic> post) {
    showDialog(
      context: context,
      builder: (context) => PostDetailsDialog(
        post: post,
        onReaction: (emoji) => _handleReaction(post, emoji),
        currentUserId: _currentUserId,
      ),
    );
  }

  void _handleReaction(Map<String, dynamic> post, String emoji) {
    final postId = post['_id'] ?? post['id'];
    if (postId != null) {
      // Check if user already has a reaction
      final reactions = post['reactions'] as List<dynamic>? ?? [];
      final userReaction = reactions.firstWhere(
        (reaction) => reaction['user']['_id'] == _currentUserId,
        orElse: () => null,
      );

      if (userReaction != null) {
        if (userReaction['emoji'] == emoji) {
          // Remove reaction if same emoji
          context.read<PostBloc>().add(
            PostEventRemoveReaction(postId: postId),
          );
        } else {
          // Update existing reaction
          context.read<PostBloc>().add(
            PostEventUpdateReaction(postId: postId, emoji: emoji),
          );
        }
      } else {
        // Add new reaction
        context.read<PostBloc>().add(
          PostEventAddReaction(postId: postId, emoji: emoji),
        );
      }
    }
  }
}

class DropdownItem {
  final String value;
  final String label;
  final IconData icon;
  final String? avatarUrl;

  DropdownItem({
    required this.value,
    required this.label,
    required this.icon,
    this.avatarUrl,
  });
}

class PostDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> post;
  final Function(String) onReaction;
  final String? currentUserId;

  const PostDetailsDialog({
    super.key,
    required this.post,
    required this.onReaction,
    this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final emojiCounts = post['emojiCounts'] as Map<String, dynamic>? ?? {};
    final reactions = post['reactions'] as List<dynamic>? ?? [];
    final userReaction = reactions.firstWhere(
      (reaction) => reaction['user']['_id'] == currentUserId,
      orElse: () => null,
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: post['owner']?['avatar']?.isNotEmpty == true
                        ? NetworkImage(post['owner']['avatar'])
                        : const AssetImage('assets/images/boy.png') as ImageProvider,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post['owner']?['username'] ?? 'Unknown',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _formatDate(post['createdAt']),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Image
            if (post['imageUrl'] != null)
              Flexible(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      post['imageUrl'],
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
              ),

            // Caption
            if (post['caption'] != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  post['caption'],
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),

            // Emoji Summary
            if (emojiCounts.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Wrap(
                  spacing: 8,
                  children: emojiCounts.entries
                      .map((entry) => Chip(
                            label: Text('${entry.key} ${entry.value}'),
                            backgroundColor: Colors.grey[100],
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ))
                      .toList(),
                ),
              ),

            // Reactions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ReactionButton(
                    emoji: '❤️',
                    isSelected: userReaction?['emoji'] == '❤️',
                    onPressed: () => onReaction('❤️'),
                  ),
                  _ReactionButton(
                    emoji: '😍',
                    isSelected: userReaction?['emoji'] == '😍',
                    onPressed: () => onReaction('😍'),
                  ),
                  _ReactionButton(
                    emoji: '😂',
                    isSelected: userReaction?['emoji'] == '😂',
                    onPressed: () => onReaction('😂'),
                  ),
                  _ReactionButton(
                    emoji: '👍',
                    isSelected: userReaction?['emoji'] == '👍',
                    onPressed: () => onReaction('👍'),
                  ),
                  _ReactionButton(
                    emoji: '😮',
                    isSelected: userReaction?['emoji'] == '😮',
                    onPressed: () => onReaction('😮'),
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
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return '';
    }
  }
}

class _ReactionButton extends StatelessWidget {
  final String emoji;
  final bool isSelected;
  final VoidCallback onPressed;

  const _ReactionButton({
    required this.emoji,
    required this.onPressed,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected 
              ? Colors.blue.withValues(alpha: 0.2)
              : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: isSelected 
              ? Border.all(color: Colors.blue, width: 2)
              : null,
        ),
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
} 