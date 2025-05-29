import 'package:lacquer/features/dictionary/data/dictionary_api_clients.dart';
import 'package:lacquer/features/dictionary/data/dictionary_local_data_source.dart';
import 'package:lacquer/features/dictionary/dtos/search_dto.dart';
import 'package:lacquer/features/dictionary/dtos/search_prefix_result_dto.dart';
import 'package:lacquer/features/dictionary/dtos/search_result_dto.dart';
import 'package:lacquer/features/result_type.dart';

class DictionaryRepository {
  final DictionaryApiClients dictionaryApiClients;
  final DictionaryLocalDataSource dictionaryLocalDataSource;

  DictionaryRepository({
    required this.dictionaryApiClients,
    required this.dictionaryLocalDataSource,
  });

  Future<Result<SearchWordResultDto>> searchWord(String word, String lang) async {
    try {
      final reponse = await dictionaryApiClients.searchWord(SearchWordDto(lang, word));
      await saveRecentSearch(word, lang);
      return Success(reponse);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<SearchPrefixResultDto>> searchPrefix(String prefix, String lang) async {
    try {
      final reponse = await dictionaryApiClients.searchPrefix(SearchPrefixDto(lang, prefix));
      return Success(reponse);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<SearchQueryResultDto>> searchQuery(String query, String lang) async {
    try {
      final reponse = await dictionaryApiClients.searchQuery(SearchQueryDto(lang, query));
      await saveRecentSearch(query, lang);
      return Success(reponse);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<void>> saveRecentSearch(String word, String lang) async {
    try {
      await dictionaryLocalDataSource.saveRecentSearch(word, lang);
      return Success(null);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<List<String>>> getRecentSearches(String lang) async {
    try {
      final recentSearches = dictionaryLocalDataSource.getRecentSearches(lang);
      return Success(recentSearches);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<void>> clearRecentSearches(String lang) async {
    try {
      await dictionaryLocalDataSource.clearRecentSearches(lang);
      return Success(null);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<void>> removeRecentSearch(String word, String lang) async {
    try {
      await dictionaryLocalDataSource.removeRecentSearch(word, lang);
      return Success(null);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<void>> saveFavorite(String word, String lang) async {
    try {
      await dictionaryLocalDataSource.saveFavorite(word, lang);
      return Success(null);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<List<String>>> getFavorites(String lang) async {
    try {
      final favorites = dictionaryLocalDataSource.getFavorites(lang);
      return Success(favorites);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<void>> removeFavorite(String word, String lang) async {
    try {
      await dictionaryLocalDataSource.removeFavorite(word, lang);
      return Success(null);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<void>> clearFavorites(String lang) async {
    try {
      await dictionaryLocalDataSource.clearFavorites(lang);
      return Success(null);
    } catch (e) {
      return Failure(e.toString());
    }
  }
}