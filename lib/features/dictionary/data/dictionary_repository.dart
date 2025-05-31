import 'package:lacquer/features/dictionary/data/dictionary_api_clients.dart';
import 'package:lacquer/features/dictionary/data/dictionary_local_data_source.dart';
import 'package:lacquer/features/dictionary/dtos/search_dto.dart';
import 'package:lacquer/features/dictionary/dtos/search_result_dto.dart';
import 'package:lacquer/features/result_type.dart';

class DictionaryRepository {
  final DictionaryApiClients dictionaryApiClients;
  final DictionaryLocalDataSource dictionaryLocalDataSource;

  DictionaryRepository({
    required this.dictionaryApiClients,
    required this.dictionaryLocalDataSource,
  });

  // Api Calls
  Future<Result<Vocabulary>> searchWord(String word, String lang) async {
    try {
      final reponse = await dictionaryApiClients.searchWord(SearchWordDto(lang, word));
      return Success(reponse.data);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<List<String>>> searchPrefix(String prefix, String lang) async {
    try {
      final reponse = await dictionaryApiClients.searchPrefix(SearchPrefixDto(lang, prefix));
      return Success(reponse.data);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<List<Vocabulary>>> searchQuery(String query, String lang) async {
    try {
      final reponse = await dictionaryApiClients.searchQuery(SearchQueryDto(lang, query));
      await saveRecentSearch(query, lang);
      return Success(reponse.data.vocabularies);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  // Recent Searches and Favorites
  Future<Result<void>> saveRecentSearch(String word, String lang) async {
    try {
      await dictionaryLocalDataSource.saveRecentSearch(word, lang);
      return Success(null);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<List<String>> getRecentSearches(String lang) async {
    try {
      final recentSearches = await dictionaryLocalDataSource.getRecentSearches(lang);
      return recentSearches ?? [];
    } catch (e) {
      return [];
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

  Future<Result<bool>> isRecentSearch(String word, String lang) async {
    try {
      final isRecent = await dictionaryLocalDataSource.isRecentSearch(word, lang);
      return Success(isRecent);
    } catch (e) {
      return Failure(e.toString());
    }
  }
}