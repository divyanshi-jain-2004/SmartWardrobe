class Event {
  final String title;
  final DateTime date;
  final String time;
  final String timeLeft;
  final List<String> outfitImageUrls;

  Event({
    required this.title,
    required this.date,
    required this.time,
    required this.timeLeft,
    required this.outfitImageUrls,
  });
}