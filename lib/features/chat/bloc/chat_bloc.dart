import 'package:flutter_bloc/flutter_bloc.dart';
import '../websocket_chat.dart';
import '../data/chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final WebSocketChat _webSocketChat = WebSocketChat.getInstance();
  final ChatRepository _chatRepository = ChatRepository();

  ChatBloc() : super(ChatInitial()) {
    // WebSocket events
    on<ChatEventConnectWebSocket>(_onConnectWebSocket);
    on<ChatEventDisconnectWebSocket>(_onDisconnectWebSocket);
    
    // Chat management events
    on<ChatEventLoadChats>(_onLoadChats);
    on<ChatEventLoadMessages>(_onLoadMessages);
    on<ChatEventCreatePrivateChat>(_onCreatePrivateChat);
    on<ChatEventCreateGroupChat>(_onCreateGroupChat);
    on<ChatEventRefreshChats>(_onRefreshChats);
    on<ChatEventLoadUnreadCount>(_onLoadUnreadCount);
    
    // Message events
    on<ChatEventSendMessage>(_onSendMessage);
    on<ChatEventWebSocketMessage>(_onWebSocketMessage);
    on<ChatEventMarkMessageAsRead>(_onMarkMessageAsRead);
    
    // Typing events
    on<ChatEventStartTyping>(_onStartTyping);
    on<ChatEventStopTyping>(_onStopTyping);
    on<ChatEventUserTyping>(_onUserTyping);
    on<ChatEventUserStoppedTyping>(_onUserStoppedTyping);
    
    // Online users events
    on<ChatEventOnlineUsersUpdated>(_onOnlineUsersUpdated);
    
    // Message seen events
    on<ChatEventMessageSeen>(_onMessageSeen);
    
    // Notification events
    on<ChatEventNewMessageNotification>(_onNewMessageNotification);
    
    // Error events
    on<ChatEventWebSocketError>(_onWebSocketError);
    
    // Chats joined event
    on<ChatEventChatsJoined>(_onChatsJoined);
    
    // Chat selection events
    on<ChatEventSelectChat>(_onSelectChat);
    on<ChatEventClearSelectedChat>(_onClearSelectedChat);

    _setupWebSocketCallbacks();
  }

  void _setupWebSocketCallbacks() {
    // Set up WebSocket event callbacks
    _webSocketChat.setOnMessageReceived((message) {
      add(ChatEventWebSocketMessage(message: message));
    });

    _webSocketChat.setOnOnlineUsersUpdated((onlineUsers) {
      add(ChatEventOnlineUsersUpdated(onlineUsers: onlineUsers));
    });

    _webSocketChat.setOnUserTyping((chatId, userId, username) {
      add(ChatEventUserTyping(
        chatId: chatId,
        userId: userId,
        username: username,
      ));
    });

    _webSocketChat.setOnUserStoppedTyping((chatId, userId) {
      add(ChatEventUserStoppedTyping(
        chatId: chatId,
        userId: userId,
      ));
    });

    _webSocketChat.setOnMessageSeen((chatId, messageId, userId) {
      add(ChatEventMessageSeen(
        chatId: chatId,
        messageId: messageId,
        userId: userId,
      ));
    });

    _webSocketChat.setOnNewMessageNotification((chatId, message) {
      add(ChatEventNewMessageNotification(
        chatId: chatId,
        message: message,
      ));
    });

    _webSocketChat.setOnError((message) {
      add(ChatEventWebSocketError(message: message));
    });

    _webSocketChat.setOnChatsJoined((chatIds) {
      add(ChatEventChatsJoined(chatIds: chatIds));
    });
  }

  Future<void> _onConnectWebSocket(
    ChatEventConnectWebSocket event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatWebSocketConnecting());
    try {
      await _webSocketChat.connect();
      emit(ChatWebSocketConnected());
    } catch (e) {
      emit(ChatWebSocketError(message: e.toString()));
    }
  }

  Future<void> _onDisconnectWebSocket(
    ChatEventDisconnectWebSocket event,
    Emitter<ChatState> emit,
  ) async {
    await _webSocketChat.disconnect();
    emit(ChatWebSocketDisconnected());
  }

  Future<void> _onSendMessage(
    ChatEventSendMessage event,
    Emitter<ChatState> emit,
  ) async {
    print('🔹 ChatBloc: Sending message to chat ${event.chatId}: "${event.content}"');
    emit(ChatSendingMessage());
    try {
      // Send via WebSocket for real-time delivery
      print('🔹 ChatBloc: Sending via WebSocket...');
      await _webSocketChat.sendMessage(event.chatId, event.content);
      
      // Note: The message confirmation will come through WebSocket via ChatEventWebSocketMessage
      // Don't emit ChatMessageSent here to avoid duplicates
      print('🔹 ChatBloc: Message sent via WebSocket successfully');
      
      // Emit initial state to clear the sending state
      // The actual message will be received via WebSocket callback
      if (state is ChatSendingMessage) {
        // Don't emit anything here - wait for WebSocket response
      }
    } catch (e) {
      print('❌ ChatBloc: WebSocket message send failed: $e');
      
      // If WebSocket fails, try HTTP API as fallback
      try {
        print('🔹 ChatBloc: Trying HTTP API as fallback...');
        final message = await _chatRepository.sendMessage(
          chatId: event.chatId,
          content: event.content,
        );
        print('🔹 ChatBloc: HTTP API fallback successful: ${message.id}');
        emit(ChatMessageSent(message: message));
      } catch (httpError) {
        print('❌ ChatBloc: HTTP API fallback also failed: $httpError');
        emit(ChatSendMessageError(message: httpError.toString()));
      }
    }
  }

  void _onWebSocketMessage(
    ChatEventWebSocketMessage event,
    Emitter<ChatState> emit,
  ) {
    // Clear sending state and emit the received message
    emit(ChatMessageReceived(message: event.message));
  }

  Future<void> _onMarkMessageAsRead(
    ChatEventMarkMessageAsRead event,
    Emitter<ChatState> emit,
  ) async {
    try {
      // Mark as read via WebSocket
      await _webSocketChat.markMessageAsRead(event.chatId, event.messageId);
      
      // Also mark via HTTP API for persistence
      try {
        await _chatRepository.markMessageAsRead(event.messageId);
      } catch (e) {
        print('HTTP mark as read failed: $e');
      }
      
      emit(ChatMessageMarkedAsRead(messageId: event.messageId));
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> _onStartTyping(
    ChatEventStartTyping event,
    Emitter<ChatState> emit,
  ) async {
    await _webSocketChat.startTyping(event.chatId);
    emit(ChatTypingStarted(chatId: event.chatId));
  }

  Future<void> _onStopTyping(
    ChatEventStopTyping event,
    Emitter<ChatState> emit,
  ) async {
    await _webSocketChat.stopTyping(event.chatId);
    emit(ChatTypingStopped(chatId: event.chatId));
  }

  void _onUserTyping(
    ChatEventUserTyping event,
    Emitter<ChatState> emit,
  ) {
    emit(ChatUserTyping(
      chatId: event.chatId,
      userId: event.userId,
      username: event.username,
    ));
  }

  void _onUserStoppedTyping(
    ChatEventUserStoppedTyping event,
    Emitter<ChatState> emit,
  ) {
    emit(ChatUserStoppedTyping(
      chatId: event.chatId,
      userId: event.userId,
    ));
  }

  void _onOnlineUsersUpdated(
    ChatEventOnlineUsersUpdated event,
    Emitter<ChatState> emit,
  ) {
    emit(ChatOnlineUsersUpdated(onlineUsers: event.onlineUsers));
  }

  void _onMessageSeen(
    ChatEventMessageSeen event,
    Emitter<ChatState> emit,
  ) {
    emit(ChatMessageSeen(
      chatId: event.chatId,
      messageId: event.messageId,
      userId: event.userId,
    ));
  }

  void _onNewMessageNotification(
    ChatEventNewMessageNotification event,
    Emitter<ChatState> emit,
  ) {
    emit(ChatNewMessageNotification(
      chatId: event.chatId,
      message: event.message,
    ));
  }

  void _onWebSocketError(
    ChatEventWebSocketError event,
    Emitter<ChatState> emit,
  ) {
    emit(ChatWebSocketError(message: event.message));
  }

  void _onChatsJoined(
    ChatEventChatsJoined event,
    Emitter<ChatState> emit,
  ) {
    emit(ChatChatsJoined(chatIds: event.chatIds));
  }

  void _onSelectChat(
    ChatEventSelectChat event,
    Emitter<ChatState> emit,
  ) {
    emit(ChatSelected(chatId: event.chatId));
  }

  void _onClearSelectedChat(
    ChatEventClearSelectedChat event,
    Emitter<ChatState> emit,
  ) {
    emit(ChatInitial());
  }

  // Updated event handlers using real repository
  Future<void> _onLoadChats(
    ChatEventLoadChats event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoadingChats());
    try {
      final chats = await _chatRepository.getChats();
      emit(ChatChatsLoaded(chats: chats));
    } catch (e) {
      emit(ChatLoadChatsError(message: e.toString()));
    }
  }

  Future<void> _onLoadMessages(
    ChatEventLoadMessages event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoadingMessages());
    try {
      final messagesResponse = await _chatRepository.getMessages(
        chatId: event.chatId,
        page: event.page,
        limit: event.limit,
      );
      emit(ChatMessagesLoaded(
        chatId: event.chatId, 
        messages: messagesResponse.messages, 
        pagination: messagesResponse.pagination,
      ));
    } catch (e) {
      emit(ChatLoadMessagesError(message: e.toString()));
    }
  }

  Future<void> _onCreatePrivateChat(
    ChatEventCreatePrivateChat event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatCreatingChat());
    try {
      final chat = await _chatRepository.createPrivateChat(event.friendId);
      emit(ChatPrivateChatCreated(chat: chat));
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
      emit(ChatGroupChatCreated(chat: chat));
    } catch (e) {
      emit(ChatCreateChatError(message: e.toString()));
    }
  }

  Future<void> _onRefreshChats(
    ChatEventRefreshChats event,
    Emitter<ChatState> emit,
  ) async {
    // Refresh chats by reloading them
    add(ChatEventLoadChats());
  }

  Future<void> _onLoadUnreadCount(
    ChatEventLoadUnreadCount event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final unreadData = await _chatRepository.getUnreadCount();
      final totalUnread = unreadData['total'] ?? 0;
      emit(ChatUnreadCountLoaded(count: totalUnread));
    } catch (e) {
      // Don't emit error for unread count, just log it
      print('Failed to load unread count: $e');
    }
  }

  @override
  Future<void> close() {
    _webSocketChat.disconnect();
    return super.close();
  }
} 