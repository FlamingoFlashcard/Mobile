class HistoryDto {
  final bool success;
  final String message;
  final Data data;

  const HistoryDto({
    required this.success,
    required this.message,
    required this.data,
  });

  factory HistoryDto.fromJson(Map<String, dynamic> json) {
    return HistoryDto(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: Data.fromJson(json['data'] as List<dynamic>),
    );
  }
}

class Data {
  final List<Message> messages;

  const Data({required this.messages});
  factory Data.fromJson(List<dynamic> json) {
    return Data(
      messages:
          json.map((e) => Message.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class Message {
  final String role;
  final List<Part> parts;

  const Message({required this.role, required this.parts});
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      role: json['role'] as String,
      parts: (json['parts'] as List).map((e) => Part.fromJson(e)).toList(),
    );
  }
}

class Part {
  final String text;

  const Part({required this.text});
  factory Part.fromJson(Map<String, dynamic> json) {
    return Part(text: json['text'] as String);
  }
}
