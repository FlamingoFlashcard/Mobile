import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../features/chat/bloc/chat_bloc.dart';
import '../../../features/chat/bloc/chat_event.dart';
import '../../../features/chat/bloc/chat_state.dart';
import '../../../features/chat/data/models/chat.dart';
import '../../../features/auth/data/constants.dart';
import '../../../services/websocket_service.dart';
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
  String? currentUserId;
  final WebSocketService _webSocketService = WebSocketService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCurrentUser();
    // Load chats when screen initializes
    context.read<ChatBloc>().add(ChatEventLoadChats());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = prefs.getString(AuthDataConstants.userIdKey);
    });
  }

  // Helper method to get chat display name
  String _getChatDisplayName(Chat chat) {
    if (chat.isGroup) {
      return chat.name ?? 'Group Chat';
    } else {
      // For private chat, find the other participant
      if (currentUserId != null) {
        final otherParticipant = chat.participants.firstWhere(
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
            const Text(
              'Messages',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            // WebSocket connection status indicator
            StreamBuilder<bool>(
              stream: Stream.periodic(const Duration(seconds: 1), (_) => _webSocketService.isConnected),
              builder: (context, snapshot) {
                final isConnected = snapshot.data ?? false;
                return Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isConnected ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.read<ChatBloc>().add(ChatEventRefreshChats());
            },
            icon: const Icon(Icons.refresh, color: Colors.black),
          ),
          // Debug button to test WebSocket connection
          IconButton(
            onPressed: () async {
              final isConnected = _webSocketService.isConnected;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('WebSocket Status: ${isConnected ? "Connected" : "Disconnected"}'),
                  backgroundColor: isConnected ? Colors.green : Colors.red,
                ),
              );
              
              if (!isConnected) {
                await _webSocketService.connect();
              }
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
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatCreateChatError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error creating chat: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is ChatPrivateChatCreated || state is ChatGroupChatCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Chat created successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
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
                        onPressed: () => _navigateToCreateGroupChat(),
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
                    _buildAllChatsTab(state),
                    _buildGroupChatsTab(state),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAllChatsTab(ChatState state) {
    if (state is ChatLoadingChats) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ChatLoadChatsError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${state.message}'),
            ElevatedButton(
              onPressed: () {
                context.read<ChatBloc>().add(ChatEventLoadChats());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state is ChatChatsLoaded) {
      final chats = state.chats;
      
      if (chats.isEmpty) {
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
        itemCount: chats.length,
        itemBuilder: (context, index) {
          final chat = chats[index];
          return _buildChatTile(chat);
        },
      );
    }

    return const Center(
      child: Text('Load chats to get started'),
    );
  }

  Widget _buildGroupChatsTab(ChatState state) {
    if (state is ChatChatsLoaded) {
      final groupChats = state.chats.where((chat) => chat.isGroup).toList();
      
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

    return _buildAllChatsTab(state);
  }

  Widget _buildChatTile(Chat chat) {
    final displayName = _getChatDisplayName(chat);
    
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
          displayName,
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
            if (chat.latestMessage != null && currentUserId != null && 
                !chat.latestMessage!.readBy.contains(currentUserId))
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
        onTap: () => _navigateToChatConversation(chat),
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
              _navigateToFriendsForChat();
            },
            child: const Text('Choose Friend'),
          ),
        ],
      ),
    );
  }

  void _navigateToFriendsForChat() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const FriendsPage(selectMode: true),
      ),
    ).then((selectedFriendId) {
      if (selectedFriendId != null && mounted) {
        context.read<ChatBloc>().add(
          ChatEventCreatePrivateChat(friendId: selectedFriendId),
        );
      }
    });
  }

  void _navigateToCreateGroupChat() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateGroupChatScreen(),
      ),
    );
  }

  void _navigateToChatConversation(Chat chat) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatConversationScreen(chat: chat),
      ),
    ).then((_) {
      // Refresh chats when returning from conversation
      if (mounted) {
        context.read<ChatBloc>().add(ChatEventRefreshChats());
      }
    });
  }
} 