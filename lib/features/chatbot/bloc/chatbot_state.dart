import 'package:lacquer/features/chatbot/dtos/history_dto.dart';

sealed class ChatbotState {}

class ChatbotInitial extends ChatbotState {}

class ChatbotAskingInProgress extends ChatbotState {}

class ChatbotAskingSuccess extends ChatbotState {
  final String response;

  ChatbotAskingSuccess(this.response);
}

class ChatbotAskingFailure extends ChatbotState {
  final String message;

  ChatbotAskingFailure(this.message);
}

class ChatbotFetchingInProgress extends ChatbotState {}
class ChatbotFetchingSuccess extends ChatbotState {
  final List<History> history;

  ChatbotFetchingSuccess(this.history);
}

class ChatbotFetchingFailure extends ChatbotState {
  final String message;

  ChatbotFetchingFailure(this.message);
}