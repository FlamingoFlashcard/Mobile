import 'dart:io';

abstract class ChatEvent {}

// Load all chats
class ChatEventLoadChats extends ChatEvent {}

// Create private chat with a friend
class ChatEventCreatePrivateChat extends ChatEvent {
  final String friendId;

  ChatEventCreatePrivateChat({required this.friendId});
}

// Create group chat
class ChatEventCreateGroupChat extends ChatEvent {
  final String name;
  final String description;
  final String admin;
  final List<String> participants;
  final File? avatar;

  ChatEventCreateGroupChat({
    required this.name,
    required this.description,
    required this.admin,
    required this.participants,
    this.avatar,
  });
}

// Add members to group
class ChatEventAddMembersToGroup extends ChatEvent {
  final String chatId;
  final List<String> members;

  ChatEventAddMembersToGroup({
    required this.chatId,
    required this.members,
  });
}

// Remove members from group
class ChatEventRemoveMembersFromGroup extends ChatEvent {
  final String chatId;
  final List<String> members;

  ChatEventRemoveMembersFromGroup({
    required this.chatId,
    required this.members,
  });
}

// Load messages for a specific chat
class ChatEventLoadMessages extends ChatEvent {
  final String chatId;
  final int page;
  final int limit;

  ChatEventLoadMessages({
    required this.chatId,
    this.page = 1,
    this.limit = 20,
  });
}

// Send message
class ChatEventSendMessage extends ChatEvent {
  final String chatId;
  final String content;

  ChatEventSendMessage({
    required this.chatId,
    required this.content,
  });
}

// Mark message as read
class ChatEventMarkMessageAsRead extends ChatEvent {
  final String messageId;
  final String? chatId;

  ChatEventMarkMessageAsRead({
    required this.messageId,
    this.chatId,
  });
}

// Load unread count
class ChatEventLoadUnreadCount extends ChatEvent {}

// Select a chat (for navigation)
class ChatEventSelectChat extends ChatEvent {
  final String chatId;

  ChatEventSelectChat({required this.chatId});
}

// Clear selected chat
class ChatEventClearSelectedChat extends ChatEvent {}

// Refresh chats
class ChatEventRefreshChats extends ChatEvent {}

// WebSocket events
class ChatEventConnectWebSocket extends ChatEvent {}

class ChatEventDisconnectWebSocket extends ChatEvent {}

class ChatEventWebSocketMessage extends ChatEvent {
  final Map<String, dynamic> data;

  ChatEventWebSocketMessage({required this.data});
} 