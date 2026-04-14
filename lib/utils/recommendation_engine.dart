// recommendation_engine.dart — Weather + Jeans Sub-Type aware

import 'package:get_storage/get_storage.dart';
import 'dart:math';

class RecommendationEngine {
  final box = GetStorage();
  final _random = Random();

  // ─── Color Categories (unchanged) ───────────────────────────────────────────
  static const List<String> warmColors = [
    'red', 'orange', 'yellow', 'warm brown', 'maroon', 'peach', 'mustard',
    'coral', 'rust', 'terracotta', 'gold', 'salmon', 'copper', 'amber',
    'burnt orange', 'brick', 'caramel', 'sand', 'tan', 'khaki',
  ];
  static const List<String> coolColors = [
    'blue', 'green', 'purple', 'navy', 'emerald', 'teal', 'lilac',
    'cyan', 'turquoise', 'indigo', 'cobalt', 'sky blue', 'denim',
    'sage', 'mint', 'pine', 'steel blue', 'powder blue', 'periwinkle',
    'slate', 'aqua', 'forest green', 'olive',
  ];
  static const List<String> neutralColors = [
    'black', 'white', 'gray', 'grey', 'beige', 'cream', 'charcoal',
    'ivory', 'off white', 'nude', 'taupe', 'stone', 'ecru',
  ];
  static const List<String> pastelColors = [
    'baby pink', 'light blue', 'mint', 'lavender', 'peach',
    'blush', 'powder blue', 'soft yellow', 'rose', 'lilac',
    'pale green', 'soft pink', 'mauve', 'dusty rose', 'pastel',
  ];
  static const List<String> brightColors = [
    'magenta', 'lime', 'cyan', 'hot pink', 'bright red', 'royal blue',
    'orange', 'yellow', 'fuchsia', 'neon', 'electric blue', 'vivid',
    'fluorescent', 'bold', 'bright',
  ];

  // ─── Weather Season ──────────────────────────────────────────────────────────
  // Temperature (Celsius) se season derive karo
  String _getWeatherSeason(double tempC) {
    if (tempC >= 30) return 'Hot';       // Garmi — 30°C+
    if (tempC >= 22) return 'Warm';      // Mild warm — 22-29°C
    if (tempC >= 14) return 'Cool';      // Cool — 14-21°C
    return 'Cold';                        // Sardi — <14°C
  }

  // ─── Jeans / Bottomwear Sub-Type Scoring ────────────────────────────────────
  // Body type ke hisab se jeans ka sub_type score karo
  int _scoreJeansSubType(String? subType, String bodyType) {
    if (subType == null || subType.isEmpty || subType == 'Unknown') return 0;
    final s = subType.toLowerCase();
    int score = 0;

    switch (bodyType) {
      case 'Pear':
      // Wide hips — straight/bootcut/wide leg balance hips
        if (s.contains('straight')) score += 10;
        if (s.contains('bootcut') || s.contains('flare')) score += 9;
        if (s.contains('wide leg')) score += 7;
        if (s.contains('slim')) score += 3;
        if (s.contains('skinny')) score -= 2; // Too form-fitting on hips
        if (s.contains('tapered') || s.contains('jogger')) score += 4;
        break;

      case 'Apple':
      // Round midsection — high waist + straight/wide leg flows away from middle
        if (s.contains('straight')) score += 10;
        if (s.contains('wide leg')) score += 9;
        if (s.contains('regular')) score += 7;
        if (s.contains('slim')) score += 5;
        if (s.contains('skinny')) score += 2;
        break;

      case 'Inverted Triangle':
      // Broad shoulders — wide leg / flare balances lower body
        if (s.contains('wide leg')) score += 12;
        if (s.contains('flare') || s.contains('bootcut')) score += 10;
        if (s.contains('straight')) score += 6;
        if (s.contains('skinny')) score -= 3; // Emphasizes upper body more
        if (s.contains('slim')) score += 2;
        break;

      case 'Hourglass':
      // Balanced — almost everything works, form-fitting looks great
        if (s.contains('skinny')) score += 12;
        if (s.contains('slim')) score += 11;
        if (s.contains('straight')) score += 9;
        if (s.contains('bootcut') || s.contains('flare')) score += 8;
        if (s.contains('wide leg')) score += 6;
        break;

      case 'Rectangle':
      // Straight figure — create curves with flare/wide leg
        if (s.contains('flare') || s.contains('bootcut')) score += 11;
        if (s.contains('wide leg')) score += 9;
        if (s.contains('straight')) score += 7;
        if (s.contains('skinny')) score += 5;
        if (s.contains('slim')) score += 6;
        break;

      default:
        score += 5; // Neutral fallback
    }
    return score;
  }

