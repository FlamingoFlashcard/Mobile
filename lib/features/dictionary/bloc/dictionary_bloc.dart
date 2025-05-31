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
    on<DictionaryEventToggleFavorite>(_onToggleFavorite);
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
    try {
      final recentSearches = await dictionaryRepository.getRecentSearches(
        language,
      );
      final favorites = await dictionaryRepository.getFavorites(language);
      emit(
        DictionaryStateMainScreenSuccess(
          recentSearches: recentSearches,
          favorites: favorites,
          lang: language,
        ),
      );
    } catch (e) {
      emit(DictionaryStateMainScreenFailure("Error: $e"));
    }
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
    final check = await dictionaryRepository.isFavorite(event.word, event.lang);
    return (switch (result) {
      Success(data: final vocabulary) => emit(
        DictionaryStateWordDetailsSuccess(
          vocabulary: vocabulary,
          isFavorite: check,
        ),
      ),
      Failure() => emit(DictionaryStateWordDetailsFailure(result.message)),
    });
  }

  Future<bool> _onToggleFavorite(
    DictionaryEventToggleFavorite event,
    Emitter<DictionaryState> emit,
  ) async {
    final String word = event.word;
    final String lang = event.lang;
    final bool isFavorite = event.isFavorite;

    if (isFavorite) {
      await dictionaryRepository.saveFavorite(word, lang);
    } else {
      await dictionaryRepository.removeFavorite(word, lang);
    }
    return isFavorite;
  }
}
