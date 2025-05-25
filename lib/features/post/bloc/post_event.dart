import 'dart:io';

sealed class PostEvent {}

class PostEventStarted extends PostEvent {}

class PostEventGetAllPosts extends PostEvent {}

class PostEventGetUserPosts extends PostEvent {
  final String userId;

  PostEventGetUserPosts({required this.userId});
}

class PostEventGetPost extends PostEvent {
  final String postId;

  PostEventGetPost({required this.postId});
}

class PostEventCreatePost extends PostEvent {
  final String imageUrl;
  final String? caption;
  final bool isPrivate;
  final List<String>? visibleToUsers;

  PostEventCreatePost({
    required this.imageUrl,
    this.caption,
    this.isPrivate = false,
    this.visibleToUsers,
  });
}

class PostEventCreatePostWithUpload extends PostEvent {
  final File image;
  final String? caption;
  final bool isPrivate;
  final List<String>? visibleToUsers;

  PostEventCreatePostWithUpload({
    required this.image,
    this.caption,
    this.isPrivate = false,
    this.visibleToUsers,
  });
}

class PostEventDeletePost extends PostEvent {
  final String postId;

  PostEventDeletePost({required this.postId});
}

class PostEventMakePostPrivate extends PostEvent {
  final String postId;
  final List<String>? visibleToUsers;

  PostEventMakePostPrivate({required this.postId, this.visibleToUsers});
}

class PostEventMakePostPublic extends PostEvent {
  final String postId;

  PostEventMakePostPublic({required this.postId});
}

class PostEventAddReaction extends PostEvent {
  final String postId;
  final String emoji;

  PostEventAddReaction({required this.postId, required this.emoji});
}

class PostEventUpdateReaction extends PostEvent {
  final String postId;
  final String emoji;

  PostEventUpdateReaction({required this.postId, required this.emoji});
}

class PostEventRemoveReaction extends PostEvent {
  final String postId;

  PostEventRemoveReaction({required this.postId});
}
