sealed class FriendshipEvent {}

class FriendshipEventStarted extends FriendshipEvent {}

class FriendshipEventGetFriends extends FriendshipEvent {}

class FriendshipEventGetFriendRequests extends FriendshipEvent {}

class FriendshipEventGetBlockedUsers extends FriendshipEvent {}

class FriendshipEventSendRequest extends FriendshipEvent {
  final String friendId;

  FriendshipEventSendRequest({required this.friendId});
}

class FriendshipEventAcceptRequest extends FriendshipEvent {
  final String friendId;

  FriendshipEventAcceptRequest({required this.friendId});
}

class FriendshipEventRejectRequest extends FriendshipEvent {
  final String friendId;

  FriendshipEventRejectRequest({required this.friendId});
}

class FriendshipEventBlockFriend extends FriendshipEvent {
  final String friendId;

  FriendshipEventBlockFriend({required this.friendId});
}

class FriendshipEventUnblockFriend extends FriendshipEvent {
  final String friendId;

  FriendshipEventUnblockFriend({required this.friendId});
}

class FriendshipEventRemoveFriend extends FriendshipEvent {
  final String friendId;

  FriendshipEventRemoveFriend({required this.friendId});
}
