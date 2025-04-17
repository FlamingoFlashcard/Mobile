class FlipCardModel {
  final String frontText;
  final String backText;

  const FlipCardModel({required this.frontText, required this.backText});
}

final List<FlipCardModel> communicationFlashcard = [
  FlipCardModel(frontText: "Xin chào", backText: "Hello"),

  FlipCardModel(frontText: "Bạn tên gì?", backText: "What's your name?"),

  FlipCardModel(frontText: "Bạn bao nhiêu tuổi?", backText: "How old are you?"),

  FlipCardModel(frontText: "Bạn đến từ đâu?", backText: "Where are you from?"),

  FlipCardModel(
    frontText: "Rất vui được gặp bạn",
    backText: "Nice to meet you",
  ),

  FlipCardModel(frontText: "Hẹn gặp lại", backText: "See you later"),
];
