import 'dart:io';
import '../../../config/api_client.dart';
import 'models/chat.dart';
import 'models/message.dart';

class ChatRepository {
  final ApiClient _apiClient = ApiClient();

  // Helper method to process backend response
  dynamic _processResponse(dynamic response) {
    if (response['success'] == true) {
      return response['data'];
    } else {
      throw Exception(response['message'] ?? 'Request failed');
    }
  }

  // Get all chats
  Future<List<Chat>> getChats() async {
    try {
      final response = await _apiClient.get('/chat');
      final data = _processResponse(response);
      final List<dynamic> chatData = data;
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
      final data = _processResponse(response);
      return Chat.fromJson(data);
    } catch (e) {
      throw Exception('Failed to create private chat: $e');
    }
  }

  // Create group chat
  Future<Chat> createGroupChat({
    required String name,
    String? description,
    required String admin,
    required List<String> participants,
    File? avatar,
  }) async {
    try {
      // Ensure participants list is not empty
      if (participants.isEmpty) {
        throw Exception('At least one participant is required');
      }

      if (avatar != null) {
        // Use multipart for avatar upload
        Map<String, dynamic> data = {
          'name': name,
          'admin': admin,
        };

        if (description != null && description.isNotEmpty) {
          data['description'] = description;
        }

        // Add participants properly for multipart
        for (int i = 0; i < participants.length; i++) {
          data['participants[$i]'] = participants[i];
        }

        List<MapEntry<String, File>> files = [];
        files.add(MapEntry('avatar', avatar));

        final response = await _apiClient.postMultipart('/chat/group', data, files);
        final responseData = _processResponse(response);
        return Chat.fromJson(responseData);
      } else {
        // Regular JSON post without avatar
        Map<String, dynamic> data = {
          'name': name,
          'admin': admin,
          'participants': participants, // Send as array for JSON
        };

        if (description != null && description.isNotEmpty) {
          data['description'] = description;
        }

        print('🔹 Creating group chat with data: $data');
        final response = await _apiClient.post('/chat/group', data);
        final responseData = _processResponse(response);
        return Chat.fromJson(responseData);
      }
    } catch (e) {
      print('❌ Group chat creation error: $e');
      throw Exception('Failed to create group chat: $e');
    }
  }

  // Add members to group chat
  Future<void> addMembersToGroup({
    required String chatId,
    required List<String> members,
  }) async {
    try {
      final response = await _apiClient.post('/chat/group/members/add', {
        'chatId': chatId,
        'members': members,
      });
      _processResponse(response); // Check for success
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
      final response = await _apiClient.post('/chat/group/members/remove', {
        'chatId': chatId,
        'members': members,
      });
      _processResponse(response); // Check for success
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
      final data = _processResponse(response);
      return Message.fromJson(data);
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
      final data = _processResponse(response);
      return MessagesResponse.fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch messages: $e');
    }
  }

  // Mark message as read
  Future<void> markMessageAsRead(String messageId) async {
    try {
      final response = await _apiClient.put('/chat/message/$messageId/read', {});
      _processResponse(response); // Check for success
    } catch (e) {
      throw Exception('Failed to mark message as read: $e');
    }
  }

  // Get unread message count
  Future<Map<String, dynamic>> getUnreadCount() async {
    try {
      final response = await _apiClient.get('/chat/messages/unread/count');
      final data = _processResponse(response);
      return data;
    } catch (e) {
      throw Exception('Failed to fetch unread count: $e');
    }
  }
} 