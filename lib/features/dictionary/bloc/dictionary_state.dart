import 'package:lacquer/features/dictionary/dtos/search_result_dto.dart';
import 'package:lacquer/presentation/pages/home/dictionary_page.dart';

sealed class DictionaryState {}

class DictionaryStateInitial extends DictionaryState {}

// Main Screen
class DictionaryStateMainScreenLoading extends DictionaryState {}

class DictionaryStateMainScreenSuccess extends DictionaryState {
  final String lang;
  final List<String>? recentSearches;
  final List<String>? favorites;

  DictionaryStateMainScreenSuccess({
    required this.lang,
    this.recentSearches,
    this.favorites,
  });
}

class DictionaryStateMainScreenFailure extends DictionaryState {
  final String message;

  DictionaryStateMainScreenFailure(this.message);
}

// Search
class DictionaryStateSearchInProgress extends DictionaryState {}

class DictionaryStateSearchSuggestions extends DictionaryState {
  final List<String> suggestions;
  final String lang;

  DictionaryStateSearchSuggestions({
    required this.suggestions,
    required this.lang,
  });
}

class DictionaryStateSearchSuccess extends DictionaryState {
  final String query;
  final List<Vocabulary> results;
  final String lang;

  DictionaryStateSearchSuccess({
    required this.query,
    required this.results,
    required this.lang,
  });

  List<SearchResultItem> get searchResults =>
      results
          .map(
            (vocabulary) => SearchResultItem(
              word: vocabulary.word,
              pronunciation: vocabulary.pronunciation,
              meanings: {
                for (var wordType in vocabulary.wordTypes)
                  wordType.type: wordType.definitions,
              },
            ),
          )
          .toList();
}

class DictionaryStateSearchFailure extends DictionaryState {
  final String message;

  DictionaryStateSearchFailure(this.message);
}

// Word Details
class DictionaryStateWordDetailsLoading extends DictionaryState {}

class DictionaryStateWordDetailsSuccess extends DictionaryState {
  final Vocabulary vocabulary;

  DictionaryStateWordDetailsSuccess({required this.vocabulary});
}

class DictionaryStateWordDetailsFailure extends DictionaryState {
  final String message;

  DictionaryStateWordDetailsFailure(this.message);
}
