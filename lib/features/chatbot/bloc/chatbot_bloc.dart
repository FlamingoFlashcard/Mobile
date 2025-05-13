import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lacquer/features/chatbot/bloc/chatbot_event.dart';
import 'package:lacquer/features/chatbot/bloc/chatbot_state.dart';
import 'package:lacquer/features/chatbot/data/chatbot_repository.dart';
import 'package:lacquer/features/result_type.dart';

class ChatbotBloc extends Bloc<ChatbotEvent, ChatbotState> {
  ChatbotBloc(this.chatbotRepository) : super(ChatbotInitial()) {
    on<ChatbotEventStarted>(_onStarted);
    on<ChatbotEventAsking>(_onAsking);
    on<ChatbotEventGetHistory>(_onGetHistory);
    on<ChatbotEventDeleteHistory>(_onDeleteHistory);
  }

  final ChatbotRepository chatbotRepository;

  void _onStarted(ChatbotEventStarted event, Emitter<ChatbotState> emit) async {
    emit(ChatbotInitial());
  }

  void _onAsking(ChatbotEventAsking event, Emitter<ChatbotState> emit) async {
    emit(ChatbotAskingInProgress());
    final result = await chatbotRepository.ask(event.prompt, event.userId);
    return (switch (result) {
      Success(data: final reply) when reply.isNotEmpty => emit(
        ChatbotAskingSuccess(reply),
      ),
      Success() => emit(ChatbotAskingFailure('No response')),
      Failure() => emit(ChatbotAskingFailure(result.message)),
    });
  }

  void _onGetHistory(
    ChatbotEventGetHistory event,
    Emitter<ChatbotState> emit,
  ) async {
    emit(ChatbotFetchingInProgress());
    final result = await chatbotRepository.getHistory(event.userId);
    return (switch (result) {
      Success(data: final history) when history.isNotEmpty => emit(
        ChatbotFetchingSuccess(history),
      ),
      Success() => emit(ChatbotFetchingFailure('No history')),
      Failure() => emit(ChatbotFetchingFailure(result.message)),
    });
  }

  void _onDeleteHistory(
    ChatbotEventDeleteHistory event,
    Emitter<ChatbotState> emit,
  ) async {
    emit(ChatbotFetchingInProgress());
    final result = await chatbotRepository.deleteHistory(event.userId);
    return (switch (result) {
      Success() => emit(ChatbotInitial()),
      Failure() => emit(ChatbotFetchingFailure(result.message)),
    });
  }
}
