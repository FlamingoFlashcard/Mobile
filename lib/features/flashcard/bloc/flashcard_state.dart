import 'package:equatable/equatable.dart';
import 'package:lacquer/features/flashcard/dtos/create_tag_dto.dart';
import '../dtos/create_deck_dto.dart';

enum FlashcardStatus { initial, loading, success, failure }

class FlashcardState extends Equatable {
  final FlashcardStatus status;
  final List<CreateDeckResponseDto> decks;
  final CreateDeckResponseDto? selectedDeck;
  final List<CreateTagResponseDto> tags;
  final String? errorMessage;

  const FlashcardState({
    this.status = FlashcardStatus.initial,
    this.decks = const [],
    this.selectedDeck,
    this.tags = const [],
    this.errorMessage,
  });

  FlashcardState copyWith({
    FlashcardStatus? status,
    List<CreateDeckResponseDto>? decks,
    CreateDeckResponseDto? selectedDeck,
    List<CreateTagResponseDto>? tags,
    String? errorMessage,
  }) {
    return FlashcardState(
      status: status ?? this.status,
      decks: decks ?? this.decks,
      selectedDeck: selectedDeck ?? this.selectedDeck,
      tags: tags ?? this.tags,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, decks, selectedDeck, tags, errorMessage];
}
