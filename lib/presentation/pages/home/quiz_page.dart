import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lacquer/config/theme.dart';
import 'package:lacquer/features/quiz/bloc/quiz_bloc.dart';
import 'package:lacquer/features/quiz/bloc/quiz_state.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _numberOfQuestions = 10;
  int _numberOfChoices = 4;
  Color _themeQuestionColor = Colors.black;
  Difficulty _currentDifficulty = Difficulty.easy;

  @override
  Widget build(BuildContext context) {
    var quizState = context.watch<QuizBloc>().state;
    var quizWidget = (switch (quizState) {
      QuizStateInitial() => _buildQuizMainScreen(),
      QuizStateLoading() => _buildQuizMainScreen(),
      QuizStateFailure() => _buildQuizMainScreen(),
      QuizStateSuccess() => _buildQuizMainScreen(),
    });

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            CustomTheme.loginGradientStart,
            CustomTheme.loginGradientEnd,
          ],
          begin: FractionalOffset(0.5, 0.0),
          end: FractionalOffset(0.5, 1.0),
          stops: <double>[0.0, 1.0],
          tileMode: TileMode.clamp,
        ),
      ),
      child: quizWidget,
    );
  }

  Future<void> _showInformationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue, size: 28),
              SizedBox(width: 8),
              Text(
                'Quiz Rules',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Please read the following rules carefully before starting:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                _buildRuleItem(
                  icon: Icons.timer,
                  title: 'Time Limit',
                  description: 'Each question has a 30-second time limit',
                ),
                const SizedBox(height: 12),
                _buildRuleItem(
                  icon: Icons.radio_button_checked,
                  title: 'Multiple Choice',
                  description: 'Select one answer from the given options',
                ),
                const SizedBox(height: 12),
                _buildRuleItem(
                  icon: Icons.star,
                  title: 'Scoring',
                  description:
                      'Correct answer: +10 points\nIncorrect answer: 0 points',
                ),
                const SizedBox(height: 12),
                _buildRuleItem(
                  icon: Icons.block,
                  title: 'No Going Back',
                  description:
                      'Once you submit an answer, you cannot change it',
                ),
                const SizedBox(height: 12),
                _buildRuleItem(
                  icon: Icons.leaderboard,
                  title: 'Final Score',
                  description: 'Your total score will be displayed at the end',
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    border: Border.all(color: Colors.amber.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Colors.amber,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Take your time to read each question carefully before selecting your answer.',
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Add logic to start the quiz here
                // _startQuiz();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Understand',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRuleItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.blue, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showExitQuizDialog() async {
    return;
  }

  Future<void> _showCustomDialog() async {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(
        0.5,
      ),
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: _currentDifficulty.color,
              width: 5,
            ),
          ),
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon ở giữa tiêu đề
                Column(
                  children: [
                    Icon(Icons.info_outline, size: 48, color: _currentDifficulty.color),
                    SizedBox(height: 8),
                    Text(
                      'Thông báo',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  'Adjust your ${_currentDifficulty.name} Test:',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Đóng'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showErrorDialog() async {
    return;
  }

  Widget _buildQuizMainScreen() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Row(
          children: [
            Text("Quiz"),
            IconButton(
              onPressed: () {
                context.go('/');
              },
              icon: Icon(Icons.turn_left),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Container(
                  decoration: BoxDecoration(),
                  child: IconButton(
                    onPressed: _showInformationDialog,
                    icon: Icon(
                      Icons.info_outline,
                      color: CustomTheme.mainColor1,
                    ),
                  ),
                ),
              ),
            ),
            _buildMainTitle(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDifficultyBox(Difficulty.easy, _showCustomDialog),
                _buildDifficultyBox(Difficulty.intermediate, _showCustomDialog),
                _buildDifficultyBox(Difficulty.hard, _showCustomDialog),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDifficultyBox(Difficulty.TOEIC, _showCustomDialog),
                _buildDifficultyBox(Difficulty.IELTS, _showCustomDialog),
              ],
            ),
            IconButton(icon: Icon(Icons.add), onPressed: _showCustomDialog),
            
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyBox(Difficulty difficulty, VoidCallback onPress) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentDifficulty = difficulty;
          });
          onPress();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: difficulty.gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: difficulty.color.withOpacity(0.8),
              width: 4,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: difficulty.color.withOpacity(0.3),
                offset: const Offset(0, 4),
                blurRadius: 8,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, 2),
                blurRadius: 4,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Text(
            difficulty.name,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              letterSpacing: 0.5,
              fontFamily: GoogleFonts.roboto().fontFamily,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainTitle() {
    return Flexible(
      child: SizedBox(
        height: 250,
        child: Column(
          children: [
            Align(
              alignment: Alignment.center,
              child: Image.asset('assets/icons/test.png', width: 50, height: 50),
            ),
            Text(
              'Challenges with\nvarying levels of\ndifficulty!',
              style: GoogleFonts.poppins(
                fontSize: 45,
                fontWeight: FontWeight.w600,
                foreground:
                    Paint()
                      ..shader = LinearGradient(
                        colors: <Color>[Colors.orange, Colors.brown],
                      ).createShader(Rect.fromLTWH(0.0, 0.0, 300.0, 70.0)),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: constant_identifier_names
enum Difficulty { easy, intermediate, hard, TOEIC, IELTS }

extension DifficultyItem on Difficulty {
  String get name {
    switch (this) {
      case Difficulty.easy:
        return "Easy";
      case Difficulty.intermediate:
        return "Intermediate";
      case Difficulty.hard:
        return "Hard";
      case Difficulty.TOEIC:
        return "TOEIC";
      case Difficulty.IELTS:
        return "IELTS";
    }
  }

  Color get color {
    switch (this) {
      case Difficulty.easy:
        return Colors.green;
      case Difficulty.intermediate:
        return Colors.orange;
      case Difficulty.hard:
        return Colors.red;
      case Difficulty.TOEIC:
        return Colors.purple;
      case Difficulty.IELTS:
        return Colors.indigo;
    }
  }

  List<Color> get gradientColors {
    switch (this) {
      case Difficulty.easy:
        return [Colors.green.shade300, Colors.green.shade600];
      case Difficulty.intermediate:
        return [Colors.orange.shade300, Colors.orange.shade600];
      case Difficulty.hard:
        return [Colors.red.shade300, Colors.red.shade600];
      case Difficulty.TOEIC:
        return [Colors.purple.shade300, Colors.purple.shade600];
      case Difficulty.IELTS:
        return [Colors.indigo.shade300, Colors.indigo.shade600];
    }
  }
}
