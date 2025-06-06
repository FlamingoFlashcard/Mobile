import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:lacquer/config/router.dart';
import 'package:lacquer/config/theme.dart';
import 'package:lacquer/features/flashcard/bloc/flashcard_bloc.dart';
import 'package:lacquer/features/flashcard/bloc/flashcard_event.dart';
import 'package:lacquer/features/flashcard/bloc/flashcard_state.dart';
import 'package:lacquer/presentation/pages/home/widgets/learning_card_list.dart';
import 'package:lacquer/presentation/pages/home/widgets/speech_adjustment.dart';

class LearningFlashcardPage extends StatefulWidget {
  final String deckId;
  const LearningFlashcardPage({super.key, required this.deckId});
  @override
  State<LearningFlashcardPage> createState() => _LearningFlashcardPageState();
}

class _LearningFlashcardPageState extends State<LearningFlashcardPage> {
  double _progress = 0.0;
  double _speechRate = 0.5;
  String _selectedAccent = 'en-US';
  @override
  void initState() {
    super.initState();
    context.read<FlashcardBloc>().add(LoadDeckByIdRequested(widget.deckId));
  }

  void _updateProgress(double progress) {
    setState(() {
      _progress = progress.clamp(0.0, 1.0);
    });
  }

  void _showTtsSettings() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder:
          (context) => SpeechAdjustment(
            initialSpeed: _speechRate,
            initialAccent:
                _accents.entries
                    .firstWhere(
                      (entry) => entry.value == _selectedAccent,
                      orElse: () => const MapEntry('US English', 'en-US'),
                    )
                    .key,
          ),
    );
    if (result != null) {
      setState(() {
        _speechRate = result['speed'] as double;
        _selectedAccent = result['accent'] as String;
      });
    }
  }

  static final Map<String, String> _accents = {
    'US English': 'en-US',
    'UK English': 'en-GB',
    'Australian': 'en-AU',
    'Indian': 'en-IN',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.lightbeige,
      body: BlocBuilder<FlashcardBloc, FlashcardState>(
        builder: (context, state) {
          if (state.status == FlashcardStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.status == FlashcardStatus.failure) {
            return Center(
              child: Text('Error: ${state.errorMessage ?? 'Unknown error'}'),
            );
          } else if (state.status == FlashcardStatus.success &&
              state.selectedDeck != null) {
            final deck = state.selectedDeck!;
            return Stack(
              children: [
                _buildAppBar(context, deck.title),
                Column(
                  children: [
                    const SizedBox(height: 100),
                    if (deck.cards != null && deck.cards!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 200,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4.0),
                                child: LinearProgressIndicator(
                                  value: _progress,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    const Color.fromARGB(255, 104, 175, 106),
                                  ),
                                  minHeight: 12.0,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${(_progress * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child:
                          (deck.cards == null || deck.cards!.isEmpty)
                              ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.menu_book_outlined,
                                        size: 80,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'No cards yet',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Start by adding your first card to this deck.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black45,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      ElevatedButton.icon(
                                        onPressed:
                                            () => context.go(
                                              RouteName.addNewWord(
                                                widget.deckId,
                                              ),
                                            ),
                                        icon: const Icon(
                                          Icons.add,
                                          color: Colors.white,
                                        ),
                                        label: const Text('Add New Card'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              CustomTheme.mainColor1,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              : LearningCardList(
                                deckId: widget.deckId,
                                cards: deck.cards!,
                                onScrollProgress: _updateProgress,
                                speechRate: _speechRate,
                                selectedAccent: _selectedAccent,
                                isDone: deck.isDone ?? false,
                              ),
                    ),
                  ],
                ),
              ],
            );
          }
          return const Center(child: Text('No deck data available'));
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, String? title) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(8),
        bottomRight: Radius.circular(8),
      ),
      child: Container(
        height: 90,
        color: CustomTheme.mainColor1,
        padding: const EdgeInsets.only(top: 30),
        child: Center(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(
                  FontAwesomeIcons.arrowLeft,
                  color: Colors.white,
                ),
                onPressed: () {
                  context.go(RouteName.flashcards);
                },
              ),
              Text(
                title ?? '',
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 15),
              const Spacer(),
              IconButton(
                icon: const Icon(FontAwesomeIcons.gear, color: Colors.white),
                onPressed: _showTtsSettings,
              ),
              IconButton(
                icon: const Icon(
                  FontAwesomeIcons.ellipsisVertical,
                  color: Colors.white,
                ),
                onPressed: null,
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }
}
