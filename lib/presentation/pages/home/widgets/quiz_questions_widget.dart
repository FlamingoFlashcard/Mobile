import 'package:flutter/material.dart';
import 'package:lacquer/features/quiz/bloc/quiz_state.dart';
import 'package:lacquer/presentation/pages/home/quiz_page.dart';

class QuizQuestionsWidget extends StatefulWidget {
  final List<Question> questions;
  final VoidCallback onBackToHome;
  final Difficulty difficulty;

  const QuizQuestionsWidget({
    super.key,
    required this.questions,
    required this.onBackToHome,
    required this.difficulty,
  });

  @override
  State<QuizQuestionsWidget> createState() => _QuizQuestionsWidget();
}

class _QuizQuestionsWidget extends State<QuizQuestionsWidget> {
  int currentQuestionIndex = 0;
  int score = 0;
  String? selectedAnswer;
  bool hasSubmitted = false;
  bool showResult = false;

  Question get currentQuestion => widget.questions[currentQuestionIndex];
  bool get isLastQuestion =>
      currentQuestionIndex == widget.questions.length - 1;

  void selectAnswer(String answer) {
    if (!hasSubmitted) {
      setState(() {
        selectedAnswer = answer;
      });
    }
  }

  void submitAnswer() {
    if (selectedAnswer == null) return;

    setState(() {
      hasSubmitted = true;
      if (selectedAnswer == currentQuestion.answer) {
        score++;
      }
    });
  }

  void nextQuestion() {
    if (isLastQuestion) {
      setState(() {
        showResult = true;
      });
    } else {
      setState(() {
        currentQuestionIndex++;
        selectedAnswer = null;
        hasSubmitted = false;
      });
    }
  }

  void tryAgain() {
    setState(() {
      currentQuestionIndex = 0;
      score = 0;
      selectedAnswer = null;
      hasSubmitted = false;
      showResult = false;
    });
  }

  Color getOptionColor(String option) {
    if (!hasSubmitted) {
      return selectedAnswer == option
          ? Colors.blue.shade100
          : Colors.grey.shade100;
    }

    if (option == currentQuestion.answer) {
      return Colors.green.shade100;
    } else if (option == selectedAnswer && option != currentQuestion.answer) {
      return Colors.red.shade100;
    }
    return Colors.grey.shade100;
  }

  Color getOptionBorderColor(String option) {
    if (!hasSubmitted) {
      return selectedAnswer == option ? Colors.blue : Colors.grey.shade300;
    }

    if (option == currentQuestion.answer) {
      return Colors.green;
    } else if (option == selectedAnswer && option != currentQuestion.answer) {
      return Colors.red;
    }
    return Colors.grey.shade300;
  }

  IconData? getOptionIcon(String option) {
    if (!hasSubmitted) return null;

    if (option == currentQuestion.answer) {
      return Icons.check_circle;
    } else if (option == selectedAnswer && option != currentQuestion.answer) {
      return Icons.cancel;
    }
    return null;
  }

  Color? getOptionIconColor(String option) {
    if (!hasSubmitted) return null;

    if (option == currentQuestion.answer) {
      return Colors.green;
    } else if (option == selectedAnswer && option != currentQuestion.answer) {
      return Colors.red;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (showResult) {
      return _buildResultScreen();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Question ${currentQuestionIndex + 1} of ${widget.questions.length}',
        ),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (currentQuestionIndex + 1) / widget.questions.length,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
            ),
            const SizedBox(height: 30),

            // Question
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  currentQuestion.definition,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Options
            Expanded(
              child: ListView.builder(
                itemCount: currentQuestion.options.length,
                itemBuilder: (context, index) {
                  final option = currentQuestion.options[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: GestureDetector(
                      onTap: () => selectAnswer(option),
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: getOptionColor(option),
                          border: Border.all(
                            color: getOptionBorderColor(option),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                option,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            if (getOptionIcon(option) != null)
                              Icon(
                                getOptionIcon(option),
                                color: getOptionIconColor(option),
                                size: 24,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Action buttons
            if (!hasSubmitted)
              ElevatedButton(
                onPressed: selectedAnswer != null ? submitAnswer : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Submit Answer',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              )
            else
              ElevatedButton(
                onPressed: nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  isLastQuestion ? 'View Results' : 'Next Question',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    final percentage = (score / widget.questions.length * 100).round();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Trophy icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.emoji_events,
                    size: 80,
                    color: Colors.yellow.shade700,
                  ),
                ),
                const SizedBox(height: 30),

                // Title
                const Text(
                  'Quiz Completed!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),

                // Score card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      children: [
                        Text(
                          'Your Score',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '$score/${widget.questions.length}',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade600,
                          ),
                        ),
                        Text(
                          '$percentage%',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Action buttons
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: tryAgain,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Try Again',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: widget.onBackToHome,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Colors.blue.shade600,
                            width: 2,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Back to Home',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
