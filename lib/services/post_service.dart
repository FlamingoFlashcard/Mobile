import 'dart:io';
import 'dart:convert';
import 'package:lacquer/config/api_client.dart';

class PostService {
  final ApiClient _apiClient = ApiClient();

  static final PostService _instance = PostService._internal();
  factory PostService() => _instance;
  PostService._internal();

  // Get all posts (me and friends)
  Future<Map<String, dynamic>> getAllPosts() async {
    try {
      return await _apiClient.get('/post/');
    } catch (e) {
      print('Get all posts error: $e');
      rethrow;
    }
  }

  // Get user posts
  Future<Map<String, dynamic>> getUserPosts(String userId) async {
    try {
      return await _apiClient.get('/post/user/$userId');
    } catch (e) {
      print('Get user posts error: $e');
      rethrow;
    }
  }

  // Get single post
  Future<Map<String, dynamic>> getPost(String postId) async {
    try {
      return await _apiClient.get('/post/$postId');
    } catch (e) {
      print('Get post error: $e');
      rethrow;
    }
  }

  // Create post with URL
  Future<Map<String, dynamic>> createPost({
    required String imageUrl,
    String? caption,
    bool isPrivate = false,
    List<String>? visibleToUsers,
  }) async {
    try {
      final data = {'imageUrl': imageUrl, 'isPrivate': isPrivate};

      if (caption != null && caption.isNotEmpty) {
        data['caption'] = caption;
      }

      if (isPrivate && visibleToUsers != null) {
        data['visibleToUsers'] = jsonEncode(visibleToUsers);
      }

      return await _apiClient.post('/post/', data);
    } catch (e) {
      print('Create post error: $e');
      rethrow;
    }
  }

  // Create post with image upload
  Future<Map<String, dynamic>> createPostWithUpload({
    required File image,
    String? caption,
    bool isPrivate = false,
    List<String>? visibleToUsers,
  }) async {
    try {
      // Validate file exists
      if (!await image.exists()) {
        throw Exception('Image file does not exist');
      }

      final fileSize = await image.length();
      if (fileSize == 0) {
        throw Exception('Image file is empty');
      }

      final data = <String, String>{'isPrivate': isPrivate.toString()};

      if (caption != null && caption.isNotEmpty) {
        data['caption'] = caption;
      }

      if (isPrivate && visibleToUsers != null) {
        data['visibleToUsers'] = jsonEncode(visibleToUsers);
      }

      final files = [MapEntry('image', image)];
      return await _apiClient.postMultipart('/post/upload', data, files);
    } catch (e) {
      print('Create post with upload error: $e');
      rethrow;
    }
  }

  // Delete post
  Future<Map<String, dynamic>> deletePost(String postId) async {
    try {
      return await _apiClient.delete('/post/$postId');
    } catch (e) {
      print('Delete post error: $e');
      rethrow;
    }
  }

  // Make post private
  Future<Map<String, dynamic>> makePostPrivate(
    String postId, {
    List<String>? visibleToUsers,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (visibleToUsers != null) {
        data['visibleToUsers'] = jsonEncode(visibleToUsers);
      }
      return await _apiClient.patch('/post/$postId/private', data);
    } catch (e) {
      print('Make post private error: $e');
      rethrow;
    }
  }

  // Make post public
  Future<Map<String, dynamic>> makePostPublic(String postId) async {
    try {
      return await _apiClient.patch('/post/$postId/public', {});
    } catch (e) {
      print('Make post public error: $e');
      rethrow;
    }
  }

  // Add reaction
  Future<Map<String, dynamic>> addReaction(String postId, String emoji) async {
    try {
      return await _apiClient.post('/post/$postId/reaction', {'emoji': emoji});
    } catch (e) {
      print('Add reaction error: $e');
      rethrow;
    }
  }

  // Update reaction
  Future<Map<String, dynamic>> updateReaction(
    String postId,
    String emoji,
  ) async {
    try {
      return await _apiClient.patch('/post/$postId/reaction', {'emoji': emoji});
    } catch (e) {
      print('Update reaction error: $e');
      rethrow;
    }
  }

  // Remove reaction
  Future<Map<String, dynamic>> removeReaction(String postId) async {
    try {
      return await _apiClient.delete('/post/$postId/reaction');
    } catch (e) {
      print('Remove reaction error: $e');
      rethrow;
    }
  }

  // Download image
  Future<List<int>> downloadImage(String postId) async {
    try {
      // This would need special handling for binary data
      // For now, we'll throw an error as it needs different implementation
      throw UnimplementedError('Image download needs special binary handling');
    } catch (e) {
      print('Download image error: $e');
      rethrow;
    }
  }
}
