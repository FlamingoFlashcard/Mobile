sealed class FriendshipState {}

class FriendshipInitial extends FriendshipState {}

// GET FRIENDS
class FriendshipGetFriendsInProgress extends FriendshipState {}

class FriendshipGetFriendsSuccess extends FriendshipState {
  final List<dynamic> friends;

  FriendshipGetFriendsSuccess(this.friends);
}

class FriendshipGetFriendsFailure extends FriendshipState {
  final String message;

  FriendshipGetFriendsFailure(this.message);
}

// GET FRIEND REQUESTS
class FriendshipGetFriendRequestsInProgress extends FriendshipState {}

class FriendshipGetFriendRequestsSuccess extends FriendshipState {
  final List<dynamic> requests;

  FriendshipGetFriendRequestsSuccess(this.requests);
}

class FriendshipGetFriendRequestsFailure extends FriendshipState {
  final String message;

  FriendshipGetFriendRequestsFailure(this.message);
}

// GET BLOCKED USERS
class FriendshipGetBlockedUsersInProgress extends FriendshipState {}

class FriendshipGetBlockedUsersSuccess extends FriendshipState {
  final List<dynamic> blocked;

  FriendshipGetBlockedUsersSuccess(this.blocked);
}

class FriendshipGetBlockedUsersFailure extends FriendshipState {
  final String message;

  FriendshipGetBlockedUsersFailure(this.message);
}

// SEND REQUEST
class FriendshipSendRequestInProgress extends FriendshipState {}

class FriendshipSendRequestSuccess extends FriendshipState {}

class FriendshipSendRequestFailure extends FriendshipState {
  final String message;

  FriendshipSendRequestFailure(this.message);
}

// ACCEPT REQUEST
class FriendshipAcceptRequestInProgress extends FriendshipState {}

class FriendshipAcceptRequestSuccess extends FriendshipState {}

class FriendshipAcceptRequestFailure extends FriendshipState {
  final String message;

  FriendshipAcceptRequestFailure(this.message);
}

// REJECT REQUEST
class FriendshipRejectRequestInProgress extends FriendshipState {}

class FriendshipRejectRequestSuccess extends FriendshipState {}

class FriendshipRejectRequestFailure extends FriendshipState {
  final String message;

  FriendshipRejectRequestFailure(this.message);
}

// BLOCK FRIEND
class FriendshipBlockFriendInProgress extends FriendshipState {}

class FriendshipBlockFriendSuccess extends FriendshipState {}

class FriendshipBlockFriendFailure extends FriendshipState {
  final String message;

  FriendshipBlockFriendFailure(this.message);
}

// UNBLOCK FRIEND
class FriendshipUnblockFriendInProgress extends FriendshipState {}

class FriendshipUnblockFriendSuccess extends FriendshipState {}

class FriendshipUnblockFriendFailure extends FriendshipState {
  final String message;

  FriendshipUnblockFriendFailure(this.message);
}

// REMOVE FRIEND
class FriendshipRemoveFriendInProgress extends FriendshipState {}

class FriendshipRemoveFriendSuccess extends FriendshipState {}

class FriendshipRemoveFriendFailure extends FriendshipState {
  final String message;

  FriendshipRemoveFriendFailure(this.message);
}
