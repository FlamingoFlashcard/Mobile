import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lacquer/features/friendship/bloc/friendship_event.dart';
import 'package:lacquer/features/friendship/bloc/friendship_state.dart';
import 'package:lacquer/features/friendship/data/friendship_repository.dart';
import 'package:lacquer/features/result_type.dart';

class FriendshipBloc extends Bloc<FriendshipEvent, FriendshipState> {
  FriendshipBloc(this.friendshipRepository) : super(FriendshipInitial()) {
    on<FriendshipEventStarted>(_onStarted);
    on<FriendshipEventGetFriends>(_onGetFriends);
    on<FriendshipEventSendRequest>(_onSendRequest);
    on<FriendshipEventAcceptRequest>(_onAcceptRequest);
    on<FriendshipEventRejectRequest>(_onRejectRequest);
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
      event.friendId,
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
      event.friendId,
    );
    return (switch (result) {
      Success() => emit(FriendshipRejectRequestSuccess()),
      Failure() => emit(FriendshipRejectRequestFailure(result.message)),
    });
  }

  void _onRemoveFriend(
    FriendshipEventRemoveFriend event,
    Emitter<FriendshipState> emit,
  ) async {
    emit(FriendshipRemoveFriendInProgress());
    final result = await friendshipRepository.removeFriend(event.friendId);
    return (switch (result) {
      Success() => emit(FriendshipRemoveFriendSuccess()),
      Failure() => emit(FriendshipRemoveFriendFailure(result.message)),
    });
  }
}