  // ─── Weather Filter for Bottomwear ─────────────────────────────────────────
  // Garmi mein heavy/full-length jeans pe penalty, sardi mein skinny pe penalty
  int _scoreBottomwearForWeather(String? subType, String season) {
    if (subType == null || subType.isEmpty || subType == 'Unknown') return 0;
    final s = subType.toLowerCase();

    switch (season) {
      case 'Hot':
      // Bahut garmi — wide leg / loose preferred, skinny uncomfortable
        if (s.contains('wide leg')) return 5;      // Airy, comfortable
        if (s.contains('straight')) return 3;
        if (s.contains('regular')) return 3;
        if (s.contains('skinny')) return -6;        // Too hot / clingy
        if (s.contains('slim')) return -3;
        if (s.contains('tapered') || s.contains('jogger')) return -2;
        break;

      case 'Warm':
      // Mild — sab chalega lekin skinny thodi less preferred
        if (s.contains('wide leg')) return 3;
        if (s.contains('straight')) return 4;
        if (s.contains('regular')) return 4;
        if (s.contains('skinny')) return 0;
        if (s.contains('slim')) return 2;
        break;

      case 'Cool':
      // Thandi hawa — skinny + slim acha lagta hai, close-fit preferred
        if (s.contains('skinny')) return 5;
        if (s.contains('slim')) return 4;
        if (s.contains('straight')) return 3;
        if (s.contains('tapered') || s.contains('jogger')) return 3;
        if (s.contains('wide leg')) return -2;    // Too breezy
        break;

      case 'Cold':
      // Kaafi sardi — close-fit best for layering, wide leg pe penalty
        if (s.contains('skinny')) return 7;
        if (s.contains('slim')) return 6;
        if (s.contains('tapered') || s.contains('jogger')) return 5;
        if (s.contains('straight')) return 4;
        if (s.contains('wide leg')) return -5;   // Cold air easily gets in
        if (s.contains('flare') || s.contains('bootcut')) return -3;
        break;
    }
    return 0;
  }

  // ─── Weather Filter for Topwear ─────────────────────────────────────────────
  // Category name ya color se topwear ko weather ke hisab se score karo
  int _scoreTopwearForWeather(Map<String, dynamic> top, String season) {
    final name = (top['item_name'] ?? '').toString().toLowerCase();
    final color = (top['color'] ?? '').toString().toLowerCase();
    int score = 0;

    switch (season) {
      case 'Hot':
      // Tank tops, sleeveless, crop tops preferred
        if (name.contains('tank') || name.contains('sleeveless')) score += 6;
        if (name.contains('crop')) score += 5;
        if (name.contains('shirt') || name.contains('top')) score += 3;
        if (name.contains('sweater') || name.contains('hoodie') || name.contains('jacket')) score -= 8;
        if (name.contains('coat') || name.contains('blazer')) score -= 6;
        // Light colors better in heat (reflect sun)
        if (color.contains('white') || color.contains('cream') || color.contains('light')) score += 3;
        if (color.contains('black')) score -= 2;
        break;

      case 'Warm':
        if (name.contains('sweater') || name.contains('hoodie')) score -= 3;
        if (name.contains('jacket') || name.contains('coat')) score -= 5;
        if (name.contains('tank') || name.contains('sleeveless')) score += 3;
        break;

      case 'Cool':
        if (name.contains('sweater') || name.contains('hoodie')) score += 5;
        if (name.contains('jacket')) score += 4;
        if (name.contains('tank') || name.contains('sleeveless')) score -= 4;
        break;

      case 'Cold':
        if (name.contains('sweater') || name.contains('hoodie')) score += 8;
        if (name.contains('jacket') || name.contains('coat') || name.contains('blazer')) score += 7;
        if (name.contains('tank') || name.contains('sleeveless') || name.contains('crop')) score -= 8;
        // Dark colors retain warmth perception
        if (color.contains('black') || color.contains('charcoal') || color.contains('navy')) score += 2;
        break;
    }
    return score;
  }

