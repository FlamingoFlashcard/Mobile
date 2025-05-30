import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lacquer/features/dictionary/bloc/dictionary_state.dart';
import 'package:lacquer/features/dictionary/bloc/dictionary_event.dart';
import 'package:lacquer/features/dictionary/data/dictionary_repository.dart';
import 'package:lacquer/features/result_type.dart';

class DictionaryBloc extends Bloc<DictionaryEvent, DictionaryState> {
  DictionaryBloc(this.dictionaryRepository) : super(DictionaryStateInitial()) {
    on<DictionaryEventStarted>(_onStarted);
    on<DictionaryEventLoadMainScreen>(_onLoadMainScreen);
    on<DictionaryEventSearch>(_onSearch);
    on<DictionaryEventSuggestions>(_onSuggestions);
    on<DictionaryEventGetWord>(_onGetWord);
    on<DictionaryEventSaveFavorite>(_onSaveFavorite);
  }
  final DictionaryRepository dictionaryRepository;

  void _onStarted(DictionaryEventStarted event, Emitter<DictionaryState> emit) {
    emit(DictionaryStateInitial());
  }

  void _onLoadMainScreen(
    DictionaryEventLoadMainScreen event,
    Emitter<DictionaryState> emit,
  ) async {
    emit(DictionaryStateMainScreenLoading());
    final language = event.lang;
    final recentSearchesResult = await dictionaryRepository.getRecentSearches(
      language,
    );
    final favoritesResult = await dictionaryRepository.getFavorites(language);
    if (recentSearchesResult is Failure) {
      emit(DictionaryStateMainScreenFailure("Failed to load recent searches"));
      return;
    }
    if (favoritesResult is Failure) {
      emit(DictionaryStateMainScreenFailure("Failed to load favorites"));
      return;
    }
    final recentSearch = (recentSearchesResult as Success).data;
    final favorites = (favoritesResult as Success).data;
    emit(
      DictionaryStateMainScreenSuccess(
        lang: language,
        recentSearches: recentSearch,
        favorites: favorites,
      ),
    );
  }

  void _onSuggestions(
    DictionaryEventSuggestions event,
    Emitter<DictionaryState> emit,
  ) async {
    final String language = event.lang;
    final result = await dictionaryRepository.searchPrefix(
      event.prefix,
      language,
    );
    return (switch (result) {
      Success(data: final suggestions) => emit(
        DictionaryStateSearchSuggestions(
          suggestions: suggestions,
          lang: language,
        ),
      ),
      Failure() => {},
    });
  }

  void _onSearch(
    DictionaryEventSearch event,
    Emitter<DictionaryState> emit,
  ) async {
    emit(DictionaryStateSearchInProgress());
    final String language = event.lang;
    final result = await dictionaryRepository.searchQuery(
      event.query,
      language,
    );
    return (switch (result) {
      Success(data: final searchResult) => emit(
        DictionaryStateSearchSuccess(
          query: event.query,
          numberOfResults: searchResult.length,
          results: searchResult,
          lang: language,
        ),
      ),
      Failure() => emit(DictionaryStateSearchFailure(result.message)),
    });
  }

  void _onGetWord(
    DictionaryEventGetWord event,
    Emitter<DictionaryState> emit,
  ) async {
    emit(DictionaryStateWordDetailsLoading());
    final result = await dictionaryRepository.searchWord(
      event.word,
      event.lang,
    );
    return (switch (result) {
      Success(data: final vocabulary) => emit(
        DictionaryStateWordDetailsSuccess(vocabulary: vocabulary),
      ),
      Failure() => emit(DictionaryStateWordDetailsFailure(result.message)),
    });
  }

  void _onSaveFavorite(
    DictionaryEventSaveFavorite event,
    Emitter<DictionaryState> emit,
  ) async {
    final result = await dictionaryRepository.saveFavorite(
      event.word,
      event.lang,
    );
    if (result is Failure) {
      emit(DictionaryStateMainScreenFailure("Failed to save favorite"));
      return;
    }
    add(DictionaryEventLoadMainScreen(lang: event.lang));
    return;
  }
}
