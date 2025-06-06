import 'package:shared_preferences/shared_preferences.dart';

class DictionaryLocalDataSource {
  final SharedPreferences sf;

  DictionaryLocalDataSource(this.sf);

  static const String _recentEngSearchesKey = 'recent_en_searches';
  static const String _recentVieSearchesKey = 'recent_vn_searches';


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

  Future<void> removeRecentSearch(String word, String lang) async {
    final key = lang == 'en' ? _recentEngSearchesKey : _recentVieSearchesKey;
    final recentSearches = sf.getStringList(key) ?? [];

    // Remove the word if it exists
    recentSearches.remove(word);

    await sf.setStringList(key, recentSearches);
  }
}
