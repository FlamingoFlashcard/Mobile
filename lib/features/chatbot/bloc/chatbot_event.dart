class ChatbotEvent {}

class ChatbotEventStarted extends ChatbotEvent {}

class ChatbotEventAsking extends ChatbotEvent {
  final String prompt;
  final String userId;

  ChatbotEventAsking({required this.prompt, required this.userId});
}

class ChatbotEventGetHistory extends ChatbotEvent {
  final String userId;

  ChatbotEventGetHistory({required this.userId});
}

class ChatbotEventDeleteHistory extends ChatbotEvent {
  final String userId;

  ChatbotEventDeleteHistory({required this.userId});
}