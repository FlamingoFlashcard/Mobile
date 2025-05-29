abstract class SearchDto {
  final String lang;

  SearchDto(this.lang);
}

class SearchPrefixDto extends SearchDto {
  final String prefix;

  SearchPrefixDto(super.lang, this.prefix);
}

class SearchWordDto extends SearchDto {
  final String word;

  SearchWordDto(super.lang, this.word);
}

class SearchQueryDto extends SearchDto {
  final String query;

  SearchQueryDto(super.lang, this.query);
}


