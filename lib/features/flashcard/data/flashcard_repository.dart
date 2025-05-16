import 'package:lacquer/features/flashcard/dtos/create_tag_dto.dart';
import 'package:lacquer/presentation/pages/home/widgets/flashcard_tag.dart';
import 'package:lacquer/presentation/utils/default_tag_list.dart';

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

  Future<List<CreateDeckResponseDto>> getDecks() async {
    return apiClient.getDecks();
  }

  Future<List<FlashcardTag>> mapDecksToTags(
    List<CreateDeckResponseDto> decks,
  ) async {
    final tagMap = <String, FlashcardTag>{};

    for (var tag in defaultTagList) {
      tagMap[tag.title.toLowerCase()] = FlashcardTag(
        title: tag.title,
        decks: [],
      );
    }

    for (var deck in decks) {
      final tagKey = deck.tag.toLowerCase();
      if (tagMap.containsKey(tagKey)) {
        tagMap[tagKey]!.decks.add(deck);
      }
    }

    return tagMap.values.where((tag) => tag.decks.isNotEmpty).toList();
  }

  Future<List<CreateTagResponseDto>> getTags() async {
    return apiClient.getTags();
  }

  Future<CreateTagResponseDto> createTag({required String name}) async {
    final tagDto = CreateTagDto(name: name);

    return apiClient.createTag(tagDto);
  }

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
