import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:lacquer/config/theme.dart';
import 'package:lacquer/presentation/pages/home/widgets/dictionary_eng_vie_switch.dart';

class Dictionarypage extends StatefulWidget {
  const Dictionarypage({super.key});

  @override
  State<Dictionarypage> createState() => _DicitionarypageState();
}

class _DicitionarypageState extends State<Dictionarypage> {
  bool isEngToVie = true; // true for Eng->Vie, false for Vie->Eng
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  List<String> recentSearches = [
    'hello',
    'world',
    'flutter',
    'dictionary',
    'example',
    'search',
    'language',
    'translation',
    'mobile app',
    'development',
  ];
  List<String> favoriteWords = [
    'flutter',
    'dictionary',
    'example',
    'search',
    'language',
    'translation',
    'mobile app',
    'development',
  ];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _showSuggestions = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        context.go('/');
      },
      child: Scaffold(
        backgroundColor: CustomTheme.lightbeige,
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildAppBar(context),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildSearchBar()),
                  DictionaryLanguageSwitch(
                    onLanguageChanged: (isEngToVie) {
                      setState(() {
                        this.isEngToVie = isEngToVie;
                        _searchController
                            .clear(); // Clear search when switching
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildTitle(
                isEngToVie ? 'Recent Searches' : 'Tìm kiếm gần đây',
                icon: FontAwesomeIcons.history,
              ),
              _buildRecentSearches(),
              const SizedBox(height: 20),
              _buildTitle(
                isEngToVie ? 'Favorite Words' : 'Từ yêu thích',
                icon: FontAwesomeIcons.solidHeart,
              ),
              _buildFavoriteWords(),
              const SizedBox(height: 20),
              // Placeholder for dictionary content
              Center(
                child: Text(
                  'Dictionary content goes here',
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        focusNode: _focusNode,
        controller: _searchController,
        decoration: InputDecoration(
          hintText:
              isEngToVie
                  ? 'Search English words...'
                  : 'Tìm kiếm từ tiếng Việt...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon:
              _showSuggestions
                  ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _focusNode.unfocus();
                    },
                  )
                  : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: Colors.grey, // Add border color
              width: 1.5, // Add border width
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: Colors.grey, // Add border color
              width: 1.5, // Add border width
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: Colors.blue, // Highlight border color when focused
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
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
                  context.go('/');
                },
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Dictionary',
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentSearches() {
    if (recentSearches.isEmpty) {
      return SizedBox(
        height: 48,
        child: const Center(
          child: Text(
            'No recent searches',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: recentSearches.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final word = recentSearches[index];
          return Chip(
            label: GestureDetector(
              onTap: () {
                _searchController.text = word;
                _focusNode.requestFocus();
              },
              child: Text(word),
            ),
            deleteIcon: const Icon(Icons.close, size: 18),
            onDeleted: () {
              setState(() {
                recentSearches.removeAt(index);
              });
            },
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Colors.grey),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFavoriteWords() {
    if (favoriteWords.isEmpty) {
      return SizedBox(
        height: 300,
        child: Center(
          child: Text(
            isEngToVie ? 'No favorite words' : 'Không có từ yêu thích',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }
    return SizedBox(
      height: 300,
      child: ListView.separated(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: favoriteWords.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final word = favoriteWords[index];
          final isOrange = !isEngToVie;
          return Card(
            elevation: 4,
            shadowColor:
                isOrange
                    ? Colors.amber.withOpacity(0.2)
                    : Colors.blue.withOpacity(0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isOrange ? Colors.amber.shade200 : Colors.blue.shade200,
                width: 1.5,
              ),
            ),
            color: isOrange ? Colors.yellow[50] : Colors.blue[50],
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    isOrange ? Colors.amber.shade100 : Colors.blue.shade100,
                child: Icon(
                  FontAwesomeIcons.solidHeart,
                  color: isOrange ? Colors.deepOrange : Colors.blue,
                  size: 18,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              title: GestureDetector(
                onTap: () {
                  _searchController.text = word;
                  _focusNode.requestFocus();
                },
                child: Text(
                  word,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isOrange ? Colors.deepOrange : Colors.blue,
                  ),
                ),
              ),
              trailing: IconButton(
                icon: Icon(
                  Icons.close,
                  size: 22,
                  color: isOrange ? Colors.redAccent : Colors.blueAccent,
                ),
                tooltip:
                    isEngToVie ? 'Remove from favorites' : 'Xóa khỏi yêu thích',
                onPressed: () {
                  setState(() {
                    favoriteWords.removeAt(index);
                  });
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTitle(String title, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (icon != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(icon, color: Colors.black87, size: 22),
                ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(height: 2, width: double.infinity, color: Colors.black12),
        ],
      ),
    );
  }

  Widget _buildSwitchLoadingScreen() {
    return Stack(
      children: [
        ModalBarrier(dismissible: false, color: Colors.black.withOpacity(0.3)),
        Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
