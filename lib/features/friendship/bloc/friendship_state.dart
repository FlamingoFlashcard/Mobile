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

// REMOVE FRIEND
class FriendshipRemoveFriendInProgress extends FriendshipState {}

class FriendshipRemoveFriendSuccess extends FriendshipState {}

class FriendshipRemoveFriendFailure extends FriendshipState {
  final String message;

  FriendshipRemoveFriendFailure(this.message);
}
