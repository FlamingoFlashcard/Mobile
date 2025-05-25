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

  // Note: UserService doesn't have removeFriend method,
  // but we can add it here for future implementation
  Future<Result<void>> removeFriend(String friendId) async {
    try {
      // This would need to be implemented in UserService
      // For now, we'll return a failure
      return Failure('Remove friend functionality not implemented yet');
    } catch (e) {
      return Failure(e.toString());
    }
  }
}
