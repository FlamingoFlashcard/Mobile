import 'package:equatable/equatable.dart';
import 'package:lacquer/features/flashcard/dtos/create_tag_dto.dart';
import 'package:lacquer/features/flashcard/dtos/grouped_decks_dto.dart';
import '../dtos/create_deck_dto.dart';

enum FlashcardStatus { initial, loading, success, failure }

class FlashcardState extends Equatable {
  final FlashcardStatus status;
  final FlashcardStatus createTagStatus;
  final FlashcardStatus updateTagStatus;
  final GroupedDecksResponseDto? groupedDecks;
  final CreateDeckResponseDto? selectedDeck;
  final List<CreateTagResponseDto> tags;
  final String? errorMessage;
  final String searchQuery;
  final bool searchResult;

  const FlashcardState({
    this.status = FlashcardStatus.initial,
    this.createTagStatus = FlashcardStatus.initial,
    this.updateTagStatus = FlashcardStatus.initial,
    this.groupedDecks,
    this.selectedDeck,
    this.tags = const [],
    this.errorMessage,
    this.searchQuery = '',
    this.searchResult = true,
  });

  FlashcardState copyWith({
    FlashcardStatus? status,
    FlashcardStatus? createTagStatus,
    FlashcardStatus? updateTagStatus,
    GroupedDecksResponseDto? groupedDecks,
    CreateDeckResponseDto? selectedDeck,
    List<CreateTagResponseDto>? tags,
    String? errorMessage,
    String? searchQuery,
    bool? searchResult,
  }) {
    return FlashcardState(
      status: status ?? this.status,
      createTagStatus: createTagStatus ?? this.createTagStatus,
      updateTagStatus: updateTagStatus ?? this.updateTagStatus,
      groupedDecks: groupedDecks ?? this.groupedDecks,
      selectedDeck: selectedDeck ?? this.selectedDeck,
      tags: tags ?? this.tags,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      searchResult: searchResult ?? this.searchResult,
    );
  }

  @override
  List<Object?> get props => [
    status,
    createTagStatus,
    updateTagStatus,
    groupedDecks,
    selectedDeck,
    tags,
    errorMessage,
    searchQuery,
    searchResult,
  ];
}
