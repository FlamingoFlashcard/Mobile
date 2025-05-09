import '../dtos/create_deck_dto.dart';
import 'flashcard_api_client.dart';

class FlashcardRepository {
  final FlashcardApiClient apiClient;

  FlashcardRepository(this.apiClient);

  Future<CreateDeckResponseDto> createDeck({
    required String title,
    required String description,
    required String imageUrl,
    required List<String> cardIds,
  }) async {
    final deckDto = CreateDeckDto(
      title: title,
      description: description,
      imageUrl: imageUrl,
      cardIds: cardIds,
    );

    return apiClient.createDeck(deckDto);
  }

  // Future<List<CreateDeckResponseDto>> getDecks() async {
  //   return apiClient.getDecks();
  // }

  // Future<CreateDeckResponseDto> getDeckById(String deckId) async {
  //   return apiClient.getDeckById(deckId);
  // }

  // Future<void> deleteDeck(String deckId) async {
  //   return apiClient.deleteDeck(deckId);
  // }

  // Future<CreateDeckResponseDto> updateDeck({
  //   required String deckId,
  //   required String title,
  //   required String description,
  //   required String imageUrl,
  //   required List<String> cardIds,
  // }) async {
  //   final deckDto = CreateDeckDto(
  //     title: title,
  //     description: description,
  //     imageUrl: imageUrl,
  //     cardIds: cardIds,
  //   );

  //   return apiClient.updateDeck(deckId, deckDto);
  // }
}
