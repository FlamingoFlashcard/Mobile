import 'package:dio/dio.dart';
import 'package:lacquer/features/dictionary/dtos/search_result_dto.dart';

class QuizApiClient {
  final Dio dio;

  QuizApiClient(this.dio);

  Future<SearchQueryResultDto> getQuiz({
    required String lang,
    required String difficulty,
    required int count,
  }) async {
    try {
      final response = await dio.get(
        '/random/$lang',       
       queryParameters: {
          'difficulty': difficulty,
          'count': count,
        },
      );
      if (response.statusCode == 200) {
        return SearchQueryResultDto.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch quiz: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Dio error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
