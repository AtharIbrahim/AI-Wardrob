class ClothingItem {
  final int? id;
  final String name;
  final String category;
  final String color;
  final String season;
  final String imagePath;
  final List<String> tags;
  final DateTime createdAt;

  ClothingItem({
    this.id,
    required this.name,
    required this.category,
    required this.color,
    required this.season,
    required this.imagePath,
    required this.tags,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'color': color,
      'season': season,
      'imagePath': imagePath,
      'tags': tags.join(','),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ClothingItem.fromMap(Map<String, dynamic> map) {
    return ClothingItem(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      color: map['color'],
      season: map['season'],
      imagePath: map['imagePath'],
      tags: map['tags'].toString().split(',').where((tag) => tag.isNotEmpty).toList(),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  ClothingItem copyWith({
    int? id,
    String? name,
    String? category,
    String? color,
    String? season,
    String? imagePath,
    List<String>? tags,
    DateTime? createdAt,
  }) {
    return ClothingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      color: color ?? this.color,
      season: season ?? this.season,
      imagePath: imagePath ?? this.imagePath,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// Clothing categories
class ClothingCategory {
  static const String tops = 'Tops';
  static const String bottoms = 'Bottoms';
  static const String dresses = 'Dresses';
  static const String outerwear = 'Outerwear';
  static const String shoes = 'Shoes';
  static const String accessories = 'Accessories';

  static List<String> get all => [
        tops,
        bottoms,
        dresses,
        outerwear,
        shoes,
        accessories,
      ];
}

// Seasons
class Season {
  static const String spring = 'Spring';
  static const String summer = 'Summer';
  static const String autumn = 'Autumn';
  static const String winter = 'Winter';
  static const String allSeason = 'All Season';

  static List<String> get all => [
        spring,
        summer,
        autumn,
        winter,
        allSeason,
      ];
}

// Colors
class ClothingColor {
  static const List<String> colors = [
    'Black',
    'White',
    'Gray',
    'Navy',
    'Brown',
    'Beige',
    'Red',
    'Pink',
    'Orange',
    'Yellow',
    'Green',
    'Blue',
    'Purple',
    'Multi-color',
  ];
}
