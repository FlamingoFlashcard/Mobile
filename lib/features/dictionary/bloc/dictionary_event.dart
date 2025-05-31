class DictionaryEvent {}

class DictionaryEventStarted extends DictionaryEvent {}

class DictionaryEventLoadMainScreen extends DictionaryEvent {
  DictionaryEventLoadMainScreen({required this.lang});

  final String lang;
}

class DictionaryEventSearch extends DictionaryEvent {
  DictionaryEventSearch({required this.query, required this.lang});

  final String query;
  final String lang;
}

class DictionaryEventSuggestions extends DictionaryEvent {
  DictionaryEventSuggestions({required this.prefix, required this.lang});

  final String prefix;
  final String lang;
}

class DictionaryEventGetWord extends DictionaryEvent {
  DictionaryEventGetWord({required this.word, required this.lang});

  final String word;
  final String lang;
}

class DictionaryEventToggleFavorite extends DictionaryEvent {
  DictionaryEventToggleFavorite({required this.word, required this.lang, required this.isFavorite});

  final String word;
  final String lang;
  final bool isFavorite;
}

class DictionaryEventSaveRecentSearch extends DictionaryEvent {
  DictionaryEventSaveRecentSearch({required this.word, required this.lang});

  final String word;
  final String lang;
}
class DictionaryEventRemoveRecentSearch extends DictionaryEvent {
  DictionaryEventRemoveRecentSearch({required this.word, required this.lang});

  final String word;
  final String lang;
}
