import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lacquer/config/theme.dart';
import 'package:lacquer/features/flashcard/dtos/card_dto.dart';
import 'package:lacquer/presentation/utils/wave_clipper.dart';

class ReviseCard extends StatefulWidget {
  final CardDto card;
  final double speechRate;
  final String selectedAccent;

  const ReviseCard({
    super.key,
    required this.card,
    required this.speechRate,
    required this.selectedAccent,
  });

  @override
  State<ReviseCard> createState() => _ReviseCardState();
}

class _ReviseCardState extends State<ReviseCard> {
  late FlutterTts flutterTts;
  bool _showMeaning = false;
  int _countdown = 5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    flutterTts = FlutterTts();
    _initializeTts();

    _startCountdownTimer();
  }

  void _startCountdownTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown <= 1) {
        timer.cancel();
        if (mounted) {
          setState(() {
            _countdown = 0;
            _showMeaning = true;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _countdown--;
          });
        }
      }
    });
  }

  Future<void> _initializeTts() async {
    await flutterTts.setLanguage(widget.selectedAccent);
    await flutterTts.setSpeechRate(widget.speechRate);
    await flutterTts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage(widget.selectedAccent);
    await flutterTts.setSpeechRate(widget.speechRate);
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  @override
  void dispose() {
    flutterTts.stop();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 0),
        child: Container(
          width: size.width - 50,
          height: size.height - 180,
          decoration: BoxDecoration(
            color: CustomTheme.flashcardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color.fromRGBO(0, 0, 0, 0.2),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildTop(card: widget.card, size: size),
              _buildMeaning(card: widget.card),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTop({required CardDto card, required Size size}) {
    return ClipPath(
      clipper: WaveClipper(),
      child: Container(
        height: (size.height - 180) / 2,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    card.word ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  if ((card.pronunciation ?? '').isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      '[${card.pronunciation}]',
                      style: const TextStyle(
                        fontSize: 20,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Positioned(
              bottom: 24,
              right: 12,
              child: IconButton(
                onPressed: () {
                  if ((card.word ?? '').isNotEmpty) {
                    _speak(card.word!);
                  }
                },
                icon: const Icon(
                  FontAwesomeIcons.volumeHigh,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeaning({required CardDto card}) {
    final blurValue = _showMeaning ? 0.0 : 10.0;

    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: CustomTheme.flashcardColor,
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (card.meaning?.type?.isNotEmpty ?? false)
                    ImageFiltered(
                      imageFilter: ImageFilter.blur(
                        sigmaX: blurValue,
                        sigmaY: blurValue,
                      ),
                      child: Text(
                        card.meaning!.type!,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  if (card.meaning?.definition?.isNotEmpty ?? false)
                    ImageFiltered(
                      imageFilter: ImageFilter.blur(
                        sigmaX: blurValue,
                        sigmaY: blurValue,
                      ),
                      child: Text(
                        card.meaning!.definition!,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton.icon(
                onPressed:
                    _showMeaning
                        ? null
                        : () {
                          setState(() {
                            _showMeaning = true;
                            _timer?.cancel();
                          });
                        },
                icon: const Icon(Icons.visibility, color: Colors.white),
                label: Text(
                  _showMeaning ? 'Shown' : 'Show (${_countdown}s)',
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 141, 188, 24),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
