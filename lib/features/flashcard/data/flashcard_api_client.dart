import 'package:dio/dio.dart';
import 'package:lacquer/features/flashcard/dtos/create_tag_dto.dart';
import '../dtos/create_deck_dto.dart';
import 'package:lacquer/features/auth/data/auth_local_data_source.dart';

class FlashcardApiClient {
  FlashcardApiClient(this.dio, this.authLocalDataSource);

  final Dio dio;
  final AuthLocalDataSource authLocalDataSource;

  Future<CreateDeckResponseDto> createDeck(CreateDeckDto deckDto) async {
    try {
      final token = await authLocalDataSource.getToken();

      final options = Options(
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );

      final response = await dio.post(
        '/decks',
        data: deckDto.toJson(),
        options: options,
      );

      return CreateDeckResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception(e.message);
      }
    }
  }

  Future<dynamic> getDecks() async {
    try {
      final token = await authLocalDataSource.getToken();

      final options = Options(
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );

      final response = await dio.get('/deck/tag', options: options);

      final responseData = response.data as Map<String, dynamic>;
      print('API Response (getDecks): $responseData'); // Log the raw response
      if (responseData['success'] != true) {
        throw Exception(responseData['message'] ?? 'Failed to load decks');
      }

      return responseData;
    } on DioException catch (e) {
      print('DioException in getDecks: $e'); // Log any Dio errors
      if (e.response != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception(e.message);
      }
    }
  }

  Future<List<CreateTagResponseDto>> getTags() async {
    try {
      final token = await authLocalDataSource.getToken();

      final options = Options(
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );

      final response = await dio.get('/tag', options: options);

      final responseData = response.data as Map<String, dynamic>;
      final tagData = responseData['data'] as Map<String, dynamic>;
      final tagList = tagData['data'] as List;

      return tagList
          .map((json) => CreateTagResponseDto.fromJson(json))
          .toList();
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception(e.message);
      }
    }
  }

  Future<CreateTagResponseDto> createTag(CreateTagDto tagDto) async {
    try {
      final token = await authLocalDataSource.getToken();

      final options = Options(
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );

      final response = await dio.post(
        '/tag',
        data: tagDto.toJson(),
        options: options,
      );

      final responseData = response.data as Map<String, dynamic>;
      if (responseData['success'] != true) {
        throw Exception(
          'Failed to create tag: ${responseData['message'] ?? 'Unknown error'}',
        );
      }

      final tagData = responseData['data'] as Map<String, dynamic>?;
      if (tagData == null) {
        throw Exception('Tag data is missing in API response');
      }

      return CreateTagResponseDto.fromJson(tagData);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception(e.message);
      }
    }
  }

  // Future<CreateDeckResponseDto> getDeckById(String deckId) async {
  //   try {
  //     final token = await authLocalDataSource.getToken();

  //     final options = Options(headers: {
  //       if (token != null) 'Authorization': 'Bearer $token',
  //     });

  //     final response = await dio.get(
  //       '/decks/$deckId',
  //       options: options,
  //     );

  //     return CreateDeckResponseDto.fromJson(response.data);
  //   } on DioException catch (e) {
  //     if (e.response != null) {
  //       throw Exception(e.response!.data['message']);
  //     } else {
  //       throw Exception(e.message);
  //     }
  //   }
  // }

  // Future<void> deleteDeck(String deckId) async {
  //   try {
  //     final token = await authLocalDataSource.getToken();

  //     final options = Options(headers: {
  //       if (token != null) 'Authorization': 'Bearer $token',
  //     });

  //     await dio.delete(
  //       '/decks/$deckId',
  //       options: options,
  //     );
  //   } on DioException catch (e) {
  //     if (e.response != null) {
  //       throw Exception(e.response!.data['message']);
  //     } else {
  //       throw Exception(e.message);
  //     }
  //   }
  // }

  // Future<CreateDeckResponseDto> updateDeck(String deckId, CreateDeckDto deckDto) async {
  //   try {
  //     final token = await authLocalDataSource.getToken();

  //     final options = Options(headers: {
  //       if (token != null) 'Authorization': 'Bearer $token',
  //     });

  //     final response = await dio.put(
  //       '/decks/$deckId',
  //       data: deckDto.toJson(),
  //       options: options,
  //     );

  //     return CreateDeckResponseDto.fromJson(response.data);
  //   } on DioException catch (e) {
  //     if (e.response != null) {
  //       throw Exception(e.response!.data['message']);
  //     } else {
  //       throw Exception(e.message);
  //     }
  //   }
  // }
}
