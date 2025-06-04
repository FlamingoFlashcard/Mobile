class Chat {
  final String id;
  final bool isGroup;
  final List<ChatParticipant> participants;
  final List<String> admins;
  final String? name;
  final String? description;
  final String? avatar;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Message? latestMessage;
  final DateTime? lastMessageTime;

  Chat({
    required this.id,
    required this.isGroup,
    required this.participants,
    required this.admins,
    this.name,
    this.description,
    this.avatar,
    required this.createdAt,
    required this.updatedAt,
    this.latestMessage,
    this.lastMessageTime,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['_id'] ?? '',
      isGroup: json['isGroup'] ?? false,
      participants: (json['participants'] as List?)
          ?.map((p) => ChatParticipant.fromJson(p))
          .toList() ?? [],
      admins: (json['admins'] as List?)
          ?.map((a) => a.toString())
          .toList() ?? [],
      name: json['name'],
      description: json['description'],
      avatar: json['avatar'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      latestMessage: json['latestMessage'] != null 
          ? Message.fromJson(json['latestMessage'])
          : null,
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.tryParse(json['lastMessageTime'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'isGroup': isGroup,
      'participants': participants.map((p) => p.toJson()).toList(),
      'admins': admins,
      'name': name,
      'description': description,
      'avatar': avatar,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'latestMessage': latestMessage?.toJson(),
      'lastMessageTime': lastMessageTime?.toIso8601String(),
    };
  }
}

class ChatParticipant {
  final String id;
  final String username;
  final String? avatar;

  ChatParticipant({
    required this.id,
    required this.username,
    this.avatar,
  });

  factory ChatParticipant.fromJson(Map<String, dynamic> json) {
    return ChatParticipant(
      id: json['_id'] ?? '',
      username: json['username'] ?? 'Unknown',
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'avatar': avatar,
    };
  }
}

class Message {
  final String id;
  final String chat;
  final MessageSender sender;
  final String text;
  final List<String> readBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Message({
    required this.id,
    required this.chat,
    required this.sender,
    required this.text,
    required this.readBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'],
      chat: json['chat'],
      sender: json['sender'] is String
          ? MessageSender(id: json['sender'], username: '', avatar: null)
          : MessageSender.fromJson(json['sender']),
      text: json['text'] ?? '',
      readBy: List<String>.from(json['readBy'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'chat': chat,
      'sender': sender.toJson(),
      'text': text,
      'readBy': readBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class MessageSender {
  final String id;
  final String username;
  final String? avatar;

  MessageSender({
    required this.id,
    required this.username,
    this.avatar,
  });

  factory MessageSender.fromJson(Map<String, dynamic> json) {
    return MessageSender(
      id: json['_id'],
      username: json['username'] ?? '',
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'avatar': avatar,
    };
  }
}

class MessagesResponse {
  final List<Message> messages;
  final MessagesPagination pagination;

  MessagesResponse({
    required this.messages,
    required this.pagination,
  });

  factory MessagesResponse.fromJson(Map<String, dynamic> json) {
    return MessagesResponse(
      messages: (json['messages'] as List)
          .map((msg) => Message.fromJson(msg))
          .toList(),
      pagination: MessagesPagination.fromJson(json['pagination']),
    );
  }
}

class MessagesPagination {
  final int total;
  final int page;
  final int limit;
  final int pages;

  MessagesPagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
  });

  factory MessagesPagination.fromJson(Map<String, dynamic> json) {
    return MessagesPagination(
      total: json['total'],
      page: json['page'],
      limit: json['limit'],
      pages: json['pages'],
    );
  }
} 