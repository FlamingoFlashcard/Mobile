import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lacquer/features/flashcard/dtos/create_tag_dto.dart';
import 'package:lacquer/features/flashcard/dtos/grouped_decks_dto.dart';
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
    on<UpdateTagRequested>(_onUpdateTagRequested);
    on<LoadDeckByIdRequested>(_onLoadDeckByIdRequested);
    on<DeleteDeckRequested>(_onDeleteDeckRequested);
    on<UpdateDeckRequested>(_onUpdateDeckRequested);
    on<DeleteTagRequested>(_onDeleteTagRequested);
    on<SearchDecksRequested>(_onSearchDecksRequested);
    on<AddCardToDeckRequested>(_onAddCardToDeckRequested);
    on<FinishDeckRequested>(_onFinishDeckRequested);
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
        tags: event.tags,
        cards: event.cards,
        imageFile: event.imageFile,
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
          searchResult: true,
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

  Future<void> _onUpdateTagRequested(
    UpdateTagRequested event,
    Emitter<FlashcardState> emit,
  ) async {
    emit(state.copyWith(updateTagStatus: FlashcardStatus.loading));
    try {
      await repository.updateTag(tagId: event.tagId, name: event.title);
      await _onLoadTagsRequested(LoadTagsRequested(), emit);
      await _onLoadDecksRequested(LoadDecksRequested(), emit);
      emit(state.copyWith(updateTagStatus: FlashcardStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          updateTagStatus: FlashcardStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onLoadDeckByIdRequested(
    LoadDeckByIdRequested event,
    Emitter<FlashcardState> emit,
  ) async {
    emit(state.copyWith(status: FlashcardStatus.loading));

    try {
      final deck = await repository.getDeckById(event.deckId);
      emit(state.copyWith(status: FlashcardStatus.success, selectedDeck: deck));
    } catch (e) {
      emit(
        state.copyWith(
          status: FlashcardStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleteDeckRequested(
    DeleteDeckRequested event,
    Emitter<FlashcardState> emit,
  ) async {
    emit(state.copyWith(status: FlashcardStatus.loading));

    try {
      await repository.deleteDeck(event.deckId);

      GroupedDecksResponseDto? updatedGroupedDecks;
      if (state.groupedDecks != null) {
        final updatedItems =
            state.groupedDecks!.data.map((item) {
              final updatedDecks =
                  item.decks.where((deck) => deck.id != event.deckId).toList();
              return GroupedDeckItem(tag: item.tag, decks: updatedDecks);
            }).toList();

        final newCount = updatedItems.fold<int>(
          0,
          (sum, item) => sum + item.decks.length,
        );

        updatedGroupedDecks = GroupedDecksResponseDto(
          count: newCount,
          data: updatedItems,
        );
      }

      emit(
        state.copyWith(
          status: FlashcardStatus.success,
          groupedDecks: updatedGroupedDecks,
          selectedDeck:
              state.selectedDeck?.id == event.deckId
                  ? null
                  : state.selectedDeck,
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

  Future<void> _onUpdateDeckRequested(
    UpdateDeckRequested event,
    Emitter<FlashcardState> emit,
  ) async {
    emit(state.copyWith(status: FlashcardStatus.loading));
    try {
      await repository.updateDeck(
        deckId: event.deckId,
        title: event.title,
        description: event.description,
        tags: event.tags,
        imageFile: event.imageFile,
      );
      await _onLoadDecksRequested(LoadDecksRequested(), emit);
      emit(state.copyWith(status: FlashcardStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: FlashcardStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleteTagRequested(
    DeleteTagRequested event,
    Emitter<FlashcardState> emit,
  ) async {
    emit(state.copyWith(status: FlashcardStatus.loading));

    try {
      await repository.deleteTag(event.tagId);
      await _onLoadDecksRequested(LoadDecksRequested(), emit);
      emit(state.copyWith(status: FlashcardStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: FlashcardStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onSearchDecksRequested(
    SearchDecksRequested event,
    Emitter<FlashcardState> emit,
  ) {
    emit(
      state.copyWith(status: FlashcardStatus.loading, searchQuery: event.query),
    );

    if (state.groupedDecks == null) {
      emit(state.copyWith(status: FlashcardStatus.success, groupedDecks: null));
      return;
    }

    final filteredDecks = filterDecksByName(state.groupedDecks!, event.query);
    emit(
      state.copyWith(
        status: FlashcardStatus.success,
        groupedDecks: filteredDecks,
        searchResult: filteredDecks != null,
      ),
    );
  }

  Future<void> _onAddCardToDeckRequested(
    AddCardToDeckRequested event,
    Emitter<FlashcardState> emit,
  ) async {
    emit(state.copyWith(status: FlashcardStatus.loading));

    try {
      await repository.addCardToDeck(
        deckId: event.deckId,
        cardId: event.cardId,
      );

      final groupedDecks = await repository.getDecks();

      final updatedDeck = await repository.getDeckById(event.deckId);

      emit(
        state.copyWith(
          status: FlashcardStatus.success,
          selectedDeck: updatedDeck,
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

  GroupedDecksResponseDto? filterDecksByName(
    GroupedDecksResponseDto groupedDecks,
    String query,
  ) {
    if (query.isEmpty) return groupedDecks;

    final lowerCaseQuery = query.toLowerCase();
    final filteredItems =
        groupedDecks.data
            .map((group) {
              final filteredDecks =
                  group.decks
                      .where(
                        (deck) =>
                            deck.title.toLowerCase().contains(lowerCaseQuery),
                      )
                      .toList();
              return filteredDecks.isNotEmpty
                  ? GroupedDeckItem(tag: group.tag, decks: filteredDecks)
                  : null;
            })
            .whereType<GroupedDeckItem>()
            .toList();

    if (filteredItems.isEmpty) return null;

    final newCount = filteredItems.fold<int>(
      0,
      (sum, item) => sum + item.decks.length,
    );
    return GroupedDecksResponseDto(count: newCount, data: filteredItems);
  }

  Future<void> _onFinishDeckRequested(
    FinishDeckRequested event,
    Emitter<FlashcardState> emit,
  ) async {
    emit(state.copyWith(status: FlashcardStatus.loading));

    try {
      await repository.finishDeck(event.deckId);
      final groupedDecks = await repository.getDecks();
      final updatedDeck = await repository.getDeckById(event.deckId);

      emit(
        state.copyWith(
          status: FlashcardStatus.success,
          selectedDeck: updatedDeck,
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
}
