import 'package:lacquer/config/env.dart';
import 'package:lacquer/features/auth/data/auth_local_data_source.dart';
import 'package:lacquer/features/chat/data/models/message_request.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class WebSocketChat {
  static WebSocketChat? _instance;
  io.Socket? _socket;
  bool _isConnected = false;

  WebSocketChat._();

  static WebSocketChat getInstance() {
    _instance ??= WebSocketChat._();
    return _instance!;
  }

  Future<void> connect() async {
    if (_isConnected) return;

    final authLocalDataSource = AuthLocalDataSource(await SharedPreferences.getInstance());
    final token = await authLocalDataSource.getToken();

    _socket = io.io(
      Env.serverURL,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .enableAutoConnect()
          .enableReconnection()
          .build(),
    );

    _socket?.onConnect((_) {
      print('Connected to WebSocket server');
      _isConnected = true;
    });

    _socket?.onDisconnect((_) {
      print('Disconnected from WebSocket server');
      _isConnected = false;
    });

    _socket?.onError((error) {
      print('WebSocket error: $error');
      _isConnected = false;
    });

    _socket?.onConnectError((error) {
      print('Connection error: $error');
      _isConnected = false;
    });

    _socket?.connect();
  }

  Future<void> reconnect() async {
    if (!_isConnected) {
      print('Attempting to reconnect...');
      _socket?.connect();
    }
  }

  Future<void> sendMessage(MessageRequest message) async {
    _socket?.emit('message:send', message.toJson());
  }

  Future<void> joinChat(String chatId) async {
    _socket?.emit('join:chats', chatId);
  }

  Future<void> disconnect() async {
    _isConnected = false;
    _socket?.disconnect();
  }
}