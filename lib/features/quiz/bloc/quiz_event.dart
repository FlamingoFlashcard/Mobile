class QuizEvent {}

class QuizEventStarted extends QuizEvent {}

class QuizEventLoadQuestions extends QuizEvent {
  final int numberOfQuestions;
  final int numverOfOptions;
  final String difficulty;
  final String language;

  QuizEventLoadQuestions({
    required this.numberOfQuestions,
    required this.numverOfOptions,
    required this.difficulty,
    required this.language,
  });
}

class QuizEventBack extends QuizEvent {}