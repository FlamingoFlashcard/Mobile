import 'package:shared_preferences/shared_preferences.dart';

class DictionaryLocalDataSource {
  final SharedPreferences sf;

  DictionaryLocalDataSource(this.sf);

  static const String _recentEngSearchesKey = 'recent_en_searches';
  static const String _recentVieSearchesKey = 'recent_vn_searches';
  static const String _favoriteEngWordsKey = 'favorite_en_words';
  static const String _favoriteVieWordsKey = 'favorite_vn_words';

  // Recent searches for English and Vietnamese words
  Future<void> saveRecentSearch(String word, String lang) async {
    final key = lang == 'en' ? _recentEngSearchesKey : _recentVieSearchesKey;
    final recentSearches = sf.getStringList(key) ?? [];

    // Remove the word if it already exists to avoid duplicates
    recentSearches.remove(word);
    // Insert the word at the beginning
    recentSearches.insert(0, word);

    // Keep only the first 10 items
    if (recentSearches.length > 10) {
      recentSearches.removeRange(10, recentSearches.length);
    }

    await sf.setStringList(key, recentSearches);
  }

  Future<List<String>?> getRecentSearches(String lang) async {
    final key = lang == 'en' ? _recentEngSearchesKey : _recentVieSearchesKey;
    return sf.getStringList(key);
  }

  Future<void> clearRecentSearches(String lang) async {
    final key = lang == 'en' ? _recentEngSearchesKey : _recentVieSearchesKey;
    await sf.remove(key);
  }

  Future<void> removeRecentSearch(String word, String lang) async {
    final key = lang == 'en' ? _recentEngSearchesKey : _recentVieSearchesKey;
    final recentSearches = sf.getStringList(key) ?? [];

    // Remove the word if it exists
    recentSearches.remove(word);

    await sf.setStringList(key, recentSearches);
  }

  Future<bool> isRecentSearch(String word, String lang) async {
    final key = lang == 'en' ? _recentEngSearchesKey : _recentVieSearchesKey;
    final recentSearches = sf.getStringList(key) ?? [];
    return recentSearches.contains(word);
  }
  // Favorites for English and Vietnamese words
  Future<void> saveFavorite(String word, String lang) async {
    final key = lang == 'en' ? _favoriteEngWordsKey : _favoriteVieWordsKey;
    final favorites = sf.getStringList(key) ?? [];

    // Remove the word if it already exists to avoid duplicates
    favorites.remove(word);
    // Insert the word at the beginning
    favorites.insert(0, word);

    // Keep only the first 100 items
    if (favorites.length > 100) {
      favorites.removeRange(100, favorites.length);
    }

    await sf.setStringList(key, favorites);
  }

  Future<List<String>?> getFavorites(String lang) async {
    final key = lang == 'en' ? _favoriteEngWordsKey : _favoriteVieWordsKey;
    return sf.getStringList(key);
  }

  Future<void> clearFavorites(String lang) async {
    final key = lang == 'en' ? _favoriteEngWordsKey : _favoriteVieWordsKey;
    await sf.remove(key);
  }

  Future<void> removeFavorite(String word, String lang) async {
    final key = lang == 'en' ? _favoriteEngWordsKey : _favoriteVieWordsKey;
    final favorites = sf.getStringList(key) ?? [];

    // Remove the word if it exists
    favorites.remove(word);

    await sf.setStringList(key, favorites);
  }

  Future<bool> isFavorite(String word, String lang) async {
    final key = lang == 'en' ? _favoriteEngWordsKey : _favoriteVieWordsKey;
    final favorites = sf.getStringList(key) ?? [];
    return favorites.contains(word);
  }
}
