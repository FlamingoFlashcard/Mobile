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
