import 'package:equatable/equatable.dart';
import 'package:lacquer/features/flashcard/dtos/create_tag_dto.dart';
import 'package:lacquer/features/flashcard/dtos/grouped_decks_dto.dart';
import '../dtos/create_deck_dto.dart';

enum FlashcardStatus { initial, loading, success, failure }

class FlashcardState extends Equatable {
  final FlashcardStatus status;
  final FlashcardStatus createTagStatus;
  final GroupedDecksResponseDto? groupedDecks;
  final CreateDeckResponseDto? selectedDeck;
  final List<CreateTagResponseDto> tags;
  final String? errorMessage;

  const FlashcardState({
    this.status = FlashcardStatus.initial,
    this.createTagStatus = FlashcardStatus.initial,
    this.groupedDecks,
    this.selectedDeck,
    this.tags = const [],
    this.errorMessage,
  });

  FlashcardState copyWith({
    FlashcardStatus? status,
    FlashcardStatus? createTagStatus,
    GroupedDecksResponseDto? groupedDecks,
    CreateDeckResponseDto? selectedDeck,
    List<CreateTagResponseDto>? tags,
    String? errorMessage,
  }) {
    return FlashcardState(
      status: status ?? this.status,
      createTagStatus: createTagStatus ?? this.createTagStatus,
      groupedDecks: groupedDecks ?? this.groupedDecks,
      selectedDeck: selectedDeck ?? this.selectedDeck,
      tags: tags ?? this.tags,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    createTagStatus,
    groupedDecks,
    selectedDeck,
    tags,
    errorMessage,
  ];
}
