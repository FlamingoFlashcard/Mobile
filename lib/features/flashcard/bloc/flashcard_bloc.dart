import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/flashcard_repository.dart';
import 'flashcard_event.dart';
import 'flashcard_state.dart';

class FlashcardBloc extends Bloc<FlashcardEvent, FlashcardState> {
  final FlashcardRepository repository;

  FlashcardBloc({required this.repository}) : super(const FlashcardState()) {
    on<CreateDeckRequested>(_onCreateDeckRequested);
    // on<LoadDecksRequested>(_onLoadDecksRequested);
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

      emit(
        state.copyWith(
          status: FlashcardStatus.success,
          selectedDeck: deck,
          decks: [...state.decks, deck],
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

  // Future<void> _onLoadDecksRequested(
  //   LoadDecksRequested event,
  //   Emitter<FlashcardState> emit,
  // ) async {
  //   emit(state.copyWith(status: FlashcardStatus.loading));

  //   try {
  //     final decks = await repository.getDecks();
  //     emit(state.copyWith(
  //       status: FlashcardStatus.success,
  //       decks: decks,
  //     ));
  //   } catch (e) {
  //     emit(state.copyWith(
  //       status: FlashcardStatus.failure,
  //       errorMessage: e.toString(),
  //     ));
  //   }
  // }

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
