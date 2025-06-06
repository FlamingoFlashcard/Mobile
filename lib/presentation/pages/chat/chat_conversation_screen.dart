import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../features/chat/bloc/chat_bloc.dart';
import '../../../features/chat/bloc/chat_event.dart';
import '../../../features/chat/bloc/chat_state.dart';
import '../../../features/chat/data/models/chat.dart';
import '../../../features/chat/data/models/message.dart';
import '../../../features/auth/data/auth_local_data_source.dart';

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
  ChatBloc? _chatBloc; // Store ChatBloc reference
  
  List<Message> _messages = [];
  final Map<String, String> _typingUsers = {}; // userId -> username
  bool _isTyping = false;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _initializeUserId();
    
    // Store ChatBloc reference
    _chatBloc = context.read<ChatBloc>();
    
    // Check initial connection status
    _isConnected = true; // Allow sending even if WebSocket is connecting
    
    // Select this chat
    _chatBloc!.add(ChatEventSelectChat(chatId: widget.chat.id));
    
    // Load messages for this chat
    _chatBloc!.add(ChatEventLoadMessages(chatId: widget.chat.id));
    
    // Listen for text changes to handle typing indicators
    _messageController.addListener(_onTextChanged);
  }

  Future<void> _initializeUserId() async {
    // Get current user ID from auth
    try {
      final authDataSource = AuthLocalDataSource(await SharedPreferences.getInstance());
      final userId = await authDataSource.getUserId();
      setState(() {
        currentUserId = userId ?? 'anonymous_user';
      });
    } catch (e) {
      setState(() {
        currentUserId = 'anonymous_user';
      });
    }
  }

  void _onTextChanged() {
    final text = _messageController.text;
    
    if (text.isNotEmpty && !_isTyping) {
      // Start typing
      _isTyping = true;
      _chatBloc!.add(ChatEventStartTyping(chatId: widget.chat.id));
    } else if (text.isEmpty && _isTyping) {
      // Stop typing
      _isTyping = false;
      _chatBloc!.add(ChatEventStopTyping(chatId: widget.chat.id));
    }
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    print('🔹 ConversationScreen: Send button pressed, content: "$content", isConnected: $_isConnected');
    
    if (content.isNotEmpty) {
      // Stop typing indicator
      if (_isTyping) {
        _isTyping = false;
        _chatBloc!.add(ChatEventStopTyping(chatId: widget.chat.id));
      }
      
      print('🔹 ConversationScreen: Sending message via ChatBloc...');
      // Send message
      _chatBloc!.add(
        ChatEventSendMessage(chatId: widget.chat.id, content: content),
      );
      
      _messageController.clear();
      
      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } else {
      print('🔹 ConversationScreen: Message content is empty, not sending');
    }
  }

  void _markMessageAsRead(String messageId) {
    _chatBloc!.add(
      ChatEventMarkMessageAsRead(
        chatId: widget.chat.id,
        messageId: messageId,
      ),
    );
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _scrollController.dispose();
    
    // Stop typing if user leaves screen while typing
    if (_isTyping) {
      _chatBloc!.add(ChatEventStopTyping(chatId: widget.chat.id));
    }
    
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
                    widget.chat.name ?? 'Unknown Chat',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  BlocBuilder<ChatBloc, ChatState>(
                    builder: (context, state) {
                      if (state is ChatWebSocketConnected) {
                        return const Text(
                          'Online',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                          ),
                        );
                      } else if (state is ChatWebSocketConnecting) {
                        return const Text(
                          'Connecting...',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 12,
                          ),
                        );
                      } else if (state is ChatWebSocketError || state is ChatWebSocketDisconnected) {
                        return const Text(
                          'Offline',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        );
                      }
                      
                      if (widget.chat.isGroup && widget.chat.description != null) {
                        return Text(
                          widget.chat.description!,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        );
                      }
                      
                      return const SizedBox.shrink();
                    },
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
      body: BlocListener<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatMessagesLoaded && state.chatId == widget.chat.id) {
            setState(() {
              _messages = state.messages;
            });
          } else if (state is ChatMessageReceived) {
            // Add new message if it belongs to this chat
            if (state.message.chat == widget.chat.id) {
              setState(() {
                _messages.add(state.message);
              });
              
              // Auto-mark message as read if it's not from current user
              if (currentUserId != null && state.message.sender.id != currentUserId) {
                _markMessageAsRead(state.message.id);
              }
              
              // Scroll to bottom
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scrollController.hasClients) {
                  _scrollController.animateTo(
                    0.0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                }
              });
            }
          } else if (state is ChatUserTyping && state.chatId == widget.chat.id) {
            setState(() {
              _typingUsers[state.userId] = state.username;
            });
          } else if (state is ChatUserStoppedTyping && state.chatId == widget.chat.id) {
            setState(() {
              _typingUsers.remove(state.userId);
            });
          } else if (state is ChatWebSocketConnected) {
            setState(() {
              _isConnected = true;
            });
          } else if (state is ChatWebSocketDisconnected || state is ChatWebSocketError) {
            setState(() {
              _isConnected = false;
            });
          } else if (state is ChatSendMessageError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to send message: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Column(
          children: [
            // Connection status indicator
            BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is ChatWebSocketConnecting) {
                  return Container(
                    color: Colors.orange,
                    padding: const EdgeInsets.all(4),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 1, color: Colors.white),
                        ),
                        SizedBox(width: 8),
                        Text('Connecting...', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  );
                } else if (state is ChatWebSocketError) {
                  return Container(
                    color: Colors.red,
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, color: Colors.white, size: 12),
                        const SizedBox(width: 8),
                        const Text('Connection error', style: TextStyle(color: Colors.white, fontSize: 12)),
                        TextButton(
                          onPressed: () {
                            _chatBloc!.add(ChatEventConnectWebSocket());
                          },
                          child: const Text('Retry', style: TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            
            Expanded(child: _buildMessagesList()),
            
            // Typing indicator
            if (_typingUsers.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                alignment: Alignment.centerLeft,
                child: Text(
                  '${_typingUsers.values.join(', ')} ${_typingUsers.length == 1 ? 'is' : 'are'} typing...',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ),
            
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state is ChatLoadingMessages) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (_messages.isEmpty) {
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
          itemCount: _messages.length,
          itemBuilder: (context, index) {
            final message = _messages.reversed.toList()[index];
            return _buildMessageBubble(message);
          },
        );
      },
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
          BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              final isLoading = state is ChatSendingMessage;
              return FloatingActionButton(
                onPressed: (isLoading || !_isConnected) ? null : _sendMessage,
                backgroundColor: _isConnected ? const Color(0xFFA31D1D) : Colors.grey,
                mini: true,
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.send, color: Colors.white),
              );
            },
          ),
        ],
      ),
    );
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
            const SizedBox(height: 16),
            const Text('Members:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...widget.chat.participants.map((participant) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundImage: participant.avatar != null 
                        ? NetworkImage(participant.avatar!) 
                        : null,
                    child: participant.avatar == null
                        ? Text(
                            participant.username.isNotEmpty 
                                ? participant.username[0].toUpperCase()
                                : '?',
                            style: const TextStyle(fontSize: 10),
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(participant.username)),
                  if (widget.chat.admins.contains(participant.id))
                    const Icon(Icons.admin_panel_settings, size: 16, color: Colors.blue),
                ],
              ),
            )).toList(),
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