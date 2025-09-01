import 'clothing_item.dart';

class Outfit {
  final int? id;
  final String name;
  final List<ClothingItem> items;
  final String occasion;
  final String weather;
  final String mood;
  final DateTime createdAt;
  final double? rating;
  final Map<String, String>? metadata;

  Outfit({
    this.id,
    required this.name,
    required this.items,
    required this.occasion,
    required this.weather,
    required this.mood,
    required this.createdAt,
    this.rating,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'itemIds': items.map((item) => item.id).toList().join(','),
      'occasion': occasion,
      'weather': weather,
      'mood': mood,
      'createdAt': createdAt.toIso8601String(),
      'rating': rating,
      'metadata': metadata != null ? metadata!.entries.map((e) => '${e.key}:${e.value}').join('|') : null,
    };
  }

  factory Outfit.fromMap(Map<String, dynamic> map, List<ClothingItem> allItems) {
    final itemIds = map['itemIds']
        .toString()
        .split(',')
        .where((id) => id.isNotEmpty)
        .map((id) => int.parse(id))
        .toList();
    
    final outfitItems = allItems
        .where((item) => itemIds.contains(item.id))
        .toList();

    Map<String, String>? metadata;
    if (map['metadata'] != null && map['metadata'].toString().isNotEmpty) {
      metadata = {};
      final metadataPairs = map['metadata'].toString().split('|');
      for (final pair in metadataPairs) {
        final parts = pair.split(':');
        if (parts.length == 2) {
          metadata[parts[0]] = parts[1];
        }
      }
    }

    return Outfit(
      id: map['id'],
      name: map['name'],
      items: outfitItems,
      occasion: map['occasion'],
      weather: map['weather'],
      mood: map['mood'],
      createdAt: DateTime.parse(map['createdAt']),
      rating: map['rating']?.toDouble(),
      metadata: metadata,
    );
  }
}

// Occasions
class Occasion {
  static const String casual = 'Casual';
  static const String work = 'Work';
  static const String formal = 'Formal';
  static const String party = 'Party';
  static const String date = 'Date';
  static const String sport = 'Sport';
  static const String travel = 'Travel';
  static const String home = 'Home';

  static List<String> get all => [
        casual,
        work,
        formal,
        party,
        date,
        sport,
        travel,
        home,
      ];
}

// Weather types
class WeatherType {
  static const String sunny = 'Sunny';
  static const String cloudy = 'Cloudy';
  static const String rainy = 'Rainy';
  static const String snowy = 'Snowy';
  static const String hot = 'Hot';
  static const String cold = 'Cold';
  static const String mild = 'Mild';

  static List<String> get all => [
        sunny,
        cloudy,
        rainy,
        snowy,
        hot,
        cold,
        mild,
      ];
}

// Moods
class Mood {
  static const String confident = 'Confident';
  static const String comfortable = 'Comfortable';
  static const String elegant = 'Elegant';
  static const String fun = 'Fun';
  static const String professional = 'Professional';
  static const String relaxed = 'Relaxed';
  static const String romantic = 'Romantic';
  static const String edgy = 'Edgy';

  static List<String> get all => [
        confident,
        comfortable,
        elegant,
        fun,
        professional,
        relaxed,
        romantic,
        edgy,
      ];
}
