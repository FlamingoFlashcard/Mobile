import 'package:dio/dio.dart';
import 'package:lacquer/features/chatbot/dtos/history_dto.dart';
import 'package:lacquer/features/chatbot/dtos/prompt_dto.dart';
import 'package:lacquer/features/chatbot/dtos/reply_dto.dart';

class ChatbotApiClient {
  ChatbotApiClient(this.dio);

  final Dio dio;

  Future<ReplyDto> ask(PromptDto promptdto, String userId) async {
    try {
      final response = await dio.post(
        '/chatbot',
        data: {
          'prompt': promptdto.prompt,          
          'userId': userId,
        },
      );
      return ReplyDto.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception(e.message);
      }
    }
  }
  
  Future<HistoryDto> getHistory(String userId) async {
    try {
      final response = await dio.get(
        '/chatbot/',
        queryParameters: {
          'userId': userId,
        },
      );
      return HistoryDto.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception(e.message);
      }
    }
  }

  Future<bool> deleteHistory(String userId) async {
    try {
      await dio.delete(
        '/chatbot/',
        queryParameters: {
          'userId': userId,
        },
      );
      return true;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception(e.message);
      }
    }
  }
}
