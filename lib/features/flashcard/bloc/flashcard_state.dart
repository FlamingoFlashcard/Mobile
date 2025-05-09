import 'package:equatable/equatable.dart';
import '../dtos/create_deck_dto.dart';

enum FlashcardStatus { initial, loading, success, failure }

class FlashcardState extends Equatable {
  final FlashcardStatus status;
  final List<CreateDeckResponseDto> decks;
  final CreateDeckResponseDto? selectedDeck;
  final String? errorMessage;

  const FlashcardState({
    this.status = FlashcardStatus.initial,
    this.decks = const [],
    this.selectedDeck,
    this.errorMessage,
  });

  FlashcardState copyWith({
    FlashcardStatus? status,
    List<CreateDeckResponseDto>? decks,
    CreateDeckResponseDto? selectedDeck,
    String? errorMessage,
  }) {
    return FlashcardState(
      status: status ?? this.status,
      decks: decks ?? this.decks,
      selectedDeck: selectedDeck ?? this.selectedDeck,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, decks, selectedDeck, errorMessage];
}
