import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/chat_bloc.dart';
import 'bloc/chat_event.dart';
import 'bloc/chat_state.dart';
import 'data/models/message.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String chatName;

  const ChatScreen({
    Key? key,
    required this.chatId,
    required this.chatName,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Message> _messages = [];
  final List<String> _onlineUsers = [];
  final Map<String, String> _typingUsers = {}; // userId -> username
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // Connect to WebSocket when screen loads
    context.read<ChatBloc>().add(ChatEventConnectWebSocket());
    
    // Select this chat
    context.read<ChatBloc>().add(ChatEventSelectChat(chatId: widget.chatId));
    
    // Listen for text changes to handle typing indicators
    _messageController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final text = _messageController.text;
    
    if (text.isNotEmpty && !_isTyping) {
      // Start typing
      _isTyping = true;
      context.read<ChatBloc>().add(ChatEventStartTyping(chatId: widget.chatId));
    } else if (text.isEmpty && _isTyping) {
      // Stop typing
      _isTyping = false;
      context.read<ChatBloc>().add(ChatEventStopTyping(chatId: widget.chatId));
    }
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isNotEmpty) {
      // Stop typing indicator
      if (_isTyping) {
        _isTyping = false;
        context.read<ChatBloc>().add(ChatEventStopTyping(chatId: widget.chatId));
      }
      
      // Send message
      context.read<ChatBloc>().add(
        ChatEventSendMessage(chatId: widget.chatId, content: content),
      );
      
      _messageController.clear();
    }
  }

  void _markMessageAsRead(String messageId) {
    context.read<ChatBloc>().add(
      ChatEventMarkMessageAsRead(
        chatId: widget.chatId,
        messageId: messageId,
      ),
    );
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    
    // Stop typing if user leaves screen while typing
    if (_isTyping) {
      context.read<ChatBloc>().add(ChatEventStopTyping(chatId: widget.chatId));
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.chatName),
            BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is ChatOnlineUsersUpdated) {
                  return Text(
                    '${state.onlineUsers.length} online',
                    style: Theme.of(context).textTheme.bodySmall,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Connection status indicator
          BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              if (state is ChatWebSocketConnecting) {
                return Container(
                  color: Colors.orange,
                  padding: const EdgeInsets.all(8),
                  child: const Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Connecting...'),
                    ],
                  ),
                );
              } else if (state is ChatWebSocketDisconnected) {
                return Container(
                  color: Colors.red,
                  padding: const EdgeInsets.all(8),
                  child: const Row(
                    children: [
                      Icon(Icons.error, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Disconnected', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                );
              } else if (state is ChatWebSocketError) {
                return Container(
                  color: Colors.red,
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Error: ${state.message}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          
          // Messages list
          Expanded(
            child: BlocListener<ChatBloc, ChatState>(
              listener: (context, state) {
                if (state is ChatMessageReceived) {
                  setState(() {
                    _messages.add(state.message);
                  });
                  
                  // Auto-mark message as read
                  _markMessageAsRead(state.message.id);
                } else if (state is ChatNewMessageNotification) {
                  // Handle notification (show snackbar, play sound, etc.)
                  if (state.chatId != widget.chatId) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('New message: ${state.message.text}'),
                        action: SnackBarAction(
                          label: 'View',
                          onPressed: () {
                            // Navigate to that chat
                          },
                        ),
                      ),
                    );
                  }
                } else if (state is ChatOnlineUsersUpdated) {
                  setState(() {
                    _onlineUsers.clear();
                    _onlineUsers.addAll(state.onlineUsers);
                  });
                } else if (state is ChatUserTyping && state.chatId == widget.chatId) {
                  setState(() {
                    _typingUsers[state.userId] = state.username;
                  });
                } else if (state is ChatUserStoppedTyping && state.chatId == widget.chatId) {
                  setState(() {
                    _typingUsers.remove(state.userId);
                  });
                }
              },
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return ListTile(
                    title: Text(message.sender.username),
                    subtitle: Text(message.text),
                    trailing: Text(
                      message.createdAt.toString().substring(11, 16),
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Typing indicator
          if (_typingUsers.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(8),
              child: Text(
                '${_typingUsers.values.join(', ')} ${_typingUsers.length == 1 ? 'is' : 'are'} typing...',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          
          // Message input
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                BlocBuilder<ChatBloc, ChatState>(
                  builder: (context, state) {
                    final isLoading = state is ChatSendingMessage;
                    return IconButton(
                      onPressed: isLoading ? null : _sendMessage,
                      icon: isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Example of how to provide the ChatBloc
class ChatApp extends StatelessWidget {
  const ChatApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (context) => ChatBloc(),
        child: const ChatScreen(
          chatId: 'your-chat-id',
          chatName: 'Chat Room',
        ),
      ),
    );
  }
} 