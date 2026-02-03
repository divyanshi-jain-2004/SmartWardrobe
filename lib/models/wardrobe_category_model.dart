import 'package:flutter/cupertino.dart';

enum Gender { men, women }

class WardrobeCategory {
  final String title;
  final IconData icon;
  final String itemImage;
  final List<String> tags;
  final List<Gender> genders;

  WardrobeCategory({
    required this.title,
    required this.icon,
    required this.itemImage,
    required this.tags,
    required this.genders,
  });
}