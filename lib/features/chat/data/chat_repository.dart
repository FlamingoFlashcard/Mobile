import 'dart:io';
import '../../../config/api_client.dart';
import 'models/chat.dart';

class ChatRepository {
  final ApiClient _apiClient = ApiClient();

  // Get all chats
  Future<List<Chat>> getChats() async {
    try {
      final response = await _apiClient.get('/chat');
      final List<dynamic> chatData = response['data'];
      return chatData.map((chat) => Chat.fromJson(chat)).toList();
    } catch (e) {
      throw Exception('Failed to fetch chats: $e');
    }
  }

  // Create private chat
  Future<Chat> createPrivateChat(String friendId) async {
    try {
      final response = await _apiClient.post('/chat/private', {
        'friendId': friendId,
      });
      return Chat.fromJson(response['data']);
    } catch (e) {
      throw Exception('Failed to create private chat: $e');
    }
  }

  // Create group chat
  Future<Chat> createGroupChat({
    required String name,
    required String description,
    required String admin,
    required List<String> participants,
    File? avatar,
  }) async {
    try {
      Map<String, dynamic> data = {
        'name': name,
        'description': description,
        'admin': admin,
      };

      // Add participants
      for (int i = 0; i < participants.length; i++) {
        data['participants[$i]'] = participants[i];
      }

      List<MapEntry<String, File>> files = [];
      if (avatar != null) {
        files.add(MapEntry('avatar', avatar));
      }

      final response = await _apiClient.postMultipart('/chat/group', data, files);
      return Chat.fromJson(response['data']);
    } catch (e) {
      throw Exception('Failed to create group chat: $e');
    }
  }

  // Add members to group chat
  Future<void> addMembersToGroup({
    required String chatId,
    required List<String> members,
  }) async {
    try {
      Map<String, dynamic> data = {
        'chatId': chatId,
      };

      // Add members
      for (int i = 0; i < members.length; i++) {
        data['members[$i]'] = members[i];
      }

      await _apiClient.post('/chat/group/members/add', data);
    } catch (e) {
      throw Exception('Failed to add members to group chat: $e');
    }
  }

  // Remove members from group chat
  Future<void> removeMembersFromGroup({
    required String chatId,
    required List<String> members,
  }) async {
    try {
      Map<String, dynamic> data = {
        'chatId': chatId,
      };

      // Add members to remove
      for (int i = 0; i < members.length; i++) {
        data['members[$i]'] = members[i];
      }

      await _apiClient.post('/chat/group/members/remove', data);
    } catch (e) {
      throw Exception('Failed to remove members from group chat: $e');
    }
  }

  // Send message
  Future<Message> sendMessage({
    required String chatId,
    required String content,
  }) async {
    try {
      final response = await _apiClient.post('/chat/message', {
        'chatId': chatId,
        'content': content,
      });
      return Message.fromJson(response['data']);
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // Get messages for a chat
  Future<MessagesResponse> getMessages({
    required String chatId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.get('/chat/$chatId/messages?page=$page&limit=$limit');
      return MessagesResponse.fromJson(response['data']);
    } catch (e) {
      throw Exception('Failed to fetch messages: $e');
    }
  }

  // Mark message as read
  Future<void> markMessageAsRead(String messageId) async {
    try {
      await _apiClient.put('/chat/message/$messageId/read', {});
    } catch (e) {
      throw Exception('Failed to mark message as read: $e');
    }
  }

  // Get unread message count (placeholder)
  Future<int> getUnreadCount() async {
    try {
      final response = await _apiClient.get('/chat/messages/unread/count');
      return response['data']['count'] ?? 0;
    } catch (e) {
      // Return 0 as placeholder since endpoint is not working
      return 0;
    }
  }
} 