sealed class QuizState {}

class QuizStateInitial extends QuizState {}

class QuizStateLoading extends QuizState {}

class QuizStateSuccess extends QuizState {
  final int count;
  final List<Question> questions;

  QuizStateSuccess({required this.count, required this.questions});
}

class QuizStateFailure extends QuizState {
  final String message;

  QuizStateFailure(this.message);
}

class Question {
  final String definition;
  final String answer;
  final List<String> options;

  Question({
    required this.definition,
    required this.answer,
    required this.options,
  });
}
