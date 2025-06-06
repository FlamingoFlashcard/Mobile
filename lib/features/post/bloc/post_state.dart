sealed class PostState {}

class PostInitial extends PostState {}

// GET ALL POSTS
class PostGetAllPostsInProgress extends PostState {}

class PostGetAllPostsSuccess extends PostState {
  final List<dynamic> posts;
  final int count;

  PostGetAllPostsSuccess({required this.posts, required this.count});
}

class PostGetAllPostsFailure extends PostState {
  final String message;

  PostGetAllPostsFailure(this.message);
}

// GET USER POSTS
class PostGetUserPostsInProgress extends PostState {}

class PostGetUserPostsSuccess extends PostState {
  final List<dynamic> posts;
  final Map<String, dynamic> user;

  PostGetUserPostsSuccess({required this.posts, required this.user});
}

class PostGetUserPostsFailure extends PostState {
  final String message;

  PostGetUserPostsFailure(this.message);
}

// GET SINGLE POST
class PostGetPostInProgress extends PostState {}

class PostGetPostSuccess extends PostState {
  final Map<String, dynamic> post;

  PostGetPostSuccess(this.post);
}

class PostGetPostFailure extends PostState {
  final String message;

  PostGetPostFailure(this.message);
}

// CREATE POST
class PostCreatePostInProgress extends PostState {}

class PostCreatePostSuccess extends PostState {
  final Map<String, dynamic> post;

  PostCreatePostSuccess(this.post);
}

class PostCreatePostFailure extends PostState {
  final String message;

  PostCreatePostFailure(this.message);
}

// CREATE POST WITH UPLOAD
class PostCreatePostWithUploadInProgress extends PostState {}

class PostCreatePostWithUploadSuccess extends PostState {
  final Map<String, dynamic> post;
  final Map<String, dynamic> uploadInfo;

  PostCreatePostWithUploadSuccess({
    required this.post,
    required this.uploadInfo,
  });
}

class PostCreatePostWithUploadFailure extends PostState {
  final String message;

  PostCreatePostWithUploadFailure(this.message);
}

// DELETE POST
class PostDeletePostInProgress extends PostState {}

class PostDeletePostSuccess extends PostState {}

class PostDeletePostFailure extends PostState {
  final String message;

  PostDeletePostFailure(this.message);
}

// MAKE POST PRIVATE
class PostMakePostPrivateInProgress extends PostState {}

class PostMakePostPrivateSuccess extends PostState {
  final Map<String, dynamic> post;

  PostMakePostPrivateSuccess(this.post);
}

class PostMakePostPrivateFailure extends PostState {
  final String message;

  PostMakePostPrivateFailure(this.message);
}

// MAKE POST PUBLIC
class PostMakePostPublicInProgress extends PostState {}

class PostMakePostPublicSuccess extends PostState {
  final Map<String, dynamic> post;

  PostMakePostPublicSuccess(this.post);
}

class PostMakePostPublicFailure extends PostState {
  final String message;

  PostMakePostPublicFailure(this.message);
}

// ADD REACTION
class PostAddReactionInProgress extends PostState {}

class PostAddReactionSuccess extends PostState {
  final Map<String, dynamic> post;

  PostAddReactionSuccess(this.post);
}

class PostAddReactionFailure extends PostState {
  final String message;

  PostAddReactionFailure(this.message);
}

// UPDATE REACTION
class PostUpdateReactionInProgress extends PostState {}

class PostUpdateReactionSuccess extends PostState {
  final Map<String, dynamic> post;

  PostUpdateReactionSuccess(this.post);
}

class PostUpdateReactionFailure extends PostState {
  final String message;

  PostUpdateReactionFailure(this.message);
}

// REMOVE REACTION
class PostRemoveReactionInProgress extends PostState {}

class PostRemoveReactionSuccess extends PostState {
  final Map<String, dynamic> post;

  PostRemoveReactionSuccess(this.post);
}

class PostRemoveReactionFailure extends PostState {
  final String message;

  PostRemoveReactionFailure(this.message);
}
