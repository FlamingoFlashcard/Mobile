import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/chat_repository.dart';
import '../data/models/chat.dart';
import '../../../services/websocket_service.dart';
import 'chat_event.dart';
import 'chat_state.dart';
import 'dart:async';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _chatRepository = ChatRepository();
  final WebSocketService _webSocketService = WebSocketService();
  List<Chat> _chats = [];
  final Map<String, List<Message>> _chatMessages = {};
  StreamSubscription? _webSocketSubscription;
  String? _currentChatId;

  ChatBloc() : super(ChatInitial()) {
    
    on<ChatEventLoadChats>(_onLoadChats);
    on<ChatEventCreatePrivateChat>(_onCreatePrivateChat);
    on<ChatEventCreateGroupChat>(_onCreateGroupChat);
    on<ChatEventAddMembersToGroup>(_onAddMembersToGroup);
    on<ChatEventRemoveMembersFromGroup>(_onRemoveMembersFromGroup);
    on<ChatEventLoadMessages>(_onLoadMessages);
    on<ChatEventSendMessage>(_onSendMessage);
    on<ChatEventMarkMessageAsRead>(_onMarkMessageAsRead);
    on<ChatEventLoadUnreadCount>(_onLoadUnreadCount);
    on<ChatEventSelectChat>(_onSelectChat);
    on<ChatEventClearSelectedChat>(_onClearSelectedChat);
    on<ChatEventRefreshChats>(_onRefreshChats);
    on<ChatEventWebSocketMessage>(_onWebSocketMessage);
    on<ChatEventConnectWebSocket>(_onConnectWebSocket);
    on<ChatEventDisconnectWebSocket>(_onDisconnectWebSocket);

    // Initialize WebSocket connection
    _initializeWebSocket();
  }

  void _initializeWebSocket() {
    // Listen to WebSocket messages
    _webSocketSubscription = _webSocketService.messageStream.listen((data) {
      add(ChatEventWebSocketMessage(data: data));
    });
    
    // Connect WebSocket
    add(ChatEventConnectWebSocket());
  }

  Future<void> _onConnectWebSocket(
    ChatEventConnectWebSocket event,
    Emitter<ChatState> emit,
  ) async {
    await _webSocketService.connect();
  }

  Future<void> _onDisconnectWebSocket(
    ChatEventDisconnectWebSocket event,
    Emitter<ChatState> emit,
  ) async {
    _webSocketService.disconnect();
  }

  Future<void> _onWebSocketMessage(
    ChatEventWebSocketMessage event,
    Emitter<ChatState> emit,
  ) async {
    final data = event.data;
    final type = data['type'];

    switch (type) {
      case 'message':
        _handleNewMessage(data, emit);
        break;
      case 'message_read':
        _handleMessageRead(data, emit);
        break;
      case 'user_joined':
        _handleUserJoined(data, emit);
        break;
      case 'user_left':
        _handleUserLeft(data, emit);
        break;
      case 'chat_updated':
        _handleChatUpdated(data, emit);
        break;
      case 'connection_established':
        print('WebSocket connection established');
        break;
      case 'error':
        print('WebSocket error: ${data['message']}');
        break;
    }
  }

  void _handleNewMessage(Map<String, dynamic> data, Emitter<ChatState> emit) {
    try {
      final messageData = data['message'];
      final message = Message.fromJson(messageData);
      final chatId = message.chat;
      
      // Add message to local cache
      final existingMessages = _chatMessages[chatId] ?? [];
      
      // Check if message already exists to avoid duplicates
      final messageExists = existingMessages.any((m) => m.id == message.id);
      if (!messageExists) {
        _chatMessages[chatId] = [message, ...existingMessages];
      }
      
      // Update chat list with latest message
      final chatIndex = _chats.indexWhere((chat) => chat.id == chatId);
      if (chatIndex != -1) {
        final updatedChats = [..._chats];
        final chat = _chats[chatIndex];
        final updatedChat = Chat(
          id: chat.id,
          isGroup: chat.isGroup,
          participants: chat.participants,
          admins: chat.admins,
          name: chat.name,
          description: chat.description,
          avatar: chat.avatar,
          createdAt: chat.createdAt,
          updatedAt: DateTime.now(),
          latestMessage: message,
          lastMessageTime: message.createdAt,
        );
        updatedChats[chatIndex] = updatedChat;
        
        // Move chat to top of list
        updatedChats.removeAt(chatIndex);
        updatedChats.insert(0, updatedChat);
        _chats = updatedChats;
        
        emit(ChatChatsLoaded(chats: _chats));
      }
      
      // If viewing this chat, update messages
      if (_currentChatId == chatId) {
        emit(ChatMessagesLoaded(
          chatId: chatId,
          messages: _chatMessages[chatId] ?? [],
          pagination: MessagesPagination(total: 0, page: 1, limit: 20, pages: 1),
        ));
      }
      
      // Emit message received for all messages
      emit(ChatMessageReceived(message: message));
      
      // If this is our own message (determined by checking if we're in sending state), 
      // emit ChatMessageSent to clear the loading state
      if (state is ChatSendingMessage) {
        emit(ChatMessageSent(message: message));
      }
      
    } catch (e) {
      print('Error handling new message: $e');
    }
  }

  void _handleMessageRead(Map<String, dynamic> data, Emitter<ChatState> emit) {
    final messageId = data['messageId'];
    final readBy = data['readBy'] as String;
    
    // Update read status in cached messages
    for (final chatId in _chatMessages.keys) {
      final messages = _chatMessages[chatId] ?? [];
      for (int i = 0; i < messages.length; i++) {
        if (messages[i].id == messageId) {
          final updatedMessage = Message(
            id: messages[i].id,
            chat: messages[i].chat,
            sender: messages[i].sender,
            text: messages[i].text,
            readBy: [...messages[i].readBy, readBy],
            createdAt: messages[i].createdAt,
            updatedAt: messages[i].updatedAt,
          );
          messages[i] = updatedMessage;
          
          if (_currentChatId == chatId) {
            emit(ChatMessagesLoaded(
              chatId: chatId,
              messages: messages,
              pagination: MessagesPagination(total: 0, page: 1, limit: 20, pages: 1),
            ));
          }
          break;
        }
      }
    }
  }

  void _handleUserJoined(Map<String, dynamic> data, Emitter<ChatState> emit) {
    // Handle user joining chat
    print('User joined: ${data['userId']} in chat ${data['chatId']}');
  }

  void _handleUserLeft(Map<String, dynamic> data, Emitter<ChatState> emit) {
    // Handle user leaving chat
    print('User left: ${data['userId']} from chat ${data['chatId']}');
  }

  void _handleChatUpdated(Map<String, dynamic> data, Emitter<ChatState> emit) {
    // Handle chat updates (name, avatar, etc.)
    add(ChatEventRefreshChats());
  }

  Future<void> _onLoadChats(
    ChatEventLoadChats event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoadingChats());
    try {
      final chats = await _chatRepository.getChats();
      _chats = chats;
      emit(ChatChatsLoaded(chats: chats));
    } catch (e) {
      emit(ChatLoadChatsError(message: e.toString()));
    }
  }

  Future<void> _onCreatePrivateChat(
    ChatEventCreatePrivateChat event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatCreatingChat());
    try {
      final chat = await _chatRepository.createPrivateChat(event.friendId);
      _chats.insert(0, chat); // Add to beginning of list
      emit(ChatPrivateChatCreated(chat: chat));
      emit(ChatChatsLoaded(chats: _chats));
    } catch (e) {
      emit(ChatCreateChatError(message: e.toString()));
    }
  }

  Future<void> _onCreateGroupChat(
    ChatEventCreateGroupChat event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatCreatingChat());
    try {
      final chat = await _chatRepository.createGroupChat(
        name: event.name,
        description: event.description,
        admin: event.admin,
        participants: event.participants,
        avatar: event.avatar,
      );
      _chats.insert(0, chat); // Add to beginning of list
      emit(ChatGroupChatCreated(chat: chat));
      emit(ChatChatsLoaded(chats: _chats));
    } catch (e) {
      emit(ChatCreateChatError(message: e.toString()));
    }
  }

  Future<void> _onAddMembersToGroup(
    ChatEventAddMembersToGroup event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    try {
      await _chatRepository.addMembersToGroup(
        chatId: event.chatId,
        members: event.members,
      );
      emit(ChatMembersAdded(chatId: event.chatId));
      // Refresh chats to get updated data
      add(ChatEventLoadChats());
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> _onRemoveMembersFromGroup(
    ChatEventRemoveMembersFromGroup event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    try {
      await _chatRepository.removeMembersFromGroup(
        chatId: event.chatId,
        members: event.members,
      );
      emit(ChatMembersRemoved(chatId: event.chatId));
      // Refresh chats to get updated data
      add(ChatEventLoadChats());
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> _onLoadMessages(
    ChatEventLoadMessages event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoadingMessages());
    _currentChatId = event.chatId;
    
    // Join the chat room via WebSocket
    _webSocketService.joinChat(event.chatId);
    
    try {
      final messagesResponse = await _chatRepository.getMessages(
        chatId: event.chatId,
        page: event.page,
        limit: event.limit,
      );
      
      // Update local cache
      if (event.page == 1) {
        _chatMessages[event.chatId] = messagesResponse.messages;
      } else {
        // Append to existing messages for pagination
        final existingMessages = _chatMessages[event.chatId] ?? [];
        _chatMessages[event.chatId] = [...existingMessages, ...messagesResponse.messages];
      }

      emit(ChatMessagesLoaded(
        chatId: event.chatId,
        messages: _chatMessages[event.chatId] ?? [],
        pagination: messagesResponse.pagination,
      ));
    } catch (e) {
      emit(ChatLoadMessagesError(message: e.toString()));
    }
  }

  Future<void> _onSendMessage(
    ChatEventSendMessage event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatSendingMessage());
    
    // Try sending via WebSocket first for real-time delivery
    final sentViaWebSocket = await _webSocketService.sendMessage(event.chatId, event.content);
    
    if (sentViaWebSocket) {
      // Message sent via WebSocket - the backend will handle saving and broadcasting
      // We'll receive the message back via WebSocket event, so no need to add to cache here
      print('Message sent via WebSocket, waiting for confirmation...');
      
      // Don't emit ChatMessageSent yet - wait for WebSocket confirmation
      // The _handleNewMessage will handle the response
    } else {
      // WebSocket failed, fallback to HTTP API
      print('WebSocket failed, using HTTP fallback...');
      try {
        final message = await _chatRepository.sendMessage(
          chatId: event.chatId,
          content: event.content,
        );
        
        // Add message to local cache
        final existingMessages = _chatMessages[event.chatId] ?? [];
        _chatMessages[event.chatId] = [message, ...existingMessages];
        
        emit(ChatMessageSent(message: message));
        
        // Update the messages view
        emit(ChatMessagesLoaded(
          chatId: event.chatId,
          messages: _chatMessages[event.chatId] ?? [],
          pagination: MessagesPagination(total: 0, page: 1, limit: 20, pages: 1),
        ));
        
        // Refresh chats to update latest message
        add(ChatEventLoadChats());
      } catch (e) {
        emit(ChatSendMessageError(message: e.toString()));
      }
    }
  }

  Future<void> _onMarkMessageAsRead(
    ChatEventMarkMessageAsRead event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _chatRepository.markMessageAsRead(event.messageId);
      
      // Also send via WebSocket for real-time updates
      _webSocketService.markAsRead(event.messageId, chatId: event.chatId);
      
      emit(ChatMessageMarkedAsRead(messageId: event.messageId));
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> _onLoadUnreadCount(
    ChatEventLoadUnreadCount event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final count = await _chatRepository.getUnreadCount();
      emit(ChatUnreadCountLoaded(count: count));
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> _onSelectChat(
    ChatEventSelectChat event,
    Emitter<ChatState> emit,
  ) async {
    _currentChatId = event.chatId;
    _webSocketService.joinChat(event.chatId);
    emit(ChatSelected(chatId: event.chatId));
  }

  Future<void> _onClearSelectedChat(
    ChatEventClearSelectedChat event,
    Emitter<ChatState> emit,
  ) async {
    if (_currentChatId != null) {
      _webSocketService.leaveChat(_currentChatId!);
    }
    _currentChatId = null;
    emit(ChatInitial());
  }

  Future<void> _onRefreshChats(
    ChatEventRefreshChats event,
    Emitter<ChatState> emit,
  ) async {
    add(ChatEventLoadChats());
  }

  // Helper methods
  List<Chat> get chats => _chats;
  
  List<Message> getMessagesForChat(String chatId) {
    return _chatMessages[chatId] ?? [];
  }

  @override
  Future<void> close() {
    _webSocketSubscription?.cancel();
    _webSocketService.dispose();
    return super.close();
  }
} 