import 'package:lacquer/config/env.dart';
import 'package:lacquer/features/auth/data/auth_local_data_source.dart';
import 'package:lacquer/features/chat/data/models/message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class WebSocketChat {
  static WebSocketChat? _instance;
  io.Socket? _socket;
  bool _isConnected = false;
  bool _listenersSetup = false;

  // Callbacks for different events
  Function(Message)? _onMessageReceived;
  Function(List<String>)? _onOnlineUsersUpdated;
  Function(String chatId, String userId, String username)? _onUserTyping;
  Function(String chatId, String userId)? _onUserStoppedTyping;
  Function(String chatId, String messageId, String userId)? _onMessageSeen;
  Function(String chatId, Message message)? _onNewMessageNotification;
  Function(String message)? _onError;
  Function(List<String> chatIds)? _onChatsJoined;

  WebSocketChat._();

  static WebSocketChat getInstance() {
    _instance ??= WebSocketChat._();
    return _instance!;
  }

  Future<void> connect() async {
    if (_isConnected) return;

    final authLocalDataSource = AuthLocalDataSource(await SharedPreferences.getInstance());
    final token = await authLocalDataSource.getToken();

    if (token == null) {
      print('No authentication token found');
      return;
    }

    _socket = io.io(
      Env.serverURL,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token}) // Use auth instead of headers for socket.io
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(1000)
          .build(),
    );

    _socket?.onConnect((_) {
      print('Connected to WebSocket server');
      _isConnected = true;
      _setupEventListeners();
      // Auto-join user's chats on connection
      joinUserChats();
    });

    _socket?.onDisconnect((_) {
      print('Disconnected from WebSocket server');
      _isConnected = false;
    });

    _socket?.onError((error) {
      print('WebSocket error: $error');
      _isConnected = false;
      _onError?.call(error.toString());
    });

    _socket?.onConnectError((error) {
      print('Connection error: $error');
      _isConnected = false;
      _onError?.call(error.toString());
    });

    _socket?.connect();
  }

  void _setupEventListeners() {
    if (_listenersSetup) return;

    // Message received
    _socket?.on('message:received', (data) {
      try {
        final message = Message.fromJson(data);
        _onMessageReceived?.call(message);
      } catch (e) {
        print('Error parsing received message: $e');
      }
    });

    // Online users updated
    _socket?.on('users:online', (data) {
      try {
        final onlineUsers = List<String>.from(data);
        _onOnlineUsersUpdated?.call(onlineUsers);
      } catch (e) {
        print('Error parsing online users: $e');
      }
    });

    // User typing
    _socket?.on('user:typing', (data) {
      try {
        final chatId = data['chatId'];
        final userId = data['userId'];
        final username = data['username'];
        _onUserTyping?.call(chatId, userId, username);
      } catch (e) {
        print('Error parsing typing event: $e');
      }
    });

    // User stopped typing
    _socket?.on('user:stopped_typing', (data) {
      try {
        final chatId = data['chatId'];
        final userId = data['userId'];
        _onUserStoppedTyping?.call(chatId, userId);
      } catch (e) {
        print('Error parsing stopped typing event: $e');
      }
    });

    // Message seen
    _socket?.on('message:seen', (data) {
      try {
        final chatId = data['chatId'];
        final messageId = data['messageId'];
        final userId = data['userId'];
        _onMessageSeen?.call(chatId, messageId, userId);
      } catch (e) {
        print('Error parsing message seen event: $e');
      }
    });

    // New message notification
    _socket?.on('notification:new_message', (data) {
      try {
        final chatId = data['chatId'];
        final message = Message.fromJson(data['message']);
        _onNewMessageNotification?.call(chatId, message);
      } catch (e) {
        print('Error parsing new message notification: $e');
      }
    });

    // Chats joined
    _socket?.on('chats:joined', (data) {
      try {
        final chatIds = List<String>.from(data);
        _onChatsJoined?.call(chatIds);
        print('Successfully joined ${chatIds.length} chat rooms');
      } catch (e) {
        print('Error parsing chats joined event: $e');
      }
    });

    // Error handling
    _socket?.on('error', (data) {
      try {
        final errorMessage = data['message'] ?? 'Unknown error';
        _onError?.call(errorMessage);
      } catch (e) {
        print('Error parsing error event: $e');
      }
    });

    _listenersSetup = true;
  }

  // Set callback functions
  void setOnMessageReceived(Function(Message) callback) {
    _onMessageReceived = callback;
  }

  void setOnOnlineUsersUpdated(Function(List<String>) callback) {
    _onOnlineUsersUpdated = callback;
  }

  void setOnUserTyping(Function(String chatId, String userId, String username) callback) {
    _onUserTyping = callback;
  }

  void setOnUserStoppedTyping(Function(String chatId, String userId) callback) {
    _onUserStoppedTyping = callback;
  }

  void setOnMessageSeen(Function(String chatId, String messageId, String userId) callback) {
    _onMessageSeen = callback;
  }

  void setOnNewMessageNotification(Function(String chatId, Message message) callback) {
    _onNewMessageNotification = callback;
  }

  void setOnError(Function(String message) callback) {
    _onError = callback;
  }

  void setOnChatsJoined(Function(List<String> chatIds) callback) {
    _onChatsJoined = callback;
  }

  Future<void> reconnect() async {
    if (!_isConnected) {
      print('Attempting to reconnect...');
      _socket?.connect();
    }
  }

  // Join user's chats (called automatically on connect)
  Future<void> joinUserChats() async {
    if (_isConnected) {
      _socket?.emit('join:chats');
    }
  }

  // Send message
  Future<void> sendMessage(String chatId, String content) async {
    if (_isConnected) {
      _socket?.emit('message:send', {
        'chatId': chatId,
        'content': content,
      });
    } else {
      print('WebSocket not connected. Cannot send message.');
    }
  }

  // Start typing indicator
  Future<void> startTyping(String chatId) async {
    if (_isConnected) {
      _socket?.emit('typing:start', chatId);
    }
  }

  // Stop typing indicator
  Future<void> stopTyping(String chatId) async {
    if (_isConnected) {
      _socket?.emit('typing:stop', chatId);
    }
  }

  // Mark message as read
  Future<void> markMessageAsRead(String chatId, String messageId) async {
    if (_isConnected) {
      _socket?.emit('message:read', {
        'chatId': chatId,
        'messageId': messageId,
      });
    }
  }

  // Join specific chat room
  Future<void> joinChat(String chatId) async {
    // This method is kept for backward compatibility
    // The backend automatically joins all user chats on 'join:chats' event
    print('Auto-joining chats is handled by joinUserChats()');
  }

  Future<void> disconnect() async {
    _isConnected = false;
    _listenersSetup = false;
    _socket?.disconnect();
    
    // Clear callbacks
    _onMessageReceived = null;
    _onOnlineUsersUpdated = null;
    _onUserTyping = null;
    _onUserStoppedTyping = null;
    _onMessageSeen = null;
    _onNewMessageNotification = null;
    _onError = null;
    _onChatsJoined = null;
  }

  // Utility methods
  bool get isConnected => _isConnected;

  // Legacy method for backward compatibility
  @Deprecated('Use setOnMessageReceived instead. This method will be removed in a future version.')
  Future<void> getMessage(String chatId, {Function(Message)? onMessageReceived}) async {
    if (onMessageReceived != null) {
      setOnMessageReceived(onMessageReceived);
    }
  }

  // Legacy method for backward compatibility  
  @Deprecated('Use setOnMessageReceived instead. This method will be removed in a future version.')
  void setMessageListener(Function(Message) onMessageReceived) {
    setOnMessageReceived(onMessageReceived);
  }
}