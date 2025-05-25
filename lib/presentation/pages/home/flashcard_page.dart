import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:lacquer/config/theme.dart';
import 'package:lacquer/features/flashcard/bloc/flashcard_bloc.dart';
import 'package:lacquer/features/flashcard/bloc/flashcard_event.dart';
import 'package:lacquer/features/flashcard/bloc/flashcard_state.dart';
import 'package:lacquer/presentation/pages/home/widgets/flashcard_tag.dart';
import 'package:lacquer/presentation/pages/home/widgets/flashcard_topic_create.dart';

class FlashcardPage extends StatefulWidget {
  const FlashcardPage({super.key});

  @override
  State<FlashcardPage> createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<FlashcardBloc>().add(const LoadDecksRequested());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchDecks() {
    final query = _searchController.text.trim();
    context.read<FlashcardBloc>().add(SearchDecksRequested(query));
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<FlashcardBloc>().add(const SearchDecksRequested(''));
    // Only reload decks if the last search had results; otherwise, show "No result"
    final bloc = context.read<FlashcardBloc>();
    if (!bloc.state.searchResult) {
      // Do not reload decks; keep the original list and show "No result"
    } else {
      context.read<FlashcardBloc>().add(const LoadDecksRequested());
    }
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar(context),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: _buildSearchBar(),
              ),
              BlocBuilder<FlashcardBloc, FlashcardState>(
                builder: (context, state) {
                  if (state.status == FlashcardStatus.loading) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 16.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (state.status == FlashcardStatus.failure) {
                    return Center(
                      child: Text(
                        'Error: ${state.errorMessage ?? 'Unknown error'}',
                      ),
                    );
                  } else if (state.status == FlashcardStatus.success) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!state.searchResult)
                          SizedBox(
                            height: 30,
                            child: Center(
                              child: Text(
                                'No result',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ),
                        if (state.groupedDecks != null &&
                            state.groupedDecks!.data.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:
                                state.groupedDecks!.data.map((group) {
                                  return group.decks.isNotEmpty
                                      ? FlashcardTag(
                                        key: ValueKey(group.tag.id),
                                        tagId: group.tag.id,
                                        title: group.tag.name,
                                        decks: group.decks,
                                      )
                                      : const SizedBox.shrink();
                                }).toList(),
                          )
                        else if (state.groupedDecks == null)
                          const Padding(
                            padding: EdgeInsets.only(left: 16.0, top: 8.0),
                            child: Text('No decks available'),
                          ),
                      ],
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
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
                    'Flashcards',
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              IconButton(
                icon: const Icon(FontAwesomeIcons.plus, color: Colors.white),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const FlashcardTopicCreate(),
                  );
                },
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CustomTheme.mainColor3,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Search Flashcards",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search topic you want",
                      hintStyle: const TextStyle(color: Colors.black),
                      prefixIcon: const Icon(
                        FontAwesomeIcons.magnifyingGlass,
                        color: Colors.grey,
                        size: 20,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(
                          FontAwesomeIcons.check,
                          color: Colors.grey,
                          size: 20,
                        ),
                        onPressed: _searchDecks,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onSubmitted: (value) => _searchDecks(),
                    onTap: () {
                      print("Search field tapped");
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(
                    FontAwesomeIcons.xmark,
                    color: Colors.grey,
                    size: 20,
                  ),
                  onPressed: _clearSearch,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
