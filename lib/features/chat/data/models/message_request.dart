class MessageRequest {
  final String chatId;
  final String content;

  MessageRequest({
    required this.content,
    required this.chatId,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'chatId': chatId,
    };
  }
}