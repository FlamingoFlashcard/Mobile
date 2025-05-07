import 'package:lacquer/features/chatbot/data/chatbot_api_client.dart';
import 'package:lacquer/features/chatbot/dtos/prompt_dto.dart';
import 'package:lacquer/features/result_type.dart';

class ChatbotRepository {
  final ChatbotApiClient chatbotApiClient;

  ChatbotRepository({required this.chatbotApiClient});

  Future<Result<String>> ask(String prompt) async {
    try {
      final reply = await chatbotApiClient.ask(PromptDto(prompt: prompt));
      if (reply.success) {
        return Success(reply.data);
      } else {
        return Failure(reply.message);
      }
    } catch (e) {
      return Failure(e.toString());
    }
  }
}
