import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:lacquer/config/router.dart';
import 'package:lacquer/config/theme.dart';
import 'package:lacquer/features/flashcard/bloc/flashcard_bloc.dart';
import 'package:lacquer/features/flashcard/bloc/flashcard_event.dart';
import 'package:lacquer/features/flashcard/bloc/flashcard_state.dart';
import 'package:lacquer/features/flashcard/dtos/card_dto.dart';
import 'package:lacquer/features/flashcard/dtos/get_deck_dto.dart';
import 'package:lacquer/presentation/pages/home/widgets/card_item.dart';

class EditCardListPage extends StatefulWidget {
  final String deckId;

  const EditCardListPage({super.key, required this.deckId});

  @override
  State<EditCardListPage> createState() => _EditCardListPageState();
}

class _EditCardListPageState extends State<EditCardListPage> {
  bool isMultiSelectMode = false;
  final Set<String> selectedCardIds = {};

  @override
  void initState() {
    super.initState();
    context.read<FlashcardBloc>().add(LoadDeckByIdRequested(widget.deckId));
  }

  void _onCardTap(CardDto card) {
    final cardId = card.id;
    if (cardId == null) return;
    if (!isMultiSelectMode) return;
    setState(() {
      selectedCardIds.contains(card.id)
          ? selectedCardIds.remove(card.id)
          : selectedCardIds.add(cardId);
    });
  }

  void _onCardLongPress(CardDto card) {
    final cardId = card.id;
    if (cardId == null) return;
    setState(() {
      isMultiSelectMode = true;
      selectedCardIds.add(cardId);
    });
  }

  void _exitMultiSelect() {
    setState(() {
      isMultiSelectMode = false;
      selectedCardIds.clear();
    });
  }

  void _selectAll(List<CardDto> cards) {
    setState(() {
      selectedCardIds.addAll(cards.map((c) => c.id).whereType<String>());
    });
  }

  void _deleteSelected() {
    final bloc = context.read<FlashcardBloc>();
    for (final cardId in selectedCardIds) {
      bloc.add(DeleteCardRequested(widget.deckId, cardId));
    }
    _exitMultiSelect();
  }

  Future<void> _showDeckSelectionDialog(bool isCopy) async {
    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<List<GetDeckDto>>(
          future: context.read<FlashcardBloc>().repository.getUserAllDecks(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AlertDialog(
                content: SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            } else if (snapshot.hasError) {
              return AlertDialog(
                title: const Text('Error'),
                content: Text('Failed to load decks: ${snapshot.error}'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              );
            } else if (snapshot.hasData && snapshot.data != null) {
              final decks = snapshot.data!;
              return AlertDialog(
                title: Text(isCopy ? 'Copy Cards To' : 'Move Cards To'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: decks.length,
                    itemBuilder: (context, index) {
                      final deck = decks[index];
                      if (deck.id == widget.deckId)
                        return const SizedBox.shrink();
                      return ListTile(
                        title: Text(deck.title),
                        onTap: () {
                          final bloc = context.read<FlashcardBloc>();
                          if (isCopy) {
                            bloc.add(
                              CopyCardsRequested(
                                widget.deckId,
                                deck.id,
                                selectedCardIds.toList(),
                              ),
                            );
                          } else {
                            bloc.add(
                              MoveCardsRequested(
                                widget.deckId,
                                deck.id,
                                selectedCardIds.toList(),
                              ),
                            );
                          }
                          Navigator.of(context).pop();
                          _exitMultiSelect();
                        },
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ],
              );
            }
            return const AlertDialog(
              content: Text('No decks available'),
              actions: [TextButton(onPressed: null, child: Text('OK'))],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.lightbeige,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: BlocBuilder<FlashcardBloc, FlashcardState>(
          builder: (context, state) {
            final title = state.selectedDeck?.title ?? '';
            return _buildAppBar(
              context,
              title,
              state.selectedDeck?.cards ?? [],
            );
          },
        ),
      ),
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
            return Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12.0),
                    itemCount: deck.cards?.length ?? 0,
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      final card = deck.cards![index];
                      final isSelected = selectedCardIds.contains(card.id);
                      return GestureDetector(
                        onTap: () => _onCardTap(card),
                        onLongPress: () => _onCardLongPress(card),
                        child: CardItem(
                          card: card,
                          isSelected: isSelected,
                          isMultiSelectMode: isMultiSelectMode,
                        ),
                      );
                    },
                  ),
                ),
                if (deck.cards == null || deck.cards!.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No cards available in this deck'),
                  ),
              ],
            );
          }
          return const Center(child: Text('No deck data available'));
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, String title, List<CardDto> cards) {
    if (isMultiSelectMode) {
      return AppBar(
        backgroundColor: CustomTheme.mainColor1,
        title: Text(
          '${selectedCardIds.length} selected',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          color: Colors.white,
          onPressed: _exitMultiSelect,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.select_all),
            color: CustomTheme.mainColor3,
            onPressed: () => _selectAll(cards),
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            color: CustomTheme.mainColor3,
            onPressed: () => _showDeckSelectionDialog(true),
          ),
          IconButton(
            icon: const Icon(Icons.drive_file_move),
            color: CustomTheme.mainColor3,
            onPressed: () => _showDeckSelectionDialog(false),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            color: CustomTheme.mainColor3,
            onPressed: _deleteSelected,
          ),
        ],
      );
    }

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
                onPressed: () => context.go(RouteName.flashcards),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(FontAwesomeIcons.plus, color: Colors.white),
                onPressed:
                    () => context.go(RouteName.addNewWord(widget.deckId)),
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }
}
