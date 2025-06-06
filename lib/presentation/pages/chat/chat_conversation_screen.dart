import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Mock data for UI demonstration
class MockMessage {
  final String id;
  final String text;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final DateTime createdAt;
  final bool isRead;

  MockMessage({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.createdAt,
    this.isRead = false,
  });
}

class MockChat {
  final String id;
  final String name;
  final bool isGroup;
  final String? description;
  final String? avatar;

  MockChat({
    required this.id,
    required this.name,
    required this.isGroup,
    this.description,
    this.avatar,
  });
}

class ChatConversationScreen extends StatefulWidget {
  final MockChat chat;

  const ChatConversationScreen({
    super.key,
    required this.chat,
  });

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String currentUserId = 'current_user_123';

  // Mock messages for demonstration
  final List<MockMessage> _mockMessages = [
    MockMessage(
      id: '1',
      text: 'Hey! How are you doing?',
      senderId: 'other_user_456',
      senderName: 'John Doe',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: true,
    ),
    MockMessage(
      id: '2',
      text: 'I\'m doing great! Just working on this Flutter project.',
      senderId: 'current_user_123',
      senderName: 'Me',
      createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      isRead: true,
    ),
    MockMessage(
      id: '3',
      text: 'That sounds awesome! What are you building?',
      senderId: 'other_user_456',
      senderName: 'John Doe',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: true,
    ),
    MockMessage(
      id: '4',
      text: 'A chat application with a clean UI design.',
      senderId: 'current_user_123',
      senderName: 'Me',
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      isRead: false,
    ),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFCF6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFEFCF6),
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: widget.chat.isGroup ? Colors.blue : const Color(0xFFA31D1D),
              backgroundImage: widget.chat.avatar != null 
                  ? NetworkImage(widget.chat.avatar!) 
                  : null,
              child: widget.chat.avatar == null
                  ? Icon(
                      widget.chat.isGroup ? Icons.group : Icons.person,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.chat.name,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.chat.isGroup && widget.chat.description != null)
                    Text(
                      widget.chat.description!,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (widget.chat.isGroup)
            IconButton(
              onPressed: () => _showGroupInfo(),
              icon: const Icon(Icons.info_outline, color: Colors.black),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessagesList()),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    if (_mockMessages.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No messages yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Start the conversation!',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      itemCount: _mockMessages.length,
      itemBuilder: (context, index) {
        final message = _mockMessages.reversed.toList()[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(MockMessage message) {
    final isCurrentUser = message.senderId == currentUserId;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: isCurrentUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        children: [
          if (!isCurrentUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey,
              backgroundImage: message.senderAvatar != null 
                  ? NetworkImage(message.senderAvatar!) 
                  : null,
              child: message.senderAvatar == null
                  ? Text(
                      message.senderName.isNotEmpty 
                          ? message.senderName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isCurrentUser ? const Color(0xFFA31D1D) : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isCurrentUser && widget.chat.isGroup)
                    Text(
                      message.senderName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isCurrentUser ? Colors.white : Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('HH:mm').format(message.createdAt),
                        style: TextStyle(
                          color: isCurrentUser ? Colors.white.withValues(alpha: 0.7) : Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                      if (isCurrentUser) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isRead ? Icons.done_all : Icons.done,
                          size: 12,
                          color: message.isRead 
                              ? Colors.blue 
                              : Colors.white.withValues(alpha: 0.7),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isCurrentUser) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFFA31D1D),
              child: Icon(Icons.person, color: Colors.white, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              maxLines: null,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: _sendMessage,
            backgroundColor: const Color(0xFFA31D1D),
            mini: true,
            child: const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      // UI only - no actual sending logic
      _messageController.clear();
    }
  }

  void _showGroupInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.chat.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.chat.description != null) ...[
              Text('Description: ${widget.chat.description}'),
              const SizedBox(height: 8),
            ],
            const Text('Participants: 5'),
            const Text('Admins: 2'),
            Text('Created: ${DateFormat('dd/MM/yyyy').format(DateTime.now().subtract(const Duration(days: 30)))}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
} 