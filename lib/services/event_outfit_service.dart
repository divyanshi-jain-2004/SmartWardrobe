// event_outfit_service.dart
// Event ki details padhke occasion + weather context banata hai,
// phir RecommendationEngine se best outfits nikalta hai.

import 'dart:math';
import 'package:get_storage/get_storage.dart';
import 'package:smart_wardrobe_new/utils/recommendation_engine.dart';
import '../models/event_model.dart';

// ─── Occasion Types ──────────────────────────────────────────────────────────
enum OccasionType {
  formal,      // Wedding, gala, interview, meeting
  casual,      // Hangout, coffee, shopping
  party,       // Birthday, club, night out
  sports,      // Gym, outdoor, trek
  business,    // Office, presentation, networking
  festive,     // Festival, Diwali, Holi, Eid
  unknown,
}

class EventOutfitService {
  final box = GetStorage();
  final _engine = RecommendationEngine();

  // ─── 1. Title se Occasion detect karo ────────────────────────────────────
  OccasionType _detectOccasion(String title) {
    final t = title.toLowerCase();

    if (_containsAny(t, ['wedding', 'shaadi', 'nikah', 'gala', 'black tie',
      'formal', 'interview', 'ceremony', 'reception', 'convocation'])) {
      return OccasionType.formal;
    }
    if (_containsAny(t, ['office', 'meeting', 'presentation', 'conference',
      'networking', 'business', 'seminar', 'work'])) {
      return OccasionType.business;
    }
    if (_containsAny(t, ['party', 'birthday', 'bday', 'club', 'night out',
      'celebration', 'bash', 'disco', 'pub', 'bar', 'Date'])) {
      return OccasionType.party;
    }
    if (_containsAny(t, ['gym', 'trek', 'hike', 'sport', 'run', 'match',
      'workout', 'yoga', 'cycling', 'marathon', 'cricket', 'football'])) {
      return OccasionType.sports;
    }
    if (_containsAny(t, ['diwali', 'eid', 'holi', 'festival', 'puja',
      'navratri', 'durga', 'ganesh', 'christmas', 'new year'])) {
      return OccasionType.festive;
    }
    if (_containsAny(t, ['hangout', 'coffee', 'lunch', 'dinner', 'casual',
      'shopping', 'outing', 'picnic', 'movie', 'mall'])) {
      return OccasionType.casual;
    }

    return OccasionType.unknown;
  }

  bool _containsAny(String text, List<String> keywords) =>
      keywords.any((k) => text.contains(k));

  // ─── 2. WeatherInfo string se tempC estimate karo ────────────────────────
  // weatherInfo example: "28°C Sunny" ya "Partly Cloudy 18°C"
  double _parseTempFromWeatherInfo(String? weatherInfo) {
    if (weatherInfo == null || weatherInfo.isEmpty) {
      // Fallback: GetStorage se current temp lo
      return (box.read('current_temp_c') ?? 25.0).toDouble();
    }
    final regex = RegExp(r'(\d+(?:\.\d+)?)\s*°?C');
    final match = regex.firstMatch(weatherInfo);
    if (match != null) {
      return double.tryParse(match.group(1)!) ?? 25.0;
    }
    return (box.read('current_temp_c') ?? 25.0).toDouble();
  }

  // ─── 3. Occasion ke hisab se wardrobe filter karo ────────────────────────
  List<Map<String, dynamic>> _filterByOccasion(
      List<Map<String, dynamic>> wardrobe, OccasionType occasion) {

    // Agar occasion unknown hai toh sabhi items return karo
    if (occasion == OccasionType.unknown) return wardrobe;

    // Item ke tags/style/sub_type se filter karo
    return wardrobe.where((item) {
      final style = (item['style'] ?? '').toString().toLowerCase();
      final subType = (item['sub_type'] ?? '').toString().toLowerCase();
      final name = (item['item_name'] ?? '').toString().toLowerCase();

      switch (occasion) {
        case OccasionType.formal:
          return _containsAny(style + subType + name,
              ['formal', 'suit', 'blazer', 'dress', 'gown', 'kurta',
                'sherwani', 'saree', 'lehenga', 'trouser', 'oxford']);

        case OccasionType.business:
          return _containsAny(style + subType + name,
              ['formal', 'business', 'blazer', 'shirt', 'trouser',
                'chinos', 'skirt', 'blouse']);

        case OccasionType.party:
          return _containsAny(style + subType + name,
              ['party', 'casual', 'dress', 'top', 'jeans', 'skirt',
                'crop', 'bodycon', 'sequin', 'glitter']);

        case OccasionType.sports:
          return _containsAny(style + subType + name,
              ['sport', 'athletic', 'gym', 'jogger', 'track',
                'shorts', 'jersey', 'hoodie', 'sneaker', 'active']);

        case OccasionType.festive:
          return _containsAny(style + subType + name,
              ['ethnic', 'kurta', 'lehenga', 'saree', 'sherwani',
                'festive', 'traditional', 'anarkali', 'dhoti', 'dupatta']);

        case OccasionType.casual:
          return _containsAny(style + subType + name,
              ['casual', 'jeans', 'top', 't-shirt', 'tshirt', 'shirt',
                'shorts', 'skirt', 'sweatshirt', 'polo', 'hoodie']);

        default:
          return true;
      }
    }).toList();
  }

  // ─── 4. Occasion Score Bonus ─────────────────────────────────────────────
  // Scored outfits mein occasion ke hisab se bonus add karo
  int _occasionBonus(Map<String, dynamic> item, OccasionType occasion, bool isTop) {
    final style = (item['style'] ?? '').toString().toLowerCase();
    final name = (item['item_name'] ?? '').toString().toLowerCase();
    final color = (item['color'] ?? '').toString().toLowerCase();
    int bonus = 0;

    switch (occasion) {
      case OccasionType.formal:
      // Neutral/dark colors preferred
        if (_containsAny(color, ['black', 'navy', 'white', 'charcoal', 'grey', 'maroon'])) bonus += 8;
        if (_containsAny(name + style, ['blazer', 'suit', 'dress', 'sherwani'])) bonus += 10;
        if (_containsAny(color, ['neon', 'fluorescent', 'bright', 'lime'])) bonus -= 10;
        break;

      case OccasionType.business:
        if (_containsAny(color, ['navy', 'white', 'grey', 'black', 'beige'])) bonus += 6;
        if (_containsAny(name, ['shirt', 'blouse', 'blazer', 'trouser', 'chino'])) bonus += 8;
        break;

      case OccasionType.party:
      // Bold/fun colors are great
        if (_containsAny(color, ['red', 'pink', 'gold', 'sequin', 'black'])) bonus += 8;
        if (isTop && _containsAny(name, ['crop', 'bodycon', 'dress', 'top'])) bonus += 6;
        break;

      case OccasionType.sports:
      // Comfort > style
        if (_containsAny(name + style, ['jogger', 'track', 'jersey', 'shorts', 'active'])) bonus += 12;
        if (_containsAny(name, ['blazer', 'suit', 'dress', 'heels'])) bonus -= 15;
        break;

      case OccasionType.festive:
        if (_containsAny(color, ['red', 'gold', 'orange', 'maroon', 'pink', 'green'])) bonus += 8;
        if (_containsAny(name + style, ['kurta', 'ethnic', 'lehenga', 'saree', 'sherwani'])) bonus += 12;
        break;

      case OccasionType.casual:
      // Relaxed vibes
        if (_containsAny(name, ['jeans', 't-shirt', 'tshirt', 'hoodie', 'top'])) bonus += 6;
        if (_containsAny(name, ['suit', 'blazer', 'gown', 'sherwani'])) bonus -= 5;
        break;

      default:
        break;
    }

    return bonus;
  }

  // ─── 5. MAIN METHOD: Event ke liye outfits generate karo ─────────────────
  List<Map<String, dynamic>> generateOutfitsForEvent({
    required Event event,
    required List<Map<String, dynamic>> wardrobeItems,
    int count = 3,
  }) {
    final OccasionType occasion = _detectOccasion(event.title);
    final double tempC = _parseTempFromWeatherInfo(event.weatherInfo);

    // Temporarily override current_temp_c so engine uses event's weather
    final previousTemp = box.read('current_temp_c');
    box.write('current_temp_c', tempC);

    // Occasion se filter karein (agar filter ke baad items bahut kam hain toh full list use karo)
    List<Map<String, dynamic>> filtered = _filterByOccasion(wardrobeItems, occasion);
    if (filtered.length < 4) filtered = wardrobeItems; // Fallback to all items

    // Engine se base combos nikalo
    List<Map<String, dynamic>> combos = _engine.generateOutfits(filtered, count + 8);

    // Occasion bonus add karo
    for (var combo in combos) {
      int bonus = 0;
      bonus += _occasionBonus(combo['top'] as Map<String, dynamic>, occasion, true);
      bonus += _occasionBonus(combo['bottom'] as Map<String, dynamic>, occasion, false);
      combo['score'] = (combo['score'] as int) + bonus;
      combo['occasion'] = occasion.name;
      combo['event_temp_c'] = tempC;
    }

    // Re-sort after bonus
    combos.sort((a, b) => b['score'].compareTo(a['score']));

    // Temperature restore karo
    if (previousTemp != null) {
      box.write('current_temp_c', previousTemp);
    }

    // Thoda randomness top results mein
    var topPicks = combos.take(min(count + 3, combos.length)).toList();
    topPicks.shuffle(Random());

    return topPicks.take(count).toList();
  }

  // ─── Helper: Occasion ka readable label ──────────────────────────────────
  String occasionLabel(String eventTitle) {
    final o = _detectOccasion(eventTitle);
    switch (o) {
      case OccasionType.formal:   return '🎩 Formal';
      case OccasionType.business: return '💼 Business';
      case OccasionType.party:    return '🎉 Party';
      case OccasionType.sports:   return '🏃 Active';
      case OccasionType.festive:  return '🪔 Festive';
      case OccasionType.casual:   return '👕 Casual';
      default:                    return '✨ General';
    }
  }
}