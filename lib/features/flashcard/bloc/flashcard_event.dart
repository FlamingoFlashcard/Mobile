import 'package:equatable/equatable.dart';
import 'dart:io';

import 'package:lacquer/features/flashcard/dtos/card_dto.dart';

abstract class FlashcardEvent extends Equatable {
  const FlashcardEvent();

  @override
  List<Object?> get props => [];
}

class CreateDeckRequested extends FlashcardEvent {
  final String title;
  final String description;
  final List<String> tags;
  final List<CardDto> cards;
  final File? imageFile;

  const CreateDeckRequested({
    required this.title,
    required this.description,
    required this.tags,
    required this.cards,
    this.imageFile,
  });

  @override
  List<Object?> get props => [title, description, tags, cards, imageFile?.path];
}

class LoadDecksRequested extends FlashcardEvent {
  const LoadDecksRequested();
}

class LoadTagsRequested extends FlashcardEvent {
  const LoadTagsRequested();
}

class CreateTagRequested extends FlashcardEvent {
  final String name;

  const CreateTagRequested({required this.name});

  @override
  List<Object> get props => [name];
}

class LoadDeckByIdRequested extends FlashcardEvent {
  final String deckId;

  const LoadDeckByIdRequested(this.deckId);

  @override
  List<Object> get props => [deckId];
}

class DeleteDeckRequested extends FlashcardEvent {
  final String deckId;

  const DeleteDeckRequested(this.deckId);

  @override
  List<Object> get props => [deckId];
}

class UpdateDeckRequested extends FlashcardEvent {
  final String deckId;
  final String title;
  final String description;
  final List<String> tags;
  final File? imageFile;

  const UpdateDeckRequested({
    required this.deckId,
    required this.title,
    required this.description,
    required this.tags,
    required this.imageFile,
  });

  @override
  List<Object?> get props => [deckId, title, description, imageFile?.path];
}

class UpdateTagRequested extends FlashcardEvent {
  final String tagId;
  final String title;

  const UpdateTagRequested({required this.tagId, required this.title});

  @override
  List<Object?> get props => [tagId, title];
}

class DeleteTagRequested extends FlashcardEvent {
  final String tagId;

  const DeleteTagRequested(this.tagId);

  @override
  List<Object> get props => [tagId];
}

class SearchDecksRequested extends FlashcardEvent {
  final String query;

  const SearchDecksRequested(this.query);

  @override
  List<Object> get props => [query];
}

class AddCardToDeckRequested extends FlashcardEvent {
  final String deckId;
  final String cardId;

  const AddCardToDeckRequested({required this.deckId, required this.cardId});

  @override
  List<Object?> get props => [deckId, cardId];
}

class FinishDeckRequested extends FlashcardEvent {
  final String deckId;

  const FinishDeckRequested({required this.deckId});

  @override
  List<Object?> get props => [deckId];
}
