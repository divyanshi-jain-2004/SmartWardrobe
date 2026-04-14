// lib/models/outfit_model.dart

class OutfitModel {
  final int? id;
  final String name;
  final String imageUrl;
  final String season;
  final String gender;
  final bool isFavorite;

  OutfitModel({
    this.id,
    required this.name,
    required this.imageUrl,
    required this.season,
    required this.gender,
    this.isFavorite = true,
  });

  // Getter to handle multiple images merged into a single string
  List<String> get splitImages {
    if (imageUrl.contains(',')) {
      return imageUrl.split(',');
    }
    return [imageUrl];
  }
}