import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lacquer/features/post/bloc/post_event.dart';
import 'package:lacquer/features/post/bloc/post_state.dart';
import 'package:lacquer/features/post/data/post_repository.dart';
import 'package:lacquer/features/result_type.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  PostBloc(this.postRepository) : super(PostInitial()) {
    on<PostEventStarted>(_onStarted);
    on<PostEventGetAllPosts>(_onGetAllPosts);
    on<PostEventGetUserPosts>(_onGetUserPosts);
    on<PostEventGetPost>(_onGetPost);
    on<PostEventCreatePost>(_onCreatePost);
    on<PostEventCreatePostWithUpload>(_onCreatePostWithUpload);
    on<PostEventDeletePost>(_onDeletePost);
    on<PostEventMakePostPrivate>(_onMakePostPrivate);
    on<PostEventMakePostPublic>(_onMakePostPublic);
    on<PostEventAddReaction>(_onAddReaction);
    on<PostEventUpdateReaction>(_onUpdateReaction);
    on<PostEventRemoveReaction>(_onRemoveReaction);
  }

  final PostRepository postRepository;

  void _onStarted(PostEventStarted event, Emitter<PostState> emit) {
    emit(PostInitial());
  }

  void _onGetAllPosts(
    PostEventGetAllPosts event,
    Emitter<PostState> emit,
  ) async {
    emit(PostGetAllPostsInProgress());
    final result = await postRepository.getAllPosts();
    return (switch (result) {
      Success(data: final response) => emit(
        PostGetAllPostsSuccess(
          posts: response['data'] ?? [],
          count: response['count'] ?? 0,
        ),
      ),
      Failure() => emit(PostGetAllPostsFailure(result.message)),
    });
  }

  void _onGetUserPosts(
    PostEventGetUserPosts event,
    Emitter<PostState> emit,
  ) async {
    emit(PostGetUserPostsInProgress());
    final result = await postRepository.getUserPosts(event.userId);
    return (switch (result) {
      Success(data: final response) => emit(
        PostGetUserPostsSuccess(
          posts: response['data'] ?? [],
          user: response['user'] ?? {},
        ),
      ),
      Failure() => emit(PostGetUserPostsFailure(result.message)),
    });
  }

  void _onGetPost(PostEventGetPost event, Emitter<PostState> emit) async {
    emit(PostGetPostInProgress());
    final result = await postRepository.getPost(event.postId);
    return (switch (result) {
      Success(data: final response) => emit(
        PostGetPostSuccess(response['data'] ?? {}),
      ),
      Failure() => emit(PostGetPostFailure(result.message)),
    });
  }

  void _onCreatePost(PostEventCreatePost event, Emitter<PostState> emit) async {
    emit(PostCreatePostInProgress());
    final result = await postRepository.createPost(
      imageUrl: event.imageUrl,
      caption: event.caption,
      isPrivate: event.isPrivate,
      visibleToUsers: event.visibleToUsers,
    );
    return (switch (result) {
      Success(data: final response) => emit(
        PostCreatePostSuccess(response['data'] ?? {}),
      ),
      Failure() => emit(PostCreatePostFailure(result.message)),
    });
  }

  void _onCreatePostWithUpload(
    PostEventCreatePostWithUpload event,
    Emitter<PostState> emit,
  ) async {
    emit(PostCreatePostWithUploadInProgress());
    final result = await postRepository.createPostWithUpload(
      image: event.image,
      caption: event.caption,
      isPrivate: event.isPrivate,
      visibleToUsers: event.visibleToUsers,
    );
    return (switch (result) {
      Success(data: final response) => emit(
        PostCreatePostWithUploadSuccess(
          post: response['data'] ?? {},
          uploadInfo: response['uploadInfo'] ?? {},
        ),
      ),
      Failure() => emit(PostCreatePostWithUploadFailure(result.message)),
    });
  }

  void _onDeletePost(PostEventDeletePost event, Emitter<PostState> emit) async {
    emit(PostDeletePostInProgress());
    final result = await postRepository.deletePost(event.postId);
    return (switch (result) {
      Success() => emit(PostDeletePostSuccess()),
      Failure() => emit(PostDeletePostFailure(result.message)),
    });
  }

  void _onMakePostPrivate(
    PostEventMakePostPrivate event,
    Emitter<PostState> emit,
  ) async {
    emit(PostMakePostPrivateInProgress());
    final result = await postRepository.makePostPrivate(
      event.postId,
      visibleToUsers: event.visibleToUsers,
    );
    return (switch (result) {
      Success(data: final response) => emit(
        PostMakePostPrivateSuccess(response['data'] ?? {}),
      ),
      Failure() => emit(PostMakePostPrivateFailure(result.message)),
    });
  }

  void _onMakePostPublic(
    PostEventMakePostPublic event,
    Emitter<PostState> emit,
  ) async {
    emit(PostMakePostPublicInProgress());
    final result = await postRepository.makePostPublic(event.postId);
    return (switch (result) {
      Success(data: final response) => emit(
        PostMakePostPublicSuccess(response['data'] ?? {}),
      ),
      Failure() => emit(PostMakePostPublicFailure(result.message)),
    });
  }

  void _onAddReaction(
    PostEventAddReaction event,
    Emitter<PostState> emit,
  ) async {
    emit(PostAddReactionInProgress());
    final result = await postRepository.addReaction(event.postId, event.emoji);
    return (switch (result) {
      Success(data: final response) => emit(
        PostAddReactionSuccess(response['data'] ?? {}),
      ),
      Failure() => emit(PostAddReactionFailure(result.message)),
    });
  }

  void _onUpdateReaction(
    PostEventUpdateReaction event,
    Emitter<PostState> emit,
  ) async {
    emit(PostUpdateReactionInProgress());
    final result = await postRepository.updateReaction(
      event.postId,
      event.emoji,
    );
    return (switch (result) {
      Success(data: final response) => emit(
        PostUpdateReactionSuccess(response['data'] ?? {}),
      ),
      Failure() => emit(PostUpdateReactionFailure(result.message)),
    });
  }

  void _onRemoveReaction(
    PostEventRemoveReaction event,
    Emitter<PostState> emit,
  ) async {
    emit(PostRemoveReactionInProgress());
    final result = await postRepository.removeReaction(event.postId);
    return (switch (result) {
      Success(data: final response) => emit(
        PostRemoveReactionSuccess(response['data'] ?? {}),
      ),
      Failure() => emit(PostRemoveReactionFailure(result.message)),
    });
  }
}
