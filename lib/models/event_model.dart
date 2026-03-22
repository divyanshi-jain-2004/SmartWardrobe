class Event {
  final String title;
  final DateTime date;
  final String time;
  final String timeLeft;
  final List<String> outfitImageUrls;
  final String? location; // Added location
  final String? weatherInfo;

  Event({
    required this.title,
    required this.date,
    required this.time,
    required this.timeLeft,
    required this.outfitImageUrls,
    this.location,
    this.weatherInfo,
  });

  // Convert a Map (from storage) back into an Event object
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      title: json['title'],
      date: DateTime.parse(json['date']),
      time: json['time'],
      timeLeft: json['timeLeft'],
      outfitImageUrls: List<String>.from(json['outfitImageUrls']),
      location: json['location'],
      weatherInfo: json['weatherInfo'],
    );
  }

  // Convert our Event object into a Map so it can be saved
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'date': date.toIso8601String(),
      'time': time,
      'timeLeft': timeLeft,
      'outfitImageUrls': outfitImageUrls,
      'location': location,
      'weatherInfo': weatherInfo,
    };
  }
}