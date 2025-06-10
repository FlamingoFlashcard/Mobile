import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lacquer/features/friendship/bloc/friendship_event.dart';
import 'package:lacquer/features/friendship/bloc/friendship_state.dart';
import 'package:lacquer/features/friendship/data/friendship_repository.dart';
import 'package:lacquer/features/result_type.dart';

class FriendshipBloc extends Bloc<FriendshipEvent, FriendshipState> {
  FriendshipBloc(this.friendshipRepository) : super(FriendshipInitial()) {
    on<FriendshipEventStarted>(_onStarted);
    on<FriendshipEventGetFriends>(_onGetFriends);
    on<FriendshipEventGetFriendRequests>(_onGetFriendRequests);
    on<FriendshipEventGetBlockedUsers>(_onGetBlockedUsers);
    on<FriendshipEventSendRequest>(_onSendRequest);
    on<FriendshipEventAcceptRequest>(_onAcceptRequest);
    on<FriendshipEventRejectRequest>(_onRejectRequest);
    on<FriendshipEventBlockFriend>(_onBlockFriend);
    on<FriendshipEventUnblockFriend>(_onUnblockFriend);
    on<FriendshipEventRemoveFriend>(_onRemoveFriend);
  }

  final FriendshipRepository friendshipRepository;

  void _onStarted(FriendshipEventStarted event, Emitter<FriendshipState> emit) {
    emit(FriendshipInitial());
  }

  void _onGetFriends(
    FriendshipEventGetFriends event,
    Emitter<FriendshipState> emit,
  ) async {
    emit(FriendshipGetFriendsInProgress());
    final result = await friendshipRepository.getFriends();
    return (switch (result) {
      Success(data: final friends) => emit(
        FriendshipGetFriendsSuccess(friends),
      ),
      Failure() => emit(FriendshipGetFriendsFailure(result.message)),
    });
  }

  void _onGetFriendRequests(
    FriendshipEventGetFriendRequests event,
    Emitter<FriendshipState> emit,
  ) async {
    emit(FriendshipGetFriendRequestsInProgress());
    final result = await friendshipRepository.getFriendRequests();
    return (switch (result) {
      Success(data: final requests) => emit(
        FriendshipGetFriendRequestsSuccess(requests),
      ),
      Failure() => emit(FriendshipGetFriendRequestsFailure(result.message)),
    });
  }

  void _onGetBlockedUsers(
    FriendshipEventGetBlockedUsers event,
    Emitter<FriendshipState> emit,
  ) async {
    emit(FriendshipGetBlockedUsersInProgress());
    final result = await friendshipRepository.getBlockedUsers();
    return (switch (result) {
      Success(data: final blocked) => emit(
        FriendshipGetBlockedUsersSuccess(blocked),
      ),
      Failure() => emit(FriendshipGetBlockedUsersFailure(result.message)),
    });
  }

  void _onSendRequest(
    FriendshipEventSendRequest event,
    Emitter<FriendshipState> emit,
  ) async {
    emit(FriendshipSendRequestInProgress());
    final result = await friendshipRepository.sendFriendRequest(event.friendId);
    return (switch (result) {
      Success() => emit(FriendshipSendRequestSuccess()),
      Failure() => emit(FriendshipSendRequestFailure(result.message)),
    });
  }

  void _onAcceptRequest(
    FriendshipEventAcceptRequest event,
    Emitter<FriendshipState> emit,
  ) async {
    emit(FriendshipAcceptRequestInProgress());
    final result = await friendshipRepository.acceptFriendRequest(
      event.friendshipId,
    );
    return (switch (result) {
      Success() => emit(FriendshipAcceptRequestSuccess()),
      Failure() => emit(FriendshipAcceptRequestFailure(result.message)),
    });
  }

  void _onRejectRequest(
    FriendshipEventRejectRequest event,
    Emitter<FriendshipState> emit,
  ) async {
    emit(FriendshipRejectRequestInProgress());
    final result = await friendshipRepository.rejectFriendRequest(
      event.friendshipId,
    );
    return (switch (result) {
      Success() => emit(FriendshipRejectRequestSuccess()),
      Failure() => emit(FriendshipRejectRequestFailure(result.message)),
    });
  }

  void _onBlockFriend(
    FriendshipEventBlockFriend event,
    Emitter<FriendshipState> emit,
  ) async {
    emit(FriendshipBlockFriendInProgress());
    final result = await friendshipRepository.blockFriend(event.friendId);
    return (switch (result) {
      Success() => emit(FriendshipBlockFriendSuccess()),
      Failure() => emit(FriendshipBlockFriendFailure(result.message)),
    });
  }

  void _onUnblockFriend(
    FriendshipEventUnblockFriend event,
    Emitter<FriendshipState> emit,
  ) async {
    emit(FriendshipUnblockFriendInProgress());
    final result = await friendshipRepository.unblockFriend(event.friendId);
    return (switch (result) {
      Success() => emit(FriendshipUnblockFriendSuccess()),
      Failure() => emit(FriendshipUnblockFriendFailure(result.message)),
    });
  }

  void _onRemoveFriend(
    FriendshipEventRemoveFriend event,
    Emitter<FriendshipState> emit,
  ) async {
    emit(FriendshipRemoveFriendInProgress());
    final result = await friendshipRepository.removeFriend(event.friendshipId);
    return (switch (result) {
      Success() => emit(FriendshipRemoveFriendSuccess()),
      Failure() => emit(FriendshipRemoveFriendFailure(result.message)),
    });
  }
}
