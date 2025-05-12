import 'package:lacquer/features/chatbot/data/chatbot_api_client.dart';
import 'package:lacquer/features/chatbot/dtos/history_dto.dart';
import 'package:lacquer/features/chatbot/dtos/prompt_dto.dart';
import 'package:lacquer/features/result_type.dart';

class ChatbotRepository {
  final ChatbotApiClient chatbotApiClient;

  ChatbotRepository({required this.chatbotApiClient});

  Future<Result<String>> ask(String prompt, String userId) async {
    try {
      final reply = await chatbotApiClient.ask(PromptDto(prompt: prompt), userId);
      if(reply.success) {
        return Success(reply.data);
      } else {
        return Failure(reply.message);
      }
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<List<History>>> getHistory(String userId) async {
    try {
      final history = await chatbotApiClient.getHistory(userId);
      if(history.success) {
        return Success(history.data.history);
      } else {
        return Failure(history.message);
      }
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<void>> deleteHistory(String userId) async {
    try {
      final result = await chatbotApiClient.deleteHistory(userId);
      if(result) {
        return Success(null);
      } else {
        return Failure('Failed to delete history');
      }
    } catch (e) {
      return Failure(e.toString());
    }
  }
}