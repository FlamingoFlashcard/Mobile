import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:lacquer/config/router.dart';
import 'package:lacquer/config/theme.dart';
import 'package:lacquer/features/flashcard/bloc/flashcard_bloc.dart';
import 'package:lacquer/features/flashcard/bloc/flashcard_event.dart';
import 'package:lacquer/features/flashcard/bloc/flashcard_state.dart';
import 'package:lacquer/features/dictionary/bloc/dictionary_bloc.dart';
import 'package:lacquer/features/dictionary/bloc/dictionary_event.dart';
import 'package:lacquer/features/dictionary/bloc/dictionary_state.dart';
import 'package:lacquer/presentation/pages/home/dictionary_page.dart';

class AddNewWordPage extends StatefulWidget {
  final String deckId;

  const AddNewWordPage({super.key, required this.deckId});

  @override
  State<AddNewWordPage> createState() => _AddNewWordPageState();
}

class _AddNewWordPageState extends State<AddNewWordPage> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  List<String> suggestions = [];
  List<SearchResultItem> searchResults = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    context.read<FlashcardBloc>().add(LoadDeckByIdRequested(widget.deckId));
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
    return Scaffold(
      backgroundColor: CustomTheme.lightbeige,
      body: MultiBlocListener(
        listeners: [
          BlocListener<FlashcardBloc, FlashcardState>(
            listener: (context, state) {
              if (state.status == FlashcardStatus.success) {
                setState(() {
                  _isLoading = false;
                });
              } else if (state.status == FlashcardStatus.loading) {
                setState(() {
                  _isLoading = true;
                });
              }
            },
          ),
          BlocListener<DictionaryBloc, DictionaryState>(
            listener: (context, state) {
              switch (state) {
                case DictionaryStateSearchInProgress():
                case DictionaryStateWordDetailsLoading():
                  setState(() {
                    _isLoading = true;
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
                case DictionaryStateWordDetailsSuccess():
                  // For now, just display the word details (no addition to deck)
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
          ),
        ],
        child: BlocBuilder<FlashcardBloc, FlashcardState>(
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
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildAppBar(context, deck.title),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: _buildSearchBar(),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: CustomTheme.mainColor3,
                              border: const Border(
                                left: BorderSide(
                                  color: Colors.grey,
                                  width: 1.0,
                                ),
                                right: BorderSide(
                                  color: Colors.grey,
                                  width: 1.0,
                                ),
                                bottom: BorderSide(
                                  color: Colors.grey,
                                  width: 1.0,
                                ),
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
                                    : searchResults.isNotEmpty
                                    ? _buildSearchResults()
                                    : _buildEmptyState(),
                          ),
                        ),
                        if (context.watch<DictionaryBloc>().state
                            is DictionaryStateWordDetailsSuccess)
                          _buildWordDetails(
                            context.watch<DictionaryBloc>().state
                                as DictionaryStateWordDetailsSuccess,
                          ),
                      ],
                    ),
                  ),
                  if (_isLoading) _buildLoadingScreenWidget(),
                ],
              );
            }
            return const Center(child: Text('No deck data available'));
          },
        ),
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
                  context.go(RouteName.edit(widget.deckId));
                },
              ),
              Text(
                'Add New Word to $title',
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      focusNode: _focusNode,
      decoration: InputDecoration(
        hintText: 'Search for a word to add',
        prefixIcon: const Icon(Icons.search),
        suffixIcon:
            _searchController.text.isNotEmpty
                ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      suggestions.clear();
                      searchResults.clear();
                    });
                  },
                )
                : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onChanged: (value) {
        setState(() {
          if (value.isNotEmpty) {
            _onSuggestions(value);
          } else {
            suggestions.clear();
            searchResults.clear();
          }
        });
      },
      onSubmitted: (value) {
        if (value.isNotEmpty) {
          _focusNode.unfocus();
          _onSearch(value);
        }
      },
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

  Widget _buildSearchResults() {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: searchResults.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final result = searchResults[index];
        return ListTile(
          title: Text(
            result.word,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (result.pronunciation.isNotEmpty)
                Text(
                  result.pronunciation,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
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
    );
  }

  Widget _buildEmptyState() {
    if (_focusNode.hasFocus && suggestions.isEmpty) {
      return const Center(
        child: Text(
          'No suggestions found',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }
    return const Center(
      child: Text(
        'Start typing to see suggestions',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }

  Widget _buildLoadingScreenWidget() {
    return Stack(
      children: [
        ModalBarrier(
          dismissible: false,
          color: Colors.black.withValues(alpha: 0.3),
        ),
        const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  Widget _buildWordDetails(DictionaryStateWordDetailsSuccess state) {
    final vocabulary = state.vocabulary;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                vocabulary.word,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (vocabulary.pronunciation.isNotEmpty)
                Text(
                  vocabulary.pronunciation,
                  style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              const SizedBox(height: 10),
              ...vocabulary.wordTypes.map((wordType) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wordType.type,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    ...wordType.definitions.map(
                      (def) => Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          '- $def',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    if (wordType.examples.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      const Text(
                        'Examples:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ...wordType.examples.map(
                        (example) => Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(
                            '- ${example.english} (${example.vietnamese})',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // Functions
  void _onSearch(String query) {
    if (query.isEmpty) return;
    _focusNode.unfocus();
    _searchController.text = query;
    context.read<DictionaryBloc>().add(
      DictionaryEventSearch(
        query: query,
        lang: 'en', // Assuming English for flashcards
      ),
    );
  }

  void _onGetWord(String word) {
    if (word.isEmpty) return;
    context.read<DictionaryBloc>().add(
      DictionaryEventGetWord(word: word, lang: 'en'),
    );
  }

  void _onSuggestions(String prefix) {
    if (prefix.isEmpty) return;
    context.read<DictionaryBloc>().add(
      DictionaryEventSuggestions(prefix: prefix, lang: 'en'),
    );
  }
}
