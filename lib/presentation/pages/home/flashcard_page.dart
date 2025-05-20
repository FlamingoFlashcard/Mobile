import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:lacquer/config/theme.dart';
import 'package:lacquer/features/flashcard/bloc/flashcard_bloc.dart';
import 'package:lacquer/features/flashcard/bloc/flashcard_state.dart';
import 'package:lacquer/presentation/pages/home/widgets/flashcard_tag.dart';
import 'package:lacquer/presentation/pages/home/widgets/flashcard_topic_create.dart';

class FlashcardPage extends StatelessWidget {
  const FlashcardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            const SizedBox(height: 16),
            BlocBuilder<FlashcardBloc, FlashcardState>(
              builder: (context, state) {
                if (state.status == FlashcardStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state.status == FlashcardStatus.failure) {
                  return Center(
                    child: Text(
                      'Error: ${state.errorMessage ?? 'Unknown error'}',
                    ),
                  );
                } else if (state.status == FlashcardStatus.success) {
                  final groupedDecks = state.groupedDecks;
                  if (groupedDecks == null || groupedDecks.data.isEmpty) {
                    return const Center(child: Text('No decks available'));
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        groupedDecks.data.map((group) {
                          return FlashcardTag(
                            key: ValueKey(group.tag.id),
                            title: group.tag.name,
                            decks: group.decks,
                          );
                        }).toList(),
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
            TextField(
              decoration: InputDecoration(
                hintText: "Search topic you want",
                hintStyle: const TextStyle(color: Colors.black),
                prefixIcon: const Icon(
                  FontAwesomeIcons.magnifyingGlass,
                  color: Colors.grey,
                  size: 20,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onTap: () {
                print("Search field tapped");
              },
            ),
          ],
        ),
      ),
    );
  }
}
