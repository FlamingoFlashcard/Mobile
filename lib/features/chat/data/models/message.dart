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
      id: json['_id'] ?? '',
      chat: json['chat'] ?? '',
      sender: json['sender'] is String
          ? MessageSender(id: json['sender'], username: '', avatar: null)
          : MessageSender.fromJson(json['sender']),
      text: json['text'] ?? '',
      readBy: List<String>.from(json['readBy'] ?? []),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
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
      id: json['_id'] ?? '',
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
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      pages: json['pages'] ?? 0,
    );
  }
}