import 'dart:io';
import 'package:lacquer/features/result_type.dart';
import 'package:lacquer/services/post_service.dart';

class PostRepository {
  final PostService _postService = PostService();

  Future<Result<Map<String, dynamic>>> getAllPosts() async {
    try {
      final response = await _postService.getAllPosts();
      return Success(response);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<Map<String, dynamic>>> getUserPosts(String userId) async {
    try {
      final response = await _postService.getUserPosts(userId);
      return Success(response);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<Map<String, dynamic>>> getPost(String postId) async {
    try {
      final response = await _postService.getPost(postId);
      return Success(response);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<Map<String, dynamic>>> createPost({
    required String imageUrl,
    String? caption,
    bool isPrivate = false,
    List<String>? visibleToUsers,
  }) async {
    try {
      final response = await _postService.createPost(
        imageUrl: imageUrl,
        caption: caption,
        isPrivate: isPrivate,
        visibleToUsers: visibleToUsers,
      );
      return Success(response);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<Map<String, dynamic>>> createPostWithUpload({
    required File image,
    String? caption,
    bool isPrivate = false,
    List<String>? visibleToUsers,
  }) async {
    try {
      final response = await _postService.createPostWithUpload(
        image: image,
        caption: caption,
        isPrivate: isPrivate,
        visibleToUsers: visibleToUsers,
      );
      return Success(response);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<void>> deletePost(String postId) async {
    try {
      await _postService.deletePost(postId);
      return Success(null);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<Map<String, dynamic>>> makePostPrivate(
    String postId, {
    List<String>? visibleToUsers,
  }) async {
    try {
      final response = await _postService.makePostPrivate(
        postId,
        visibleToUsers: visibleToUsers,
      );
      return Success(response);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<Map<String, dynamic>>> makePostPublic(String postId) async {
    try {
      final response = await _postService.makePostPublic(postId);
      return Success(response);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<Map<String, dynamic>>> addReaction(
    String postId,
    String emoji,
  ) async {
    try {
      final response = await _postService.addReaction(postId, emoji);
      return Success(response);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<Map<String, dynamic>>> updateReaction(
    String postId,
    String emoji,
  ) async {
    try {
      final response = await _postService.updateReaction(postId, emoji);
      return Success(response);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<Map<String, dynamic>>> removeReaction(String postId) async {
    try {
      final response = await _postService.removeReaction(postId);
      return Success(response);
    } catch (e) {
      return Failure(e.toString());
    }
  }
}
