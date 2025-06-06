import 'dart:io';
import '../data/models/message.dart';

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
  final String? description;
  final String admin;
  final List<String> participants;
  final File? avatar;

  ChatEventCreateGroupChat({
    required this.name,
    this.description,
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
  final String chatId;

  ChatEventMarkMessageAsRead({
    required this.messageId,
    required this.chatId,
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
  final Message message;

  ChatEventWebSocketMessage({required this.message});
}

// Typing events
class ChatEventStartTyping extends ChatEvent {
  final String chatId;

  ChatEventStartTyping({required this.chatId});
}

class ChatEventStopTyping extends ChatEvent {
  final String chatId;

  ChatEventStopTyping({required this.chatId});
}

class ChatEventUserTyping extends ChatEvent {
  final String chatId;
  final String userId;
  final String username;

  ChatEventUserTyping({
    required this.chatId,
    required this.userId,
    required this.username,
  });
}

class ChatEventUserStoppedTyping extends ChatEvent {
  final String chatId;
  final String userId;

  ChatEventUserStoppedTyping({
    required this.chatId,
    required this.userId,
  });
}

// Online users events
class ChatEventOnlineUsersUpdated extends ChatEvent {
  final List<String> onlineUsers;

  ChatEventOnlineUsersUpdated({required this.onlineUsers});
}

// Message seen events
class ChatEventMessageSeen extends ChatEvent {
  final String chatId;
  final String messageId;
  final String userId;

  ChatEventMessageSeen({
    required this.chatId,
    required this.messageId,
    required this.userId,
  });
}

// New message notification
class ChatEventNewMessageNotification extends ChatEvent {
  final String chatId;
  final Message message;

  ChatEventNewMessageNotification({
    required this.chatId,
    required this.message,
  });
}

// WebSocket error
class ChatEventWebSocketError extends ChatEvent {
  final String message;

  ChatEventWebSocketError({required this.message});
}

// Chats joined
class ChatEventChatsJoined extends ChatEvent {
  final List<String> chatIds;

  ChatEventChatsJoined({required this.chatIds});
} 