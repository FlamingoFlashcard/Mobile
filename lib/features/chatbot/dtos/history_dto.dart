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
      data: Data.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class Data {
  final List<History> history;

  const Data({required this.history});
  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      history: (json['history'] as List)
          .map((e) => History.fromJson(e))
          .toList(),
    );
  }
}

class History {
  final List<Message> message;

  const History({required this.message});
  factory History.fromJson(Map<String, dynamic> json) {
    return History(
      message: (json['message'] as List)
          .map((e) => Message.fromJson(e))
          .toList(),
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
      parts: (json['parts'] as List)
          .map((e) => Part.fromJson(e))
          .toList(),
    );
  }
}

class Part {
  final String text;

  const Part({required this.text});
  factory Part.fromJson(Map<String, dynamic> json) {
    return Part(
      text: json['text'] as String,
    );
  }
}
