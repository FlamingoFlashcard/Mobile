import 'package:lacquer/features/quiz/data/quiz_api_clients.dart';

class QuizRepository {
  final QuizApiClient quizApiClient;

  QuizRepository({required this.quizApiClient});

  Future<Map<String, String>> getRandomWord(
    int count,
    String difficulty,
  ) async {
    try {
      final response = await quizApiClient.getQuiz(
        lang: 'en',
        difficulty: difficulty,
        count: count,
      );
      return Map.fromEntries(
        response.data.vocabularies.map(
          (vocabulary) => MapEntry(
            vocabulary.word,
            vocabulary.wordTypes.isNotEmpty &&
                    vocabulary.wordTypes[0].definitions.isNotEmpty
                ? vocabulary.wordTypes[0].definitions.first
                : "",
          ),
        ),
      );
    } catch (e) {
      return {'error': 'Failed to fetch words: $e'};
    }
  }
}
