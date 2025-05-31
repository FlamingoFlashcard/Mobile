import 'package:flutter/material.dart';
import 'package:lacquer/config/theme.dart';

class DictionaryLanguageSwitch extends StatefulWidget {
  final bool isEngToVie;
  final Function(bool isEngToVie) onLanguageChanged;

  const DictionaryLanguageSwitch({
    super.key,
    required this.isEngToVie,
    required this.onLanguageChanged,
  });

  @override
  State<DictionaryLanguageSwitch> createState() =>
      _DictionaryLanguageSwitchState();
}

class _DictionaryLanguageSwitchState extends State<DictionaryLanguageSwitch>
    with SingleTickerProviderStateMixin {
  late bool isEngToVie;
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    isEngToVie = widget.isEngToVie;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    if (!isEngToVie) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant DictionaryLanguageSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEngToVie != isEngToVie) {
      setState(() {
        isEngToVie = widget.isEngToVie;
        if (isEngToVie) {
          _animationController.reverse();
        } else {
          _animationController.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleLanguage() {
    final newValue = !isEngToVie;
    widget.onLanguageChanged(newValue);
    // The state will be updated via didUpdateWidget when parent updates isEngToVie
  }

  @override
  Widget build(BuildContext context) {
    // Reduced sizes
    const double width = 100;
    const double height = 40;
    const double flagSize = 25;
    const double iconSize = 18;

    return Container(
      padding: const EdgeInsets.only(top: 20, right: 10, left: 2),
      child: GestureDetector(
        onTap: _toggleLanguage,
        child: Column(
          children: [
            Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(height / 2),
                gradient: LinearGradient(
                  colors: isEngToVie
                      ? [Colors.blue, Colors.red]
                      : [Colors.red, Colors.blue],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: AnimatedBuilder(
                animation: _rotationAnimation,
                builder: (context, child) {
                  return Center(
                    child: Transform.rotate(
                      angle: _rotationAnimation.value * 3.14159,
                      child: Container(
                        width: width - 8,
                        height: height - 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(height / 2),
                          color: Colors.white38,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildFlag('🇬🇧', flagSize),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.swap_horiz,
                                size: iconSize,
                                color: isEngToVie
                                    ? Colors.blue[600]
                                    : Colors.red[600],
                              ),
                            ),
                            _buildFlag('🇻🇳', flagSize),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Text(
              isEngToVie ? 'Eng → Vie' : 'Vie → Eng',
              style: TextStyle(
                fontSize: 14,
                color: isEngToVie ? Colors.blue[600] : Colors.red[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlag(String emoji, double size) {
    return SizedBox(
      width: size,
      height: size,
      child: Center(child: Text(emoji, style: TextStyle(fontSize: size * 0.7))),
    );
  }
}
