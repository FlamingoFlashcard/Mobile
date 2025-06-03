import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lacquer/config/theme.dart';
import 'package:lacquer/features/quiz/bloc/quiz_bloc.dart';
import 'package:lacquer/features/quiz/bloc/quiz_event.dart';
import 'package:lacquer/features/quiz/bloc/quiz_state.dart';
import 'package:lacquer/presentation/pages/home/widgets/quiz_questions_widget.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _numberOfQuestions = 10;
  int _numberOfChoices = 4;
  Difficulty _currentDifficulty = Difficulty.easy;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    var quizState = context.watch<QuizBloc>().state;
    var quizWidget = (switch (quizState) {
      QuizStateInitial() => _buildQuizMainScreen(),
      QuizStateLoading() => _buildQuizMainScreen(),
      QuizStateSuccess() => QuizQuestionsWidget(
        questions: quizState.questions,
        onBackToHome: _onQuitQuiz,
        difficulty: _currentDifficulty,
      ),
      QuizStateFailure() => _buildQuizMainScreen(),
    });
    quizWidget = BlocListener<QuizBloc, QuizState>(
      listener: (context, state) {
        switch (state) {
          case QuizStateLoading():
            setState(() {
              _isLoading = true;
            });
            break;
          case QuizStateFailure():
            setState(() {
              _isLoading = false;
            });
            _showErrorDialog(state.message);
            break;
          default:
            setState(() {
              _isLoading = false;
            });
            break;
        }
      },
      child: quizWidget,
    );

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
      child: Stack(
        children: [quizWidget, if (_isLoading) _buildLoadingScreenWidget()],
      ),
    );
  }

  void _showInformationDialog() async {
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

  void _showCustomDialog({required VoidCallback onConfirm}) async {
    int tempNumberOfQuestions = _numberOfQuestions;
    int tempNumberOfChoices = _numberOfChoices;

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: Colors.blueGrey.shade300,
                  width: 2,
                ), // Softer border
              ),
              elevation: 8,
              child: Container(
                constraints: BoxConstraints(maxWidth: 320), // Limit width
                padding: const EdgeInsets.all(24.0), // More padding
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header section
                    Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _currentDifficulty.color.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons
                                .tune, // More appropriate icon for customization
                            size: 32,
                            color: _currentDifficulty.color,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Customize Test',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Adjust your ${_currentDifficulty.name} test settings',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),

                    SizedBox(height: 24),

                    // Questions section
                    _buildSettingRow(
                      label: 'Number of questions',
                      icon: Icons.quiz_outlined,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: tempNumberOfQuestions,
                            isDense: true,
                            items:
                                [5, 10, 15, 20, 25, 30].map((value) {
                                  return DropdownMenuItem<int>(
                                    value: value,
                                    child: Text(
                                      value.toString(),
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  );
                                }).toList(),
                            onChanged: (int? newValue) {
                              setStateDialog(() {
                                tempNumberOfQuestions = newValue!;
                              });
                            },
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 16),

                    // Choices section
                    _buildSettingRow(
                      label: 'Number of choices',
                      icon: Icons.format_list_bulleted,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: tempNumberOfChoices,
                            isDense: true,
                            items:
                                [2, 3, 4, 5, 6].map((value) {
                                  return DropdownMenuItem<int>(
                                    value: value,
                                    child: Text(
                                      value.toString(),
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  );
                                }).toList(),
                            onChanged: (int? newValue) {
                              setStateDialog(() {
                                tempNumberOfChoices = newValue!;
                              });
                            },
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 32),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _numberOfQuestions = tempNumberOfQuestions;
                                _numberOfChoices = tempNumberOfChoices;
                              });
                              Navigator.pop(context);
                              _onStartQuiz();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _currentDifficulty.color,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 2,
                            ),
                            child: Text(
                              'Apply',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSettingRow({
    required String label,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey.shade600),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        child,
      ],
    );
  }

  void _showErrorDialog(String message) async {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.red, width: 5),
          ),
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  children: [
                    Icon(Icons.error, size: 48, color: Colors.red),
                    SizedBox(height: 8),
                    Text(
                      'Quiz Generate Failure:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text('Error: $message', textAlign: TextAlign.center),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Return'),
                ),
              ],
            ),
          ),
        );
      },
    );
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
                _buildDifficultyBox(
                  Difficulty.easy,
                  () => _showCustomDialog(
                    onConfirm: () => {_onConfirmCustom(Difficulty.easy)},
                  ),
                ),
                _buildDifficultyBox(
                  Difficulty.intermediate,
                  () => _showCustomDialog(
                    onConfirm:
                        () => {_onConfirmCustom(Difficulty.intermediate)},
                  ),
                ),
                _buildDifficultyBox(
                  Difficulty.hard,
                  () => _showCustomDialog(
                    onConfirm: () => {_onConfirmCustom(Difficulty.hard)},
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDifficultyBox(
                  Difficulty.TOEIC,
                  () => _showCustomDialog(
                    onConfirm: () => {_onConfirmCustom(Difficulty.TOEIC)},
                  ),
                ),
                _buildDifficultyBox(
                  Difficulty.IELTS,
                  () => _showCustomDialog(
                    onConfirm: () => {_onConfirmCustom(Difficulty.IELTS)},
                  ),
                ),
              ],
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => _showErrorDialog('An error occurred'),
            ),
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
              child: Image.asset(
                'assets/icons/test.png',
                width: 50,
                height: 50,
              ),
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

  void _onConfirmCustom(Difficulty difficulty) {
    print("Difficult press: ${difficulty.name}");
  }

  void _onStartQuiz() {
    context.read<QuizBloc>().add(
      QuizEventLoadQuestions(
        numberOfQuestions: _numberOfQuestions,
        numverOfOptions: _numberOfChoices,
        difficulty: _currentDifficulty.parameter,
        language: "en",
      ),
    );
  }

  void _onQuitQuiz() {
    context.read<QuizBloc>().add(QuizEventBack());
  }

  Widget _buildLoadingScreenWidget() {
    return Stack(
      children: [
        ModalBarrier(
          dismissible: false,
          color: Colors.black.withValues(alpha: 0.3),
        ),
        Center(child: CircularProgressIndicator()),
      ],
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

  String get parameter {
    switch (this) {
      case Difficulty.easy:
        return "easy";
      case Difficulty.intermediate:
        return "intermediate";
      case Difficulty.hard:
        return "hard";
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
