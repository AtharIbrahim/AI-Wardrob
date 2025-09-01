import 'package:flutter_test/flutter_test.dart';
import 'package:reco_outfit/services/outfit_recommendation_service.dart';
import 'package:reco_outfit/models/clothing_item.dart';
import 'package:reco_outfit/models/outfit.dart';

void main() {
  group('Digital Wardrobe Improvements Tests', () {
    test('Recommendation Service should generate outfits', () {
      final service = OutfitRecommendationService();
      
      // Create sample clothing items
      final items = [
        ClothingItem(
          id: 1,
          name: 'Blue Jeans',
          category: ClothingCategory.bottoms,
          color: 'Blue',
          season: Season.allSeason,
          imagePath: 'test_path',
          tags: ['casual'],
          createdAt: DateTime.now(),
        ),
        ClothingItem(
          id: 2,
          name: 'White T-Shirt',
          category: ClothingCategory.tops,
          color: 'White',
          season: Season.summer,
          imagePath: 'test_path',
          tags: ['casual'],
          createdAt: DateTime.now(),
        ),
        ClothingItem(
          id: 3,
          name: 'Red Dress',
          category: ClothingCategory.dresses,
          color: 'Red',
          season: Season.summer,
          imagePath: 'test_path',
          tags: ['party'],
          createdAt: DateTime.now(),
        ),
      ];

      // Test casual outfit generation
      final casualOutfits = service.recommendOutfits(
        availableItems: items,
        occasion: Occasion.casual,
        mood: Mood.comfortable,
        maxRecommendations: 3,
      );

      expect(casualOutfits.isNotEmpty, true, reason: 'Should generate casual outfits');
      
      // Test party outfit generation
      final partyOutfits = service.recommendOutfits(
        availableItems: items,
        occasion: Occasion.party,
        mood: Mood.fun,
        maxRecommendations: 3,
      );

      expect(partyOutfits.isNotEmpty, true, reason: 'Should generate party outfits');
    });

    test('ClothingItem model should handle data correctly', () {
      final item = ClothingItem(
        id: 1,
        name: 'Test Item',
        category: ClothingCategory.tops,
        color: 'Blue',
        season: Season.summer,
        imagePath: 'test_path',
        tags: ['test', 'item'],
        createdAt: DateTime.now(),
      );

      final map = item.toMap();
      final fromMap = ClothingItem.fromMap(map);

      expect(fromMap.name, equals(item.name));
      expect(fromMap.category, equals(item.category));
      expect(fromMap.color, equals(item.color));
      expect(fromMap.tags, equals(item.tags));
    });

    test('Outfit model should handle data correctly', () {
      final items = [
        ClothingItem(
          id: 1,
          name: 'Test Top',
          category: ClothingCategory.tops,
          color: 'Blue',
          season: Season.summer,
          imagePath: 'test_path',
          tags: ['test'],
          createdAt: DateTime.now(),
        ),
        ClothingItem(
          id: 2,
          name: 'Test Bottom',
          category: ClothingCategory.bottoms,
          color: 'Black',
          season: Season.allSeason,
          imagePath: 'test_path',
          tags: ['test'],
          createdAt: DateTime.now(),
        ),
      ];

      final outfit = Outfit(
        id: 1,
        name: 'Test Outfit',
        items: items,
        occasion: Occasion.casual,
        weather: 'Clear',
        mood: Mood.comfortable,
        createdAt: DateTime.now(),
      );

      final map = outfit.toMap();
      final fromMap = Outfit.fromMap(map, items);

      expect(fromMap.name, equals(outfit.name));
      expect(fromMap.occasion, equals(outfit.occasion));
      expect(fromMap.mood, equals(outfit.mood));
      expect(fromMap.items.length, equals(outfit.items.length));
    });
  });
}
