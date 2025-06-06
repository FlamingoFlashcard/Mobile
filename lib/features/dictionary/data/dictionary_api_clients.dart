import 'package:dio/dio.dart';
import 'package:lacquer/features/dictionary/dtos/search_dto.dart';
import 'package:lacquer/features/dictionary/dtos/search_prefix_result_dto.dart';
import 'package:lacquer/features/dictionary/dtos/search_result_dto.dart';

class DictionaryApiClients {
  final Dio dio;

  DictionaryApiClients(this.dio);

  Future<SearchWordResultDto> searchWord(SearchWordDto word) async {
    try {
      final response = await dio.get('/search/${word.lang}?word=${word.word}');

      if (response.statusCode == 200) {
        return SearchWordResultDto.fromJson(response.data);
      } else {
        throw Exception('Failed to search word: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Dio error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<SearchQueryResultDto> searchQuery(SearchQueryDto query) async {
    try {
      final response = await dio.get(
        '/search/${query.lang}?query=${query.query}',
      );

      if (response.statusCode == 200) {
        return SearchQueryResultDto.fromJson(response.data);
      } else {
        throw Exception('Failed to search query: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Dio error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<SearchPrefixResultDto> searchPrefix(SearchPrefixDto prefix) async {
    try {
      final response = await dio.get(
        '/search/${prefix.lang}?prefix=${prefix.prefix}',
      );

      if (response.statusCode == 200) {
        return SearchPrefixResultDto.fromJson(response.data);
      } else {
        throw Exception('Failed to search prefix: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Dio error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
