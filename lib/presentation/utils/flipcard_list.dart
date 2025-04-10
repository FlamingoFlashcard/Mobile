class FlipcardModel {
  final String fronttext;
  final String backtext;

  const FlipcardModel({required this.fronttext, required this.backtext});
}

final List<FlipcardModel> communicationflashcard = [
  FlipcardModel(fronttext: "Xin chào", backtext: "Hello"),

  FlipcardModel(fronttext: "Bạn tên gì?", backtext: "What's your name?"),

  FlipcardModel(fronttext: "Bạn bao nhiêu tuổi?", backtext: "How old are you?"),

  FlipcardModel(fronttext: "Bạn đến từ đâu?", backtext: "Where are you from?"),

  FlipcardModel(
    fronttext: "Rất vui được gặp bạn",
    backtext: "Nice to meet you",
  ),

  FlipcardModel(fronttext: "Hẹn gặp lại", backtext: "See you later"),
];
