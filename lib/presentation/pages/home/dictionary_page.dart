import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:lacquer/config/theme.dart';
import 'package:lacquer/features/dictionary/bloc/dictionary_bloc.dart';
import 'package:lacquer/features/dictionary/bloc/dictionary_event.dart';
import 'package:lacquer/features/dictionary/bloc/dictionary_state.dart';
import 'package:lacquer/presentation/pages/home/widgets/dictionary_eng_vie_switch.dart';
import 'package:lacquer/presentation/pages/home/widgets/dictionary_word_detail_widget.dart';
import 'package:lacquer/presentation/widgets/dictionary_topic_widget.dart';

class Dictionarypage extends StatefulWidget {
  const Dictionarypage({super.key});

  @override
  State<Dictionarypage> createState() => _DicitionarypageState();
}

class _DicitionarypageState extends State<Dictionarypage> {
  bool isEngToVie = true; // true for Eng->Vie, false for Vie->Eng
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  List<String> recentSearches = [];
  List<SearchResultItem> searchResults = [];
  List<String> suggestions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _onLoadingMainScreen();
    _focusNode.addListener(() {});
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dictionaryState = context.watch<DictionaryBloc>().state;
    var dictionaryWidget = (switch (dictionaryState) {
      DictionaryStateInitial() => _buildMainScreenWidget(),
      DictionaryStateMainScreenLoading() => _buildMainScreenWidget(),
      DictionaryStateMainScreenSuccess() => _buildMainScreenWidget(),
      DictionaryStateMainScreenFailure() => _buildErrorWidget(
        'Error loading main screen: ${dictionaryState.message}',
      ),
      DictionaryStateSearchInProgress() => _buildSearchingWidget(),
      DictionaryStateSearchSuggestions() => _buildSearchingWidget(),
      DictionaryStateSearchSuccess() => _buildSearchResults(),
      DictionaryStateSearchFailure() => _buildErrorWidget(
        'Error searching: ${dictionaryState.message}',
      ),
      DictionaryStateWordDetailsLoading() => _buildSearchingWidget(),
      DictionaryStateWordDetailsSuccess() => DictionaryWordWidget(
        word: dictionaryState.vocabulary,
        onBack: () {
          _onLoadingMainScreen();
        },
      ),
      DictionaryStateWordDetailsFailure() => _buildErrorWidget(
        'Error loading word details',
      ),
    });
    dictionaryWidget = BlocListener<DictionaryBloc, DictionaryState>(
      listener: (context, state) {
        switch (state) {
          case DictionaryStateInitial():
          case DictionaryStateSearchInProgress():
          case DictionaryStateMainScreenLoading():
          case DictionaryStateWordDetailsLoading():
            setState(() {
              _isLoading = true;
            });
            break;
          case DictionaryStateMainScreenSuccess():
            recentSearches = state.recentSearches ?? [];
            setState(() {
              _isLoading = false;
            });
            break;
          case DictionaryStateSearchSuggestions():
            suggestions = state.suggestions;
            setState(() {
              _isLoading = false;
            });
            break;
          case DictionaryStateSearchSuccess():
            searchResults = state.searchResults;
            setState(() {
              _isLoading = false;
            });
            break;
          default:
            setState(() {
              _isLoading = false;
            });
            break;
        }
      },
      child: dictionaryWidget,
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        context.go('/');
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: CustomTheme.lightbeige,
            body: SingleChildScrollView(child: dictionaryWidget),
          ),
          if (_isLoading) _buildSwitchLoadingScreenWidget(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      focusNode: _focusNode,
      decoration: InputDecoration(
        hintText: isEngToVie ? 'Search vocabulary' : 'Tìm kiếm từ vựng',
        prefixIcon: const Icon(Icons.search),
        suffixIcon:
            _searchController.text.isNotEmpty
                ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      suggestions.clear();
                    });
                  },
                )
                : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onChanged: (value) {
        setState(() {
          if (value.isNotEmpty) {
            _onSuggestions(value); // Call your suggestion method
          } else {
            suggestions.clear();
          }
        });
      },
      onSubmitted: (value) {
        if (value.isNotEmpty && suggestions.isNotEmpty) {
          _focusNode.unfocus();
          _onSearch(value);
        }
      },
    );
  }

  Widget _buildAppBar(BuildContext context, VoidCallback onBackPressed) {
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
                  onBackPressed();
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
              _onRemoveRecentSearch(word);
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

  //------------------------------ WIDGETS -----------------------------
  Widget _buildSwitchLoadingScreenWidget() {
    return Stack(
      children: [
        ModalBarrier(dismissible: false, color: Colors.black.withValues(alpha: 0.3)),
        Center(child: CircularProgressIndicator()),
      ],
    );
  }

  Widget _buildMainScreenWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAppBar(context, () {
          context.go('/');
        }),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 10, right: 10, left: 10),
                child: _buildSearchBar(),
              ),
            ),
            DictionaryLanguageSwitch(
              onLanguageChanged: (isEngToVie) {
                setState(() {
                  this.isEngToVie = isEngToVie;
                  _searchController.clear();
                });
                _onLoadingMainScreen();
              },
              isEngToVie: isEngToVie,
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildTitle(
          isEngToVie ? 'Recent Searches' : 'Tìm kiếm gần đây',
          icon: Icons.history,
        ),
        _buildRecentSearches(),
        const SizedBox(height: 20),
        _buildTitle(
          isEngToVie ? 'Topic' : 'Chủ đề',
          icon: FontAwesomeIcons.star,
        ),
        DictionaryTopicWidget(
          onWordSearch: (word) {
            _onGetWord(word);
          },
          isEngToVie: isEngToVie,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSearchingWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAppBar(context, () {
          _onLoadingMainScreen();
        }),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(top: 10, right: 10, left: 10),
          child: _buildSearchBar(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: CustomTheme.mainColor3,
              border: const Border(
                left: BorderSide(color: Colors.grey, width: 1.0),
                right: BorderSide(color: Colors.grey, width: 1.0),
                bottom: BorderSide(color: Colors.grey, width: 1.0),
                top: BorderSide.none,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child:
                _focusNode.hasFocus && suggestions.isNotEmpty
                    ? _buildSuggestionsList()
                    : _buildEmptyState(),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionsList() {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: suggestions.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return ListTile(
          title: Text(suggestion, style: const TextStyle(fontSize: 16)),
          onTap: () {
            _searchController.text = suggestion;
            _focusNode.unfocus();
            _onSearch(suggestion);
          },
        );
      },
    );
  }

  Widget _buildErrorWidget(String message) {
    return Column(
      children: [
        _buildAppBar(context, () {
          _onLoadingMainScreen();
        }),
        const SizedBox(height: 20),
        Center(
          child: Text(
            message,
            style: TextStyle(color: Colors.red, fontSize: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    if (_focusNode.hasFocus && suggestions.isEmpty) {
      return Center(
        child: Text(
          isEngToVie ? 'No suggestions found' : 'Không có gợi ý nào',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return Center(
      child: Text(
        isEngToVie
            ? 'Start typing to see suggestions'
            : 'Bắt đầu nhập để xem gợi ý',
        style: const TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAppBar(context, () {
          _onLoadingMainScreen();
        }),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(top: 10, right: 10, left: 10),
          child: _buildSearchBar(),
        ),
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: searchResults.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final result = searchResults[index];
              return ListTile(
                title: Text(
                  result.word,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (result.pronunciation.isNotEmpty)
                      Text(
                        result.pronunciation,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ...result.meanings.entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          '- (${entry.key}) ${entry.value.join(", ")}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  _onGetWord(result.word);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  //----------------------------- FUNCTIONS -----------------------------
  void _onLoadingMainScreen() {
    recentSearches.clear();
    searchResults.clear();
    context.read<DictionaryBloc>().add(
      DictionaryEventLoadMainScreen(lang: isEngToVie ? 'en' : 'vn'),
    );
    setState(() {
      _searchController.clear();
      _focusNode.unfocus();
    });
  }

  void _onSearch(String query) {
    if (query.isEmpty) return;
    _focusNode.unfocus();
    _searchController.text = query;
    context.read<DictionaryBloc>().add(
      DictionaryEventSearch(query: query, lang: isEngToVie ? 'en' : 'vn'),
    );
  }

  void _onGetWord(String word) {
    if (word.isEmpty) return;
    context.read<DictionaryBloc>().add(
      DictionaryEventGetWord(word: word, lang: isEngToVie ? 'en' : 'vn'),
    );
  }

  void _onSuggestions(String prefix) {
    if (prefix.isEmpty) return;
    context.read<DictionaryBloc>().add(
      DictionaryEventSuggestions(
        prefix: prefix,
        lang: isEngToVie ? 'en' : 'vn',
      ),
    );
  }

  void _onRemoveRecentSearch(String word) {
    context.read<DictionaryBloc>().add(
      DictionaryEventRemoveRecentSearch(
        word: word,
        lang: isEngToVie ? 'en' : 'vn',
      ),
    );
  }
}

class SearchResultItem {
  final String word;
  final String pronunciation;
  final Map<String, List<String>> meanings;

  SearchResultItem({
    required this.word,
    required this.pronunciation,
    required this.meanings,
  });
}
