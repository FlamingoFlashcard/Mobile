import 'message.dart';

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