import 'package:dio/dio.dart';
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

  // Future<List<CreateDeckResponseDto>> getDecks() async {
  //   try {
  //     final token = await authLocalDataSource.getToken();

  //     final options = Options(headers: {
  //       if (token != null) 'Authorization': 'Bearer $token',
  //     });

  //     final response = await dio.get(
  //       '/decks',
  //       options: options,
  //     );

  //     return (response.data as List)
  //         .map((json) => CreateDeckResponseDto.fromJson(json))
  //         .toList();
  //   } on DioException catch (e) {
  //     if (e.response != null) {
  //       throw Exception(e.response!.data['message']);
  //     } else {
  //       throw Exception(e.message);
  //     }
  //   }
  // }

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
