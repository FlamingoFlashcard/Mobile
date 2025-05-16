import 'package:equatable/equatable.dart';

abstract class FlashcardEvent extends Equatable {
  const FlashcardEvent();

  @override
  List<Object?> get props => [];
}

class CreateDeckRequested extends FlashcardEvent {
  final String title;
  final String description;
  final String imageUrl;
  final List<String> cardIds;

  const CreateDeckRequested({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.cardIds,
  });

  @override
  List<Object> get props => [title, description, imageUrl, cardIds];
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

// class DeleteDeckRequested extends FlashcardEvent {
//   final String deckId;

//   const DeleteDeckRequested(this.deckId);

//   @override
//   List<Object> get props => [deckId];
// }

// class UpdateDeckRequested extends FlashcardEvent {
//   final String deckId;
//   final String title;
//   final String description;
//   final String imageUrl;
//   final List<String> cardIds;

//   const UpdateDeckRequested({
//     required this.deckId,
//     required this.title,
//     required this.description,
//     required this.imageUrl,
//     required this.cardIds,
//   });

//   @override
//   List<Object> get props => [deckId, title, description, imageUrl, cardIds];
// }