  // ─── Existing Scoring Methods (unchanged) ───────────────────────────────────
  String _categorizeColor(String color) {
    color = color.toLowerCase().trim();
    if (neutralColors.any((c) => color.contains(c))) return 'Neutral';
    if (pastelColors.any((c) => color.contains(c))) return 'Pastel';
    if (brightColors.any((c) => color.contains(c))) return 'Bright';
    if (warmColors.any((c) => color.contains(c))) return 'Warm';
    if (coolColors.any((c) => color.contains(c))) return 'Cool';
    return 'Neutral';
  }

  int _scoreColorForSkinTone(String colorStr, String skinTone) {
    String cat = _categorizeColor(colorStr);
    colorStr = colorStr.toLowerCase();
    int score = 0;
    switch (skinTone) {
      case 'Fair':
      case 'Light':
        if (cat == 'Cool') score += 10;
        if (cat == 'Pastel') score += 8;
        if (cat == 'Neutral') score += 6;
        if (cat == 'Bright') score += 4;
        if (cat == 'Warm') score += 3;
        break;
      case 'Medium':
      case 'Olive':
        if (cat == 'Warm') score += 10;
        if (cat == 'Bright') score += 9;
        if (cat == 'Cool') score += 7;
        if (cat == 'Neutral') score += 6;
        if (colorStr.contains('beige') || colorStr.contains('nude')) score -= 3;
        if (cat == 'Pastel') score += 4;
        break;
      case 'Tan':
      case 'Brown':
        if (cat == 'Warm') score += 10;
        if (cat == 'Bright') score += 10;
        if (colorStr.contains('white') || colorStr.contains('cream')) score += 10;
        if (cat == 'Cool') score += 6;
        if (cat == 'Neutral') score += 5;
        if (cat == 'Pastel') score += 5;
        break;
      case 'Deep':
      case 'Dark':
        if (colorStr.contains('white') || colorStr.contains('cream') || colorStr.contains('ivory')) score += 12;
        if (cat == 'Pastel') score += 10;
        if (cat == 'Bright') score += 10;
        if (cat == 'Neutral' && !colorStr.contains('black') && !colorStr.contains('charcoal')) score += 6;
        if (colorStr.contains('black') || colorStr.contains('charcoal')) score -= 2;
        if (cat == 'Cool') score += 7;
        if (cat == 'Warm') score += 7;
        break;
      default:
        score += 5;
    }
    return score;
  }

  int _scoreForBodyType(Map<String, dynamic> item, String bodyType, bool isTop) {
    String cat = _categorizeColor(item['color'] ?? '');
    int score = 0;
    switch (bodyType) {
      case 'Pear':
        if (isTop && (cat == 'Bright' || cat == 'Pastel' || cat == 'Warm')) score += 10;
        if (!isTop && (cat == 'Neutral' || cat == 'Cool')) score += 10;
        if (!isTop && (cat == 'Bright' || cat == 'Warm')) score -= 5;
        break;
      case 'Apple':
        if (isTop && cat == 'Neutral') score += 8;
        if (isTop && cat == 'Cool') score += 5;
        if (!isTop && (cat == 'Bright' || cat == 'Warm')) score += 10;
        break;
      case 'Inverted Triangle':
        if (isTop && cat == 'Neutral') score += 12;
        if (isTop && (cat == 'Bright' || cat == 'Warm')) score -= 5;
        if (!isTop && (cat == 'Bright' || cat == 'Warm' || cat == 'Pastel')) score += 10;
        break;
      case 'Hourglass':
        score += 7;
        if (cat == 'Bright' || cat == 'Warm') score += 3;
        break;
      case 'Rectangle':
        if (isTop && (cat == 'Bright' || cat == 'Warm')) score += 8;
        if (!isTop && (cat == 'Pastel' || cat == 'Cool')) score += 5;
        break;
      default:
        score += 5;
    }
    return score;
  }

