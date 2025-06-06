import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../features/chat/bloc/chat_bloc.dart';
import '../../../features/chat/bloc/chat_event.dart';
import '../../../features/chat/bloc/chat_state.dart';
import '../../../features/chat/data/models/chat.dart';
import '../../../features/auth/data/constants.dart';

class ChatConversationScreen extends StatefulWidget {
  final Chat chat;

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
  String? currentUserId;
  ChatBloc? _chatBloc; // Store reference to avoid context access in dispose

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    // Store the BLoC reference
    _chatBloc = context.read<ChatBloc>();
    // Select this chat (joins WebSocket room and loads messages)
    _chatBloc!.add(ChatEventSelectChat(chatId: widget.chat.id));
    _chatBloc!.add(ChatEventLoadMessages(chatId: widget.chat.id));
  }

  @override
  void dispose() {
    // Leave the chat room when disposing - use stored reference
    _chatBloc?.add(ChatEventClearSelectedChat());
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = prefs.getString(AuthDataConstants.userIdKey);
    });
  }

  // Helper method to get chat display name
  String _getChatDisplayName() {
    if (widget.chat.isGroup) {
      return widget.chat.name ?? 'Group Chat';
    } else {
      // For private chat, find the other participant
      if (currentUserId != null) {
        final otherParticipant = widget.chat.participants.firstWhere(
          (participant) => participant.id != currentUserId,
          orElse: () => ChatParticipant(id: '', username: 'Unknown'),
        );
        return otherParticipant.username;
      }
      return 'Private Chat';
    }
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
                    _getChatDisplayName(),
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
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatMessageSent) {
            _messageController.clear();
            _scrollToBottom();
          } else if (state is ChatMessageReceived) {
            // Handle real-time message received
            if (state.message.chat == widget.chat.id) {
              _scrollToBottom();
              // Mark message as read if from another user
              if (currentUserId != null && state.message.sender.id != currentUserId) {
                context.read<ChatBloc>().add(
                  ChatEventMarkMessageAsRead(
                    messageId: state.message.id,
                    chatId: widget.chat.id,
                  ),
                );
              }
            }
          } else if (state is ChatSendMessageError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to send message: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: _buildMessagesList(state),
              ),
              _buildMessageInput(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessagesList(ChatState state) {
    if (state is ChatLoadingMessages) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ChatLoadMessagesError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error loading messages: ${state.message}'),
            ElevatedButton(
              onPressed: () {
                context.read<ChatBloc>().add(
                  ChatEventLoadMessages(chatId: widget.chat.id),
                );
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Handle the case where we have loaded messages for this specific chat
    final chatBloc = context.read<ChatBloc>();
    final messages = chatBloc.getMessagesForChat(widget.chat.id);
    
    if (state is ChatMessagesLoaded && state.chatId == widget.chat.id) {
      // Use messages from the state
      final stateMessages = state.messages;

      if (stateMessages.isEmpty) {
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

      // Auto-scroll when messages are loaded
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });

      return ListView.builder(
        controller: _scrollController,
        reverse: true,
        itemCount: stateMessages.length,
        itemBuilder: (context, index) {
          final message = stateMessages[index];
          return _buildMessageBubble(message);
        },
      );
    }
    
    // If we have cached messages but no specific loaded state yet
    if (messages.isNotEmpty) {
      return ListView.builder(
        controller: _scrollController,
        reverse: true,
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          return _buildMessageBubble(message);
        },
      );
    }

    // Default empty state
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

  Widget _buildMessageBubble(Message message) {
    final isCurrentUser = currentUserId != null && message.sender.id == currentUserId;

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
              backgroundImage: message.sender.avatar != null 
                  ? NetworkImage(message.sender.avatar!) 
                  : null,
              child: message.sender.avatar == null
                  ? Text(
                      message.sender.username.isNotEmpty 
                          ? message.sender.username[0].toUpperCase()
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
                      message.sender.username,
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
                          message.readBy.length > 1 ? Icons.done_all : Icons.done,
                          size: 12,
                          color: message.readBy.length > 1 
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
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFA31D1D),
              child: const Icon(Icons.person, color: Colors.white, size: 16),
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
          BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              final isLoading = state is ChatSendingMessage;
              return CircleAvatar(
                backgroundColor: const Color(0xFFA31D1D),
                child: IconButton(
                  onPressed: isLoading ? null : _sendMessage,
                  icon: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send, color: Colors.white),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      context.read<ChatBloc>().add(
        ChatEventSendMessage(
          chatId: widget.chat.id,
          content: text,
        ),
      );
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _showGroupInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.chat.name ?? 'Group Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.chat.description != null) ...[
              Text('Description: ${widget.chat.description}'),
              const SizedBox(height: 8),
            ],
            Text('Participants: ${widget.chat.participants.length}'),
            Text('Admins: ${widget.chat.admins.length}'),
            Text('Created: ${DateFormat('dd/MM/yyyy').format(widget.chat.createdAt)}'),
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