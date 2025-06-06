import 'package:lacquer/features/result_type.dart';
import 'package:lacquer/services/user_service.dart';

class FriendshipRepository {
  final UserService _userService = UserService();

  Future<Result<List<dynamic>>> getFriends() async {
    try {
      final friends = await _userService.getFriends();
      return Success(friends);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<List<dynamic>>> getFriendRequests() async {
    try {
      final requests = await _userService.getFriendRequests();
      return Success(requests);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<List<dynamic>>> getBlockedUsers() async {
    try {
      final blocked = await _userService.getBlockedUsers();
      return Success(blocked);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<void>> sendFriendRequest(String friendId) async {
    try {
      await _userService.sendFriendRequest(friendId);
      return Success(null);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<void>> acceptFriendRequest(String friendId) async {
    try {
      await _userService.acceptFriendRequest(friendId);
      return Success(null);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<void>> rejectFriendRequest(String friendId) async {
    try {
      await _userService.rejectFriendRequest(friendId);
      return Success(null);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<void>> blockFriend(String friendId) async {
    try {
      await _userService.blockFriend(friendId);
      return Success(null);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<void>> unblockFriend(String friendId) async {
    try {
      await _userService.unblockFriend(friendId);
      return Success(null);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<void>> removeFriend(String friendId) async {
    try {
      await _userService.removeFriend(friendId);
      return Success(null);
    } catch (e) {
      return Failure(e.toString());
    }
  }
}
