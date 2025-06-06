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
  ChatBloc? _chatBloc;
  
  List<Message> _messages = [];
  final Map<String, String> _typingUsers = {};
  bool _isTyping = false;
  bool _isConnected = false;
  
  // Pagination variables
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasMoreMessages = true;

  @override
  void initState() {
    super.initState();
    _initializeUserId();
    
    _chatBloc = context.read<ChatBloc>();
    _isConnected = true;
    
    _chatBloc!.add(ChatEventSelectChat(chatId: widget.chat.id));
    _chatBloc!.add(ChatEventLoadMessages(chatId: widget.chat.id, page: _currentPage));
    
    _messageController.addListener(_onTextChanged);
    _scrollController.addListener(_onScroll);
  }

  Future<void> _initializeUserId() async {
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
      _isTyping = true;
      _chatBloc!.add(ChatEventStartTyping(chatId: widget.chat.id));
    } else if (text.isEmpty && _isTyping) {
      _isTyping = false;
      _chatBloc!.add(ChatEventStopTyping(chatId: widget.chat.id));
    }
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    print('🔹 ConversationScreen: Send button pressed, content: "$content", isConnected: $_isConnected');
    
    if (content.isNotEmpty) {
      if (_isTyping) {
        _isTyping = false;
        _chatBloc!.add(ChatEventStopTyping(chatId: widget.chat.id));
      }
      
      print('🔹 ConversationScreen: Sending message via ChatBloc...');
      _chatBloc!.add(
        ChatEventSendMessage(chatId: widget.chat.id, content: content),
      );
      
      _messageController.clear();
      
      // Scroll to bottom after sending
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } else {
      print('🔹 ConversationScreen: Message content is empty, not sending');
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
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

  void _onScroll() {
    // Load more messages when scrolling near the top
    if (_scrollController.position.pixels <= 100 && _hasMoreMessages && !_isLoadingMore) {
      setState(() {
        _isLoadingMore = true;
      });
      _currentPage++;
      print('🔹 Loading more messages - Page: $_currentPage');
      _chatBloc!.add(ChatEventLoadMessages(chatId: widget.chat.id, page: _currentPage));
    }
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _scrollController.removeListener(_onScroll);
    _messageController.dispose();
    _scrollController.dispose();
    
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
                    _getChatDisplayName(),
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
              if (_currentPage == 1) {
                // First load - reverse the messages to show oldest first
                _messages = state.messages.reversed.toList();
              } else {
                // Pagination - reverse and prepend older messages
                final olderMessages = state.messages.reversed.toList();
                _messages.insertAll(0, olderMessages);
              }
              _isLoadingMore = false;
              _hasMoreMessages = state.messages.length >= 20; // Check if we got a full page
            });
            
            // Auto-scroll to bottom only on first load
            if (_currentPage == 1) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToBottom();
              });
            }
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
              
              // Scroll to bottom for new messages
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToBottom();
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
          } else if (state is ChatMessageSent) {
            // When message is sent successfully via HTTP API (fallback)
            setState(() {
              _messages.add(state.message);
            });
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToBottom();
            });
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
        if (state is ChatLoadingMessages && _currentPage == 1) {
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
          reverse: false, // Normal order: oldest at top, newest at bottom
          itemCount: _messages.length + (_isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            // Show loading indicator at the top when loading more
            if (index == 0 && _isLoadingMore) {
              return Container(
                padding: const EdgeInsets.all(16),
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              );
            }
            
            final messageIndex = _isLoadingMore ? index - 1 : index;
            if (messageIndex >= _messages.length) return const SizedBox.shrink();
            
            final message = _messages[messageIndex];
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

  String _getChatDisplayName() {
    if (widget.chat.isGroup) {
      return widget.chat.name ?? 'Group Chat';
    } else {
      final otherParticipant = widget.chat.participants.firstWhere(
        (p) => p.id != currentUserId,
        orElse: () => widget.chat.participants.first,
      );
      return otherParticipant.username;
    }
  }
} 