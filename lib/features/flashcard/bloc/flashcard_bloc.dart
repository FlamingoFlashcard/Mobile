import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lacquer/features/flashcard/dtos/create_tag_dto.dart';
import '../data/flashcard_repository.dart';
import 'flashcard_event.dart';
import 'flashcard_state.dart';

class FlashcardBloc extends Bloc<FlashcardEvent, FlashcardState> {
  final FlashcardRepository repository;

  FlashcardBloc({required this.repository}) : super(const FlashcardState()) {
    on<CreateDeckRequested>(_onCreateDeckRequested);
    on<LoadDecksRequested>(_onLoadDecksRequested);
    on<LoadTagsRequested>(_onLoadTagsRequested);
    on<CreateTagRequested>(_onCreateTagRequested);
    // on<LoadDeckByIdRequested>(_onLoadDeckByIdRequested);
    // on<DeleteDeckRequested>(_onDeleteDeckRequested);
    // on<UpdateDeckRequested>(_onUpdateDeckRequested);
  }

  Future<void> _onCreateDeckRequested(
    CreateDeckRequested event,
    Emitter<FlashcardState> emit,
  ) async {
    emit(state.copyWith(status: FlashcardStatus.loading));

    try {
      final deck = await repository.createDeck(
        title: event.title,
        description: event.description,
        imageUrl: event.imageUrl,
        cardIds: event.cardIds,
      );

      final groupedDecks = await repository.getDecks();

      emit(
        state.copyWith(
          status: FlashcardStatus.success,
          selectedDeck: deck,
          groupedDecks: groupedDecks,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: FlashcardStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onLoadDecksRequested(
    LoadDecksRequested event,
    Emitter<FlashcardState> emit,
  ) async {
    emit(state.copyWith(status: FlashcardStatus.loading));

    try {
      final groupedDecks = await repository.getDecks();
      emit(
        state.copyWith(
          status: FlashcardStatus.success,
          groupedDecks: groupedDecks,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: FlashcardStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onLoadTagsRequested(
    LoadTagsRequested event,
    Emitter<FlashcardState> emit,
  ) async {
    emit(state.copyWith(status: FlashcardStatus.loading));

    try {
      final tags = await repository.getTags();
      emit(state.copyWith(status: FlashcardStatus.success, tags: tags));
    } catch (e) {
      emit(
        state.copyWith(
          status: FlashcardStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onCreateTagRequested(
    CreateTagRequested event,
    Emitter<FlashcardState> emit,
  ) async {
    emit(state.copyWith(createTagStatus: FlashcardStatus.loading));

    try {
      final newTag = await repository.createTag(name: event.name);
      final updatedTags = List<CreateTagResponseDto>.from(state.tags)
        ..add(newTag);

      emit(
        state.copyWith(
          createTagStatus: FlashcardStatus.success,
          tags: updatedTags,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          createTagStatus: FlashcardStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // Future<void> _onLoadDeckByIdRequested(
  //   LoadDeckByIdRequested event,
  //   Emitter<FlashcardState> emit,
  // ) async {
  //   emit(state.copyWith(status: FlashcardStatus.loading));

  //   try {
  //     final deck = await repository.getDeckById(event.deckId);
  //     emit(state.copyWith(
  //       status: FlashcardStatus.success,
  //       selectedDeck: deck,
  //     ));
  //   } catch (e) {
  //     emit(state.copyWith(
  //       status: FlashcardStatus.failure,
  //       errorMessage: e.toString(),
  //     ));
  //   }
  // }

  // Future<void> _onDeleteDeckRequested(
  //   DeleteDeckRequested event,
  //   Emitter<FlashcardState> emit,
  // ) async {
  //   emit(state.copyWith(status: FlashcardStatus.loading));

  //   try {
  //     await repository.deleteDeck(event.deckId);

  //     // Remove the deleted deck from the list
  //     final updatedDecks = state.decks.where((deck) => deck.id != event.deckId).toList();

  //     emit(state.copyWith(
  //       status: FlashcardStatus.success,
  //       decks: updatedDecks,
  //       // Clear selected deck if it was the one deleted
  //       selectedDeck: state.selectedDeck?.id == event.deckId ? null : state.selectedDeck,
  //     ));
  //   } catch (e) {
  //     emit(state.copyWith(
  //       status: FlashcardStatus.failure,
  //       errorMessage: e.toString(),
  //     ));
  //   }
  // }

  // Future<void> _onUpdateDeckRequested(
  //   UpdateDeckRequested event,
  //   Emitter<FlashcardState> emit,
  // ) async {
  //   emit(state.copyWith(status: FlashcardStatus.loading));

  //   try {
  //     final updatedDeck = await repository.updateDeck(
  //       deckId: event.deckId,
  //       title: event.title,
  //       description: event.description,
  //       imageUrl: event.imageUrl,
  //       cardIds: event.cardIds,
  //     );

  //     // Update the deck in the list
  //     final updatedDecks = state.decks.map((deck) {
  //       return deck.id == event.deckId ? updatedDeck : deck;
  //     }).toList();

  //     emit(state.copyWith(
  //       status: FlashcardStatus.success,
  //       decks: updatedDecks,
  //       // Update selected deck if it was the one updated
  //       selectedDeck: state.selectedDeck?.id == event.deckId ? updatedDeck : state.selectedDeck,
  //     ));
  //   } catch (e) {
  //     emit(state.copyWith(
  //       status: FlashcardStatus.failure,
  //       errorMessage: e.toString(),
  //     ));
  //   }
  // }
}
