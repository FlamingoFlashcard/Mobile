import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class FlashcardEvent extends Equatable {
  const FlashcardEvent();

  @override
  List<Object?> get props => [];
}

class CreateDeckRequested extends FlashcardEvent {
  final String title;
  final String description;
  final List<String> tags;
  final List<String> cardIds;
  final File? imageFile;

  const CreateDeckRequested({
    required this.title,
    required this.description,
    required this.tags,
    required this.cardIds,
    this.imageFile,
  });

  @override
  List<Object?> get props => [
    title,
    description,
    tags,
    cardIds,
    imageFile?.path,
  ];
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

// class LoadDeckByIdRequested extends FlashcardEvent {
//   final String deckId;

//   const LoadDeckByIdRequested(this.deckId);

//   @override
//   List<Object> get props => [deckId];
// }

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
