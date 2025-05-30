import 'package:lacquer/features/dictionary/dtos/search_result_dto.dart';

sealed class DictionaryState {}

class DictionaryStateInitial extends DictionaryState {}

// Main Screen
class DictionaryStateMainScreenLoading extends DictionaryState {}

class DictionaryStateMainScreenSuccess extends DictionaryState {
  final String lang;
  final List<String> recentSearches;
  final List<String> favorites;

  DictionaryStateMainScreenSuccess({
    required this.lang,
    required this.recentSearches,
    required this.favorites,
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
  final int numberOfResults;
  final List<Vocabulary> results;
  final String lang;

  DictionaryStateSearchSuccess({
    required this.query,
    required this.numberOfResults,
    required this.results,
    required this.lang,
  });
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