  int _scoreColorHarmony(String topColor, String bottomColor) {
    String topCat = _categorizeColor(topColor);
    String botCat = _categorizeColor(bottomColor);
    topColor = topColor.toLowerCase();
    bottomColor = bottomColor.toLowerCase();
    if (topCat == 'Neutral' || botCat == 'Neutral') return 12;
    if (topCat == botCat) return 9;
    bool isNavyMustard = (topColor.contains('navy') && bottomColor.contains('mustard')) ||
        (topColor.contains('mustard') && bottomColor.contains('navy'));
    bool isWhiteAnything = topColor.contains('white') || bottomColor.contains('white');
    if (isNavyMustard) return 14;
    if (isWhiteAnything) return 12;
    if ((topCat == 'Pastel' && botCat == 'Neutral') || (topCat == 'Neutral' && botCat == 'Pastel')) return 10;
    if ((topCat == 'Warm' && botCat == 'Cool') || (topCat == 'Cool' && botCat == 'Warm')) return 4;
    if (topCat == 'Bright' && botCat == 'Bright') return -3;
    return 5;
  }

  // ─── Main: Generate Outfits ─────────────────────────────────────────────────
  List<Map<String, dynamic>> generateOutfits(
      List<Map<String, dynamic>> wardrobeItems, int count) {
    final String skinTone = box.read('skin_tone_name') ?? 'Medium';
    final String bodyType = box.read('body_type') ?? 'Unknown';

    // 🌡️ Weather temperature GetStorage se read karo
    // WeatherController already 'current_temp_c' save karta ho toh:
    final double tempC = (box.read('current_temp_c') ?? 25.0).toDouble();
    final String season = _getWeatherSeason(tempC);

    final List<Map<String, dynamic>> tops = wardrobeItems
        .where((i) => i['category'] == 'Topwear' || i['category'] == 'Tops')
        .toList();
    final List<Map<String, dynamic>> bottoms = wardrobeItems
        .where((i) => i['category'] == 'Bottomwear' || i['category'] == 'Bottoms')
        .toList();

    if (tops.isEmpty || bottoms.isEmpty) return [];

    final List<Map<String, dynamic>> combos = [];

    for (var top in tops) {
      for (var bot in bottoms) {
        int score = 0;

        // 1. Skin tone color scoring
        score += _scoreColorForSkinTone(top['color'] ?? '', skinTone);
        score += _scoreColorForSkinTone(bot['color'] ?? '', skinTone);

        // 2. Body type color scoring
        score += _scoreForBodyType(top, bodyType, true);
        score += _scoreForBodyType(bot, bodyType, false);

        // 3. Color harmony
        score += _scoreColorHarmony(top['color'] ?? '', bot['color'] ?? '');

        // 4. 🆕 Jeans sub_type + body type compatibility
        final String? subType = bot['sub_type'] as String?;
        score += _scoreJeansSubType(subType, bodyType);

        // 5. 🌡️ Weather-based scoring
        score += _scoreTopwearForWeather(top, season);
        score += _scoreBottomwearForWeather(subType, season);

        // Combo name mein sub_type bhi dikhao
        final String botLabel = subType != null && subType.isNotEmpty && subType != 'Unknown'
            ? '${bot['color'] ?? 'Matching'} $subType'
            : '${bot['color'] ?? 'Matching'} Bottom';

        combos.add({
          'top': top,
          'bottom': bot,
          'score': score,
          'season': season,
          'sub_type': subType,
          'name': '${top['color'] ?? 'Stylish'} Top & $botLabel',
        });
      }
    }

    combos.sort((a, b) => b['score'].compareTo(a['score']));

    // Top candidates mein se thoda randomness
    var topCandidates = combos.take(min(count + 5, combos.length)).toList();
    topCandidates.shuffle(_random);

    return topCandidates.take(count).toList();
  }
}