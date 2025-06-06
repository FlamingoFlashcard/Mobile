import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../features/chat/bloc/chat_bloc.dart';
import '../../../features/chat/bloc/chat_event.dart';
import '../../../features/chat/bloc/chat_state.dart';
import '../../../features/chat/data/models/chat.dart';
import '../../../features/auth/data/auth_local_data_source.dart';
import 'chat_conversation_screen.dart';
import 'create_group_chat_screen.dart';
import '../friends/friends_page.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  List<Chat> _chats = [];
  List<String> _onlineUsers = [];
  bool _isConnected = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeCurrentUser();
    
    // Connect to WebSocket and load chats
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatBloc>().add(ChatEventConnectWebSocket());
      context.read<ChatBloc>().add(ChatEventLoadChats());
    });
  }

  Future<void> _initializeCurrentUser() async {
    try {
      final authDataSource = AuthLocalDataSource(await SharedPreferences.getInstance());
      final userId = await authDataSource.getUserId();
      setState(() {
        _currentUserId = userId;
      });
    } catch (e) {
      print('Error getting current user ID: $e');
    }
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
              context.read<ChatBloc>().add(ChatEventRefreshChats());
            },
            icon: const Icon(Icons.refresh, color: Colors.black),
          ),
          BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              Color iconColor = Colors.grey;
              if (state is ChatWebSocketConnected) {
                iconColor = Colors.green;
              } else if (state is ChatWebSocketConnecting) {
                iconColor = Colors.orange;
              } else if (state is ChatWebSocketError || state is ChatWebSocketDisconnected) {
                iconColor = Colors.red;
              }
              
              return IconButton(
                onPressed: () {
                  if (!_isConnected) {
                    context.read<ChatBloc>().add(ChatEventConnectWebSocket());
                  }
                },
                icon: Icon(Icons.wifi, color: iconColor),
              );
            },
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
      body: BlocListener<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatChatsLoaded) {
            setState(() {
              _chats = state.chats;
              // Sort chats by most recent message time
              _chats.sort((a, b) {
                final aTime = a.lastMessageTime ?? a.updatedAt;
                final bTime = b.lastMessageTime ?? b.updatedAt;
                return bTime.compareTo(aTime); // Most recent first
              });
            });
          } else if (state is ChatOnlineUsersUpdated) {
            setState(() {
              _onlineUsers = state.onlineUsers;
            });
          } else if (state is ChatWebSocketConnected) {
            setState(() {
              _isConnected = true;
            });
          } else if (state is ChatWebSocketDisconnected || state is ChatWebSocketError) {
            setState(() {
              _isConnected = false;
            });
          } else if (state is ChatNewMessageNotification) {
            // Update latest message in chat list
            setState(() {
              final chatIndex = _chats.indexWhere((chat) => chat.id == state.chatId);
              if (chatIndex != -1) {
                // Update the chat with new message info
                // In a real implementation, you might want to update the latestMessage
                // For now, we'll trigger a refresh
                context.read<ChatBloc>().add(ChatEventLoadChats());
              }
            });
            
            // Show notification
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('New message: ${state.message.text}'),
                action: SnackBarAction(
                  label: 'View',
                  onPressed: () {
                    final chat = _chats.firstWhere((chat) => chat.id == state.chatId);
                    _navigateToConversation(chat);
                  },
                ),
              ),
            );
          } else if (state is ChatPrivateChatCreated) {
            _navigateToConversation(state.chat);
          } else if (state is ChatGroupChatCreated) {
            _navigateToConversation(state.chat);
          } else if (state is ChatLoadChatsError) {
            _showErrorDialog('Error Loading Chats', state.message);
          } else if (state is ChatCreateChatError) {
            _showErrorDialog('Error Creating Chat', state.message);
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
                    padding: const EdgeInsets.all(8),
                    child: const Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        ),
                        SizedBox(width: 8),
                        Text('Connecting...', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  );
                } else if (state is ChatWebSocketError) {
                  return Container(
                    color: Colors.red,
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Connection error: ${state.message}',
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            context.read<ChatBloc>().add(ChatEventConnectWebSocket());
                          },
                          child: const Text('Retry', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            
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
                      onPressed: () => _navigateToCreateGroup(),
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
      ),
    );
  }

  Widget _buildAllChatsTab() {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state is ChatLoadingChats) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (_chats.isEmpty) {
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
          itemCount: _chats.length,
          itemBuilder: (context, index) {
            final chat = _chats[index];
            return _buildChatTile(chat);
          },
        );
      },
    );
  }

  Widget _buildGroupChatsTab() {
    final groupChats = _chats.where((chat) => chat.isGroup).toList();
    
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state is ChatLoadingChats) {
          return const Center(child: CircularProgressIndicator());
        }
        
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
      },
    );
  }

  Widget _buildChatTile(Chat chat) {
    final hasUnreadMessages = chat.latestMessage != null; // Simplified logic
    final isOnline = chat.participants.any((p) => _onlineUsers.contains(p.id));
    
    // Get proper chat display name
    String chatDisplayName;
    if (chat.isGroup) {
      chatDisplayName = chat.name ?? 'Group Chat';
    } else {
      // For private chats, show the other participant's name
      final otherParticipant = chat.participants.firstWhere(
        (p) => p.id != _currentUserId,
        orElse: () => chat.participants.first,
      );
      chatDisplayName = otherParticipant.username;
    }
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: chat.isGroup ? Colors.blue : const Color(0xFFA31D1D),
              backgroundImage: chat.avatar != null ? NetworkImage(chat.avatar!) : null,
              child: chat.avatar == null
                  ? Icon(
                      chat.isGroup ? Icons.group : Icons.person,
                      color: Colors.white,
                    )
                  : null,
            ),
            if (!chat.isGroup && isOnline)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          chatDisplayName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: chat.latestMessage != null
            ? Text(
                chat.latestMessage!.text,
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
            if (hasUnreadMessages)
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
        onTap: () => _navigateToConversation(chat),
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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const FriendsPage(
          selectMode: true,
          multiSelect: false,
        ),
      ),
    ).then((selectedFriendId) {
      if (selectedFriendId != null && selectedFriendId is String && mounted) {
        // Create private chat with selected friend
        context.read<ChatBloc>().add(
          ChatEventCreatePrivateChat(friendId: selectedFriendId),
        );
      }
    });
  }

  void _navigateToCreateGroup() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<ChatBloc>(),
          child: const CreateGroupChatScreen(),
        ),
      ),
    );
  }

  void _navigateToConversation(Chat chat) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<ChatBloc>(),
          child: ChatConversationScreen(chat: chat),
        ),
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(message, style: TextStyle(fontSize: 14)),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}