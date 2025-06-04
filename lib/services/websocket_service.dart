import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/env.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  IO.Socket? _socket;
  StreamController<Map<String, dynamic>>? _messageController;
  bool _isConnected = false;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int maxReconnectAttempts = 5;

  Stream<Map<String, dynamic>> get messageStream => 
      _messageController?.stream ?? const Stream.empty();

  bool get isConnected => _isConnected;

  Future<void> connect() async {
    if (_isConnected && _socket?.connected == true) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        print('No auth token found, cannot connect to Socket.IO');
        return;
      }

      print('Connecting to Socket.IO: ${Env.serverURL}');

      _messageController ??= StreamController<Map<String, dynamic>>.broadcast();

      // Disconnect existing socket if any
      _socket?.disconnect();
      _socket?.dispose();

      // Create Socket.IO connection with authentication
      // For your Express server, Socket.IO is available at the same URL
      _socket = IO.io(Env.serverURL, IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({
            'token': token,
          })
          .build());

      // Connection event handlers
      _socket!.onConnect((_) {
        print('Socket.IO connected successfully');
        _isConnected = true;
        _reconnectAttempts = 0;
        
        // Automatically join user's chats
        print('Emitting join:chats');
        _socket!.emit('join:chats');
        
        _messageController!.add({
          'type': 'connection_established',
        });
      });

      _socket!.onDisconnect((reason) {
        print('Socket.IO disconnected: $reason');
        _isConnected = false;
        if (reason != 'io client disconnect') {
          _attemptReconnect();
        }
      });

      _socket!.onConnectError((error) {
        print('Socket.IO connection error: $error');
        _isConnected = false;
        _attemptReconnect();
      });

      // Debug: Listen to all events (commented out to reduce log noise)
      // _socket!.onAny((event, data) {
      //   print('Socket.IO event received: $event with data: $data');
      // });

      // Chat event handlers
      _socket!.on('message:received', (data) {
        print('Received message: $data');
        _messageController!.add({
          'type': 'message',
          'message': data,
        });
      });

      _socket!.on('message:seen', (data) {
        print('Message seen: $data');
        _messageController!.add({
          'type': 'message_read',
          'messageId': data['messageId'],
          'readBy': data['userId'],
        });
      });

      _socket!.on('chats:joined', (data) {
        print('Joined chats: $data');
        _messageController!.add({
          'type': 'chats_joined',
          'joinedChats': data,
        });
      });

      _socket!.on('users:online', (data) {
        print('Online users: $data');
        _messageController!.add({
          'type': 'users_online',
          'users': data,
        });
      });

      _socket!.on('error', (data) {
        print('Socket.IO error: $data');
        _messageController!.add({
          'type': 'error',
          'message': data['message'] ?? 'Unknown error',
        });
      });

      // Connect the socket
      print('Attempting to connect socket...');
      _socket!.connect();

    } catch (e) {
      print('Error connecting to Socket.IO: $e');
      _isConnected = false;
      _attemptReconnect();
    }
  }

  void _attemptReconnect() {
    if (_reconnectAttempts >= maxReconnectAttempts) {
      print('Max reconnection attempts reached');
      return;
    }

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(
      Duration(seconds: _reconnectAttempts * 2 + 1), // Exponential backoff
      () {
        _reconnectAttempts++;
        print('Attempting to reconnect (attempt $_reconnectAttempts)');
        connect();
      },
    );
  }

  Future<bool> sendMessage(String chatId, String content) async {
    if (_isConnected && _socket != null) {
      print('Sending message via Socket.IO to chat $chatId: $content');
      _socket!.emit('message:send', {
        'chatId': chatId,
        'content': content,
      });
      return true; // Message sent via WebSocket
    } else {
      print('Cannot send message via Socket.IO: not connected');
      return false; // Need to use HTTP fallback
    }
  }

  void joinChat(String chatId) {
    // For Socket.IO backend, joining individual chats isn't needed
    // as we join all chats on connection with 'join:chats'
    print('Joining chat $chatId (handled by join:chats)');
  }

  void leaveChat(String chatId) {
    // Leaving individual chats isn't implemented in the backend
    print('Leaving chat $chatId (not implemented in backend)');
  }

  void markAsRead(String messageId, {String? chatId}) {
    if (_isConnected && _socket != null) {
      final data = <String, dynamic>{
        'messageId': messageId,
      };
      
      // Add chatId if provided (backend might need it)
      if (chatId != null) {
        data['chatId'] = chatId;
      }
      
      print('Marking message as read: $data');
      _socket!.emit('message:read', data);
    }
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _socket?.disconnect();
    _socket?.dispose();
    _messageController?.close();
    _isConnected = false;
    _reconnectAttempts = 0;
  }

  void dispose() {
    disconnect();
    _messageController = null;
  }
} 