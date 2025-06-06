import '../data/models/chat.dart';
import '../data/models/message.dart';

abstract class ChatState {}

// Initial state
class ChatInitial extends ChatState {}

// Loading states
class ChatLoading extends ChatState {}

class ChatLoadingChats extends ChatState {}

class ChatLoadingMessages extends ChatState {}

class ChatSendingMessage extends ChatState {}

class ChatCreatingChat extends ChatState {}

// WebSocket connection states
class ChatWebSocketConnecting extends ChatState {}

class ChatWebSocketConnected extends ChatState {}

class ChatWebSocketDisconnected extends ChatState {}

class ChatWebSocketError extends ChatState {
  final String message;

  ChatWebSocketError({required this.message});
}

// Success states
class ChatChatsLoaded extends ChatState {
  final List<Chat> chats;

  ChatChatsLoaded({required this.chats});
}

class ChatMessagesLoaded extends ChatState {
  final String chatId;
  final List<Message> messages;
  final MessagesPagination pagination;

  ChatMessagesLoaded({
    required this.chatId,
    required this.messages,
    required this.pagination,
  });
}

class ChatMessageSent extends ChatState {
  final Message message;

  ChatMessageSent({required this.message});
}

class ChatMessageReceived extends ChatState {
  final Message message;

  ChatMessageReceived({required this.message});
}

class ChatPrivateChatCreated extends ChatState {
  final Chat chat;

  ChatPrivateChatCreated({required this.chat});
}

class ChatGroupChatCreated extends ChatState {
  final Chat chat;

  ChatGroupChatCreated({required this.chat});
}

class ChatMembersAdded extends ChatState {
  final String chatId;

  ChatMembersAdded({required this.chatId});
}

class ChatMembersRemoved extends ChatState {
  final String chatId;

  ChatMembersRemoved({required this.chatId});
}

class ChatMessageMarkedAsRead extends ChatState {
  final String messageId;

  ChatMessageMarkedAsRead({required this.messageId});
}

class ChatUnreadCountLoaded extends ChatState {
  final int count;

  ChatUnreadCountLoaded({required this.count});
}

class ChatSelected extends ChatState {
  final String chatId;

  ChatSelected({required this.chatId});
}

// Typing states
class ChatUserTyping extends ChatState {
  final String chatId;
  final String userId;
  final String username;

  ChatUserTyping({
    required this.chatId,
    required this.userId,
    required this.username,
  });
}

class ChatUserStoppedTyping extends ChatState {
  final String chatId;
  final String userId;

  ChatUserStoppedTyping({
    required this.chatId,
    required this.userId,
  });
}

class ChatTypingStarted extends ChatState {
  final String chatId;

  ChatTypingStarted({required this.chatId});
}

class ChatTypingStopped extends ChatState {
  final String chatId;

  ChatTypingStopped({required this.chatId});
}

// Online users state
class ChatOnlineUsersUpdated extends ChatState {
  final List<String> onlineUsers;

  ChatOnlineUsersUpdated({required this.onlineUsers});
}

// Message seen state
class ChatMessageSeen extends ChatState {
  final String chatId;
  final String messageId;
  final String userId;

  ChatMessageSeen({
    required this.chatId,
    required this.messageId,
    required this.userId,
  });
}

// New message notification
class ChatNewMessageNotification extends ChatState {
  final String chatId;
  final Message message;

  ChatNewMessageNotification({
    required this.chatId,
    required this.message,
  });
}

// Chats joined state
class ChatChatsJoined extends ChatState {
  final List<String> chatIds;

  ChatChatsJoined({required this.chatIds});
}

// Error states
class ChatError extends ChatState {
  final String message;

  ChatError({required this.message});
}

class ChatLoadChatsError extends ChatState {
  final String message;

  ChatLoadChatsError({required this.message});
}

class ChatLoadMessagesError extends ChatState {
  final String message;

  ChatLoadMessagesError({required this.message});
}

class ChatSendMessageError extends ChatState {
  final String message;

  ChatSendMessageError({required this.message});
}

class ChatCreateChatError extends ChatState {
  final String message;

  ChatCreateChatError({required this.message});
} 