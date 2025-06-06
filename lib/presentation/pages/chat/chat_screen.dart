import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Static mock data for UI demonstration
class MockChat {
  final String id;
  final String name;
  final bool isGroup;
  final String? description;
  final String? avatar;
  final String? latestMessageText;
  final DateTime? lastMessageTime;
  final bool hasUnread;

  MockChat({
    required this.id,
    required this.name,
    required this.isGroup,
    this.description,
    this.avatar,
    this.latestMessageText,
    this.lastMessageTime,
    this.hasUnread = false,
  });
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  // Mock data for demonstration
  final List<MockChat> _mockChats = [
    MockChat(
      id: '1',
      name: 'John Doe',
      isGroup: false,
      latestMessageText: 'Hey, how are you?',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
      hasUnread: true,
    ),
    MockChat(
      id: '2',
      name: 'Flutter Developers',
      isGroup: true,
      description: 'Discuss Flutter development',
      latestMessageText: 'Check out this new widget!',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
      hasUnread: false,
    ),
    MockChat(
      id: '3',
      name: 'Team Project',
      isGroup: true,
      description: 'Work collaboration',
      latestMessageText: 'Meeting at 3 PM',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
      hasUnread: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFCF6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFEFCF6),
        elevation: 0,
        title: const Row(
          children: [
            Text(
              'Messages',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              // UI only - no logic
            },
            icon: const Icon(Icons.refresh, color: Colors.black),
          ),
          IconButton(
            onPressed: () {
              // UI only - no logic
            },
            icon: const Icon(Icons.wifi, color: Colors.black),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFA31D1D),
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'All Chats'),
            Tab(text: 'Groups'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Quick action buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showCreatePrivateChatDialog(),
                    icon: const Icon(Icons.person_add),
                    label: const Text('New Private Chat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA31D1D),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // UI only - no navigation logic
                    },
                    icon: const Icon(Icons.group_add),
                    label: const Text('Create Group'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Chat list
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllChatsTab(),
                _buildGroupChatsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllChatsTab() {
    if (_mockChats.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No chats yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Start a conversation with friends!',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _mockChats.length,
      itemBuilder: (context, index) {
        final chat = _mockChats[index];
        return _buildChatTile(chat);
      },
    );
  }

  Widget _buildGroupChatsTab() {
    final groupChats = _mockChats.where((chat) => chat.isGroup).toList();
    
    if (groupChats.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No group chats yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Create a group to start chatting!',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: groupChats.length,
      itemBuilder: (context, index) {
        final chat = groupChats[index];
        return _buildChatTile(chat);
      },
    );
  }

  Widget _buildChatTile(MockChat chat) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: chat.isGroup ? Colors.blue : const Color(0xFFA31D1D),
          backgroundImage: chat.avatar != null ? NetworkImage(chat.avatar!) : null,
          child: chat.avatar == null
              ? Icon(
                  chat.isGroup ? Icons.group : Icons.person,
                  color: Colors.white,
                )
              : null,
        ),
        title: Text(
          chat.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: chat.latestMessageText != null
            ? Text(
                chat.latestMessageText!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : Text(chat.isGroup ? (chat.description ?? 'No messages yet') : 'No messages yet'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (chat.lastMessageTime != null)
              Text(
                _formatTime(chat.lastMessageTime!),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            const SizedBox(height: 4),
            // Show unread indicator if there are unread messages
            if (chat.hasUnread)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFA31D1D),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        onTap: () {
          // UI only - no navigation logic
        },
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (difference.inDays < 7) {
      return DateFormat('EEE').format(dateTime);
    } else {
      return DateFormat('dd/MM').format(dateTime);
    }
  }

  void _showCreatePrivateChatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Private Chat'),
        content: const Text('Choose a friend to start chatting with:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // UI only - no navigation logic
            },
            child: const Text('Choose Friend'),
          ),
        ],
      ),
    );
  }
} 