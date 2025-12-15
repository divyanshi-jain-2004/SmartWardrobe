// lib/models/outfit_model.dart

class OutfitModel {
  final String name;
  final String imageUrl;
  final String season;
  final String gender;
  final bool isFavorite;

  OutfitModel({
    required this.name,
    required this.imageUrl,
    required this.season,
    required this.gender,
    this.isFavorite = true,
  });
}