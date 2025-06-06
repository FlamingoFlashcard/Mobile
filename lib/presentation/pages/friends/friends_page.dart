import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lacquer/config/theme.dart';
import 'package:lacquer/features/friendship/bloc/friendship_bloc.dart';
import 'package:lacquer/features/friendship/bloc/friendship_event.dart';
import 'package:lacquer/features/friendship/bloc/friendship_state.dart';
import 'package:lacquer/features/auth/data/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FriendsPage extends StatefulWidget {
  final bool selectMode;
  final bool multiSelect;
  
  const FriendsPage({
    super.key,
    this.selectMode = false,
    this.multiSelect = false,
  });

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> friends = [];
  List<dynamic> friendRequests = [];
  List<dynamic> blockedUsers = [];
  String? currentUserId;
  
  // Selection mode variables
  List<String> selectedFriendIds = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCurrentUser();
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = prefs.getString(AuthDataConstants.userIdKey);
    });
  }

  void _loadData() {
    context.read<FriendshipBloc>().add(FriendshipEventGetFriends());
    context.read<FriendshipBloc>().add(FriendshipEventGetFriendRequests());
    context.read<FriendshipBloc>().add(FriendshipEventGetBlockedUsers());
  }

  // Helper method to get the friend user ID from a friendship relationship
  String _getFriendUserId(dynamic friendship) {
    if (currentUserId == null) {
      return '';
    }

    final requester = friendship['requester'];
    final recipient = friendship['recipient'];
    
    // Handle both old format (just IDs) and new format (full objects)
    String requesterId;
    String recipientId;
    
    if (requester is Map) {
      requesterId = requester['_id'] ?? '';
    } else {
      requesterId = requester?.toString() ?? '';
    }
    
    if (recipient is Map) {
      recipientId = recipient['_id'] ?? '';
    } else {
      recipientId = recipient?.toString() ?? '';
    }

    // Return the other person's ID
    return requesterId == currentUserId ? recipientId : requesterId;
  }

  // Helper method to get display information from friendship object
  Map<String, String> _getFriendDisplayInfo(dynamic friendship) {
    if (currentUserId == null) {
      return {
        'id': '',
        'username': 'Unknown',
        'email': '',
        'avatarUrl': '',
      };
    }

    final requester = friendship['requester'];
    final recipient = friendship['recipient'];

    // Determine which user is the friend (not the current user)
    Map<String, dynamic>? friendUser;
    
    if (requester is Map && requester['_id'] == currentUserId) {
      friendUser = recipient is Map ? Map<String, dynamic>.from(recipient) : null;
    } else if (recipient is Map && recipient['_id'] == currentUserId) {
      friendUser = requester is Map ? Map<String, dynamic>.from(requester) : null;
    } else if (requester is Map) {
      friendUser = Map<String, dynamic>.from(requester);
    } else if (recipient is Map) {
      friendUser = Map<String, dynamic>.from(recipient);
    }
    
    if (friendUser != null) {
      return {
        'id': friendUser['_id'] ?? '',
        'username': friendUser['username'] ?? 'Unknown',
        'email': friendUser['email'] ?? '',
        'avatarUrl': friendUser['avatar'] ?? '',
      };
    }
    
    // Fallback for old format
    final friendId = _getFriendUserId(friendship);
    return {
      'id': friendId,
      'username': 'User ${friendId.isNotEmpty && friendId.length >= 4 ? friendId.substring(friendId.length - 4) : friendId}',
      'email': '',
      'avatarUrl': '',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            CustomTheme.loginGradientStart,
            CustomTheme.loginGradientEnd,
          ],
          begin: FractionalOffset(0.5, 0.0),
          end: FractionalOffset(0.5, 1.0),
          stops: <double>[0.0, 1.0],
          tileMode: TileMode.clamp,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            widget.selectMode 
                ? (widget.multiSelect 
                    ? 'Select Friends (${selectedFriendIds.length})' 
                    : 'Select a Friend')
                : 'Friends',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          actions: widget.selectMode ? [
            if (widget.multiSelect || selectedFriendIds.isNotEmpty)
              TextButton(
                onPressed: () {
                  if (widget.multiSelect) {
                    Navigator.of(context).pop(selectedFriendIds);
                  } else if (selectedFriendIds.isNotEmpty) {
                    Navigator.of(context).pop(selectedFriendIds.first);
                  }
                },
                child: Text(
                  'Done',
                  style: TextStyle(
                    color: const Color(0xFFA31D1D),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
          ] : null,
          bottom: widget.selectMode ? null : PreferredSize(
            preferredSize: Size.fromHeight(48),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Color.fromRGBO(255, 255, 255, 0.9),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.1),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: LinearGradient(
                    colors: [Colors.deepOrange, Colors.deepOrange.shade600],
                  ),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black54,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people, size: 18),
                        SizedBox(width: 4),
                        Text('Friends'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_add, size: 18),
                        SizedBox(width: 4),
                        Text('Requests'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.block, size: 18),
                        SizedBox(width: 4),
                        Text('Blocked'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: BlocListener<FriendshipBloc, FriendshipState>(
          listener: (context, state) {
            if (state is FriendshipGetFriendsSuccess) {
              setState(() {
                friends = state.friends;
              });
            } else if (state is FriendshipGetFriendRequestsSuccess) {
              setState(() {
                friendRequests = state.requests;
              });
            } else if (state is FriendshipGetBlockedUsersSuccess) {
              setState(() {
                blockedUsers = state.blocked;
              });
            } else if (state is FriendshipAcceptRequestSuccess ||
                state is FriendshipRejectRequestSuccess ||
                state is FriendshipBlockFriendSuccess ||
                state is FriendshipUnblockFriendSuccess ||
                state is FriendshipRemoveFriendSuccess) {
              _loadData(); // Refresh data after actions
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Action completed successfully'),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            } else if (state is FriendshipGetFriendsFailure ||
                state is FriendshipGetFriendRequestsFailure ||
                state is FriendshipGetBlockedUsersFailure ||
                state is FriendshipAcceptRequestFailure ||
                state is FriendshipRejectRequestFailure ||
                state is FriendshipBlockFriendFailure ||
                state is FriendshipUnblockFriendFailure ||
                state is FriendshipRemoveFriendFailure) {
              final errorMessage = switch (state) {
                FriendshipGetFriendsFailure() => state.message,
                FriendshipGetFriendRequestsFailure() => state.message,
                FriendshipGetBlockedUsersFailure() => state.message,
                FriendshipAcceptRequestFailure() => state.message,
                FriendshipRejectRequestFailure() => state.message,
                FriendshipBlockFriendFailure() => state.message,
                FriendshipUnblockFriendFailure() => state.message,
                FriendshipRemoveFriendFailure() => state.message,
                _ => 'An error occurred',
              };

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.error, color: Colors.white),
                      SizedBox(width: 8),
                      Expanded(child: Text(errorMessage)),
                    ],
                  ),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }
          },
          child: SafeArea(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFriendsTab(),
                _buildRequestsTab(),
                _buildBlockedTab(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFriendsTab() {
    return BlocBuilder<FriendshipBloc, FriendshipState>(
      builder: (context, state) {
        if (state is FriendshipGetFriendsInProgress) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
                ),
                SizedBox(height: 16),
                Text(
                  'Loading friends...',
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                ),
              ],
            ),
          );
        }

        if (friends.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(255, 255, 255, 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'No Friends Yet',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Start connecting with people!',
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.all(20),
          child: ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final friend = friends[index];
              return _buildFriendCard(friend);
            },
          ),
        );
      },
    );
  }

  Widget _buildRequestsTab() {
    return BlocBuilder<FriendshipBloc, FriendshipState>(
      builder: (context, state) {
        if (state is FriendshipGetFriendRequestsInProgress) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
                ),
                SizedBox(height: 16),
                Text(
                  'Loading requests...',
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                ),
              ],
            ),
          );
        }

        if (friendRequests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(255, 255, 255, 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_add_outlined,
                    size: 64,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'No Friend Requests',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'You\'re all caught up!',
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.all(20),
          child: ListView.builder(
            itemCount: friendRequests.length,
            itemBuilder: (context, index) {
              final request = friendRequests[index];
              return _buildRequestCard(request);
            },
          ),
        );
      },
    );
  }

  Widget _buildBlockedTab() {
    return BlocBuilder<FriendshipBloc, FriendshipState>(
      builder: (context, state) {
        if (state is FriendshipGetBlockedUsersInProgress) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
                ),
                SizedBox(height: 16),
                Text(
                  'Loading blocked users...',
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                ),
              ],
            ),
          );
        }

        if (blockedUsers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(255, 255, 255, 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.block_outlined,
                    size: 64,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'No Blocked Users',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'You haven\'t blocked anyone',
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.all(20),
          child: ListView.builder(
            itemCount: blockedUsers.length,
            itemBuilder: (context, index) {
              final blockedUser = blockedUsers[index];
              return _buildBlockedCard(blockedUser);
            },
          ),
        );
      },
    );
  }

  Widget _buildFriendCard(dynamic friend) {
    final friendInfo = _getFriendDisplayInfo(friend);
    final username = friendInfo['username'] ?? 'Unknown';
    final email = friendInfo['email'] ?? '';
    final avatarUrl = friendInfo['avatarUrl'] ?? '';
    final friendId = friendInfo['id'] ?? '';

    final isSelected = selectedFriendIds.contains(friendId);

    return GestureDetector(
      onTap: widget.selectMode ? () {
        setState(() {
          if (widget.multiSelect) {
            if (isSelected) {
              selectedFriendIds.remove(friendId);
            } else {
              selectedFriendIds.add(friendId);
            }
          } else {
            // Single select mode
            selectedFriendIds.clear();
            selectedFriendIds.add(friendId);
            Navigator.of(context).pop(friendId);
          }
        });
      } : null,
      child: Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: widget.selectMode && isSelected 
              ? const Color(0xFFA31D1D).withValues(alpha: 0.1)
              : Color.fromRGBO(255, 255, 255, 0.95),
        borderRadius: BorderRadius.circular(16),
          border: widget.selectMode && isSelected
              ? Border.all(color: const Color(0xFFA31D1D), width: 2)
              : null,
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
              if (widget.selectMode && widget.multiSelect) ...[
                Checkbox(
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        selectedFriendIds.add(friendId);
                      } else {
                        selectedFriendIds.remove(friendId);
                      }
                    });
                  },
                  activeColor: const Color(0xFFA31D1D),
                ),
                SizedBox(width: 8),
              ],
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey.shade200,
              backgroundImage:
                  avatarUrl.isNotEmpty
                      ? NetworkImage(avatarUrl)
                      : const AssetImage('assets/images/boy.png')
                          as ImageProvider,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  if (email.isNotEmpty) ...[
                    SizedBox(height: 2),
                    Text(
                      email,
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                  // Show friendship status info
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(76, 175, 80, 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Friends since ${_formatDate(friend['createdAt'])}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
              if (!widget.selectMode)
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'block':
                    _showBlockConfirmDialog(friendId, username);
                    break;
                  case 'remove':
                    _showRemoveConfirmDialog(friendId, username);
                    break;
                }
              },
              itemBuilder:
                  (context) => [
                    PopupMenuItem(
                      value: 'block',
                      child: Row(
                        children: [
                          Icon(Icons.block, color: Colors.orange, size: 20),
                          SizedBox(width: 8),
                          Text('Block'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'remove',
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_remove,
                            color: Colors.red,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text('Remove'),
                        ],
                      ),
                    ),
                  ],
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(0, 0, 0, 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.more_vert, color: Colors.black54, size: 20),
              ),
                )
              else if (widget.selectMode && !widget.multiSelect && isSelected)
                Icon(Icons.check_circle, color: const Color(0xFFA31D1D), size: 24),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(dynamic request) {
    final requestInfo = _getFriendDisplayInfo(request);
    final username = requestInfo['username'] ?? 'Unknown';
    final email = requestInfo['email'] ?? '';
    final avatarUrl = requestInfo['avatarUrl'] ?? '';

    // For accept/reject operations, use the requester ID (person who sent the request)
    // This is likely what the API expects as the friendId parameter
    final requesterId = request['requester'] ?? '';
    final requestId = request['_id'] ?? request['id'] ?? '';
    final idToUse = requesterId.isNotEmpty ? requesterId : requestId;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, 0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage:
                      avatarUrl.isNotEmpty
                          ? NetworkImage(avatarUrl)
                          : const AssetImage('assets/images/boy.png')
                              as ImageProvider,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      if (email.isNotEmpty) ...[
                        SizedBox(height: 2),
                        Text(
                          email,
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ],
                      SizedBox(height: 4),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(255, 193, 7, 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Friend Request • ${_formatDate(request['createdAt'])}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<FriendshipBloc>().add(
                        FriendshipEventAcceptRequest(friendId: idToUse),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check, size: 18),
                        SizedBox(width: 4),
                        Text(
                          'Accept',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<FriendshipBloc>().add(
                        FriendshipEventRejectRequest(friendId: idToUse),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.close, size: 18),
                        SizedBox(width: 4),
                        Text(
                          'Decline',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockedCard(dynamic blockedUser) {
    final blockedInfo = _getFriendDisplayInfo(blockedUser);
    final username = blockedInfo['username'] ?? 'Unknown';
    final email = blockedInfo['email'] ?? '';
    final avatarUrl = blockedInfo['avatarUrl'] ?? '';
    final userId = blockedInfo['id'] ?? '';

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, 0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage:
                      avatarUrl.isNotEmpty
                          ? NetworkImage(avatarUrl)
                          : const AssetImage('assets/images/boy.png')
                              as ImageProvider,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(Icons.block, color: Colors.white, size: 12),
                  ),
                ),
              ],
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  if (email.isNotEmpty) ...[
                    SizedBox(height: 2),
                    Text(
                      email,
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(244, 67, 54, 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Blocked • ${_formatDate(blockedUser['updatedAt'])}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _showUnblockConfirmDialog(userId, username);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Unblock',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBlockConfirmDialog(String friendId, String username) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.block, color: Colors.orange, size: 24),
                SizedBox(width: 8),
                Text('Block Friend?'),
              ],
            ),
            content: Text(
              'Are you sure you want to block $username? You won\'t see their posts and they won\'t be able to contact you.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<FriendshipBloc>().add(
                    FriendshipEventBlockFriend(friendId: friendId),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: Text('Block'),
              ),
            ],
          ),
    );
  }

  void _showRemoveConfirmDialog(String friendId, String username) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.person_remove, color: Colors.red, size: 24),
                SizedBox(width: 8),
                Text('Remove Friend?'),
              ],
            ),
            content: Text(
              'Are you sure you want to remove $username from your friends list?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<FriendshipBloc>().add(
                    FriendshipEventRemoveFriend(friendId: friendId),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text('Remove'),
              ),
            ],
          ),
    );
  }

  void _showUnblockConfirmDialog(String userId, String username) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.person_add, color: Colors.blue, size: 24),
                SizedBox(width: 8),
                Text('Unblock User?'),
              ],
            ),
            content: Text(
              'Are you sure you want to unblock $username? They will be able to contact you and see your posts again.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<FriendshipBloc>().add(
                    FriendshipEventUnblockFriend(friendId: userId),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: Text('Unblock'),
              ),
            ],
          ),
    );
  }

  // Helper method to format date
  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inMinutes}m ago';
      }
    } catch (e) {
      return '';
    }
  }
}
