class QuizRequestDto {
  final String lang;
  final String difficulty;
  final int count;

  QuizRequestDto({
    required this.lang,
    required this.difficulty,
    required this.count,
  });
}
