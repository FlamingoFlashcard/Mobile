import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lacquer/presentation/utils/languages.dart';
import 'package:go_router/go_router.dart';

class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({super.key});

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen>
    with TickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _outputScrollController = ScrollController();
  String _translatedText = '';
  String _sourceLang = 'en';
  String _targetLang = 'vi';
  bool _isLoading = false;
  bool _isOutputExpanded = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _swapController;
  late Animation<double> _rotationAnimation;
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _swapController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _swapController, curve: Curves.easeInOut),
    );

    _expandController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _expandAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _expandController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _swapController.dispose();
    _expandController.dispose();
    _outputScrollController.dispose();
    super.dispose();
  }

  Future<void> translateText() async {
    if (_inputController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final uri = Uri.parse('https://lacquer-server.onrender.com/translate');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'text': _inputController.text,
          'source': _sourceLang,
          'target': _targetLang,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonRes = jsonDecode(response.body);
        if (jsonRes['success'] == true) {
          setState(() {
            _translatedText =
                jsonRes['data']['translatedText'] ?? 'No translation found';
          });
          _animationController.forward();

          // Auto-expand if text is long (more than 200 characters)
          if (_translatedText.length > 200) {
            Future.delayed(const Duration(milliseconds: 600), () {
              setState(() {
                _isOutputExpanded = true;
              });
              _expandController.forward();
            });
          }
        } else {
          setState(() {
            _translatedText = 'Error: ${jsonRes['message']}';
          });
        }
      } else {
        setState(() {
          _translatedText =
              'Request failed with status: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _translatedText = 'Network error: Please check your connection';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _swapLanguages() async {
    _swapController.forward().then((_) => _swapController.reverse());

    setState(() {
      final tempLang = _sourceLang;
      _sourceLang = _targetLang;
      _targetLang = tempLang;

      if (_translatedText.trim().isNotEmpty) {
        _inputController.text = _translatedText;
        _translatedText = '';
        _animationController.reset();
      }
    });

    if (_inputController.text.trim().isNotEmpty) {
      await translateText();
    }
  }

  void _copyToClipboard(String text) {
    if (text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Copied to clipboard'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _clearText() {
    setState(() {
      _inputController.clear();
      _translatedText = '';
      _isOutputExpanded = false;
      _animationController.reset();
      _expandController.reset();
    });
  }

  void _toggleOutputExpand() {
    setState(() {
      _isOutputExpanded = !_isOutputExpanded;
    });

    if (_isOutputExpanded) {
      _expandController.forward();
    } else {
      _expandController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Nút quay lại
                      GestureDetector(
                        onTap: () => context.go('/'),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(255, 255, 255, 0.2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Nội dung chính giữa
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(255, 255, 255, 0.2),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(
                              Icons.translate,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Smart Translator',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(), // Để giữ căn giữa khi có nút Back bên trái
                    ],
                  ),
                ),

                // Language Selection
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(255, 255, 255, 0.95),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildModernLangDropdown(_sourceLang, (val) {
                          setState(() => _sourceLang = val!);
                        }),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: RotationTransition(
                          turns: _rotationAnimation,
                          child: GestureDetector(
                            onTap: _swapLanguages,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(63, 81, 181, 0.1),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Icon(
                                Icons.swap_horiz,
                                color: Colors.indigo,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: _buildModernLangDropdown(_targetLang, (val) {
                          setState(() => _targetLang = val!);
                        }),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Input Container
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Input Section
                        Flexible(
                          flex: 3,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.1),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.edit,
                                        color: Colors.grey.shade600,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        languages.firstWhere(
                                          (e) => e['code'] == _sourceLang,
                                        )['name']!,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      const Spacer(),
                                      if (_inputController.text.isNotEmpty)
                                        GestureDetector(
                                          onTap: _clearText,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade300,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: const Icon(
                                              Icons.clear,
                                              size: 16,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: TextField(
                                      controller: _inputController,
                                      maxLines: null,
                                      expands: true,
                                      textAlignVertical: TextAlignVertical.top,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        height: 1.5,
                                      ),
                                      decoration:
                                          const InputDecoration.collapsed(
                                            hintText:
                                                'Enter text to translate...',
                                            hintStyle: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 16,
                                            ),
                                          ),
                                      onChanged: (text) {
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Translate Button
                        Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.indigo, Colors.purple],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromRGBO(63, 81, 181, 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap:
                                  _inputController.text.trim().isEmpty ||
                                          _isLoading
                                      ? null
                                      : translateText,
                              child: Center(
                                child:
                                    _isLoading
                                        ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                        : const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.translate,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'Translate',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Output Section
                        Flexible(
                          flex: 3,
                          child: AnimatedBuilder(
                            animation: _expandAnimation,
                            builder: (context, child) {
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                constraints: BoxConstraints(
                                  minHeight: 120,
                                  maxHeight:
                                      _isOutputExpanded
                                          ? MediaQuery.of(context).size.height *
                                              0.35
                                          : 200,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color.fromRGBO(0, 0, 0, 0.1),
                                        blurRadius: 15,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade50,
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(20),
                                              ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.language,
                                              color: Colors.green.shade600,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              languages.firstWhere(
                                                (e) => e['code'] == _targetLang,
                                              )['name']!,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.green.shade700,
                                              ),
                                            ),
                                            const Spacer(),
                                            if (_translatedText.isNotEmpty) ...[
                                              // Expand/Collapse button
                                              GestureDetector(
                                                onTap: _toggleOutputExpand,
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    8,
                                                  ),
                                                  margin: const EdgeInsets.only(
                                                    right: 8,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue.shade100,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                  child: AnimatedRotation(
                                                    turns:
                                                        _isOutputExpanded
                                                            ? 0.5
                                                            : 0,
                                                    duration: const Duration(
                                                      milliseconds: 300,
                                                    ),
                                                    child: Icon(
                                                      Icons.expand_more,
                                                      size: 16,
                                                      color:
                                                          Colors.blue.shade600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // Copy button
                                              GestureDetector(
                                                onTap:
                                                    () => _copyToClipboard(
                                                      _translatedText,
                                                    ),
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    8,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        Colors.green.shade100,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                  child: Icon(
                                                    Icons.copy,
                                                    size: 16,
                                                    color:
                                                        Colors.green.shade600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(20),
                                          child:
                                              _translatedText.isEmpty
                                                  ? Center(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .translate_outlined,
                                                          size: 40,
                                                          color:
                                                              Colors
                                                                  .grey
                                                                  .shade400,
                                                        ),
                                                        const SizedBox(
                                                          height: 12,
                                                        ),
                                                        Text(
                                                          'Translation will appear here',
                                                          style: TextStyle(
                                                            color:
                                                                Colors
                                                                    .grey
                                                                    .shade500,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                  : FadeTransition(
                                                    opacity: _fadeAnimation,
                                                    child: Scrollbar(
                                                      controller:
                                                          _outputScrollController,
                                                      thumbVisibility:
                                                          _isOutputExpanded,
                                                      child: SingleChildScrollView(
                                                        controller:
                                                            _outputScrollController,
                                                        child: SizedBox(
                                                          width:
                                                              double.infinity,
                                                          child: Text(
                                                            _translatedText,
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 16,
                                                                  height: 1.5,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                        ),
                                      ),
                                      // Word count indicator for long text
                                      if (_translatedText.isNotEmpty &&
                                          _translatedText.length > 100)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 6,
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.info_outline,
                                                size: 12,
                                                color: Colors.grey.shade500,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${_translatedText.split(' ').length} words • ${_translatedText.length} characters',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey.shade500,
                                                ),
                                              ),
                                              const Spacer(),
                                              if (_translatedText.length >
                                                      200 &&
                                                  !_isOutputExpanded)
                                                Text(
                                                  'Tap ↑ to expand',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.blue.shade600,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernLangDropdown(
    String selected,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
          style: TextStyle(
            color: Colors.grey.shade800,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          items:
              languages.map((lang) {
                return DropdownMenuItem<String>(
                  value: lang['code'],
                  child: Text(lang['name']!),
                );
              }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
