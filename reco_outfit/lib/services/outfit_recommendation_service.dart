import 'dart:math';
import '../models/clothing_item.dart';
import '../models/outfit.dart';
import '../models/weather.dart';

class OutfitRecommendationService {
  static final OutfitRecommendationService _instance = OutfitRecommendationService._internal();
  factory OutfitRecommendationService() => _instance;
  OutfitRecommendationService._internal();

  List<Outfit> recommendOutfits({
    required List<ClothingItem> availableItems,
    required String occasion,
    required String mood,
    Weather? weather,
    int maxRecommendations = 5,
  }) {
    print('🔥 RECOMMENDATION SERVICE CALLED');
    print('Available items count: ${availableItems.length}');
    print('Occasion: $occasion, Mood: $mood');
    
    if (availableItems.isEmpty) {
      print('❌ No items available for recommendations');
      return [];
    }

    List<Outfit> recommendations = [];
    
    // Filter items based on weather and season
    List<ClothingItem> suitableItems = _filterItemsByWeather(availableItems, weather);
    print('Suitable items after weather filter: ${suitableItems.length}');
    
    // If weather filtering removed too many items, use all items
    if (suitableItems.length < 3) {
      print('⚠️ Weather filter too restrictive, using all items');
      suitableItems = availableItems;
    }
    
    // Generate outfit combinations
    int attempts = 0;
    int maxAttempts = maxRecommendations * 3; // More attempts to find variety
    
    while (recommendations.length < maxRecommendations && attempts < maxAttempts) {
      attempts++;
      print('🎯 Attempt $attempts to generate outfit...');
      
      final outfit = _generateOutfit(
        suitableItems,
        occasion,
        mood,
        weather,
      );
      
      if (outfit != null) {
        print('✅ Generated outfit: ${outfit.name} with ${outfit.items.length} items');
        
        if (!_isDuplicateOutfit(outfit, recommendations)) {
          recommendations.add(outfit);
          print('💖 Added outfit to recommendations. Total: ${recommendations.length}');
        } else {
          print('🔄 Outfit was duplicate, trying again...');
        }
      } else {
        print('❌ Failed to generate outfit');
      }
    }
    
    print('🎉 Final recommendations count: ${recommendations.length}');
    return recommendations;
  }

  List<ClothingItem> _filterItemsByWeather(List<ClothingItem> items, Weather? weather) {
    if (weather == null) return items;
    
    return items.where((item) {
      // Filter by season based on weather
      if (weather.isCold) {
        return item.season == Season.winter || 
               item.season == Season.autumn || 
               item.season == Season.allSeason;
      } else if (weather.isHot) {
        return item.season == Season.summer || 
               item.season == Season.spring || 
               item.season == Season.allSeason;
      } else {
        return item.season == Season.spring || 
               item.season == Season.autumn || 
               item.season == Season.allSeason;
      }
    }).toList();
  }

  Outfit? _generateOutfit(
    List<ClothingItem> items,
    String occasion,
    String mood,
    Weather? weather,
  ) {
    print('🎨 Generating outfit from ${items.length} items...');
    
    if (items.isEmpty) {
      print('❌ No items to generate outfit from');
      return null;
    }
    
    final random = Random();
    List<ClothingItem> outfitItems = [];
    
    // Get required categories for a complete outfit
    final requiredCategories = _getRequiredCategories(occasion);
    print('Required categories for $occasion: $requiredCategories');
    
    // Try to get one item from each required category
    for (String category in requiredCategories) {
      final categoryItems = items.where((item) => item.category == category).toList();
      print('Category "$category" has ${categoryItems.length} items available');
      
      if (categoryItems.isNotEmpty) {
        final selectedItem = categoryItems[random.nextInt(categoryItems.length)];
        outfitItems.add(selectedItem);
        print('✅ Selected "${selectedItem.name}" for category "$category"');
      } else {
        print('⚠️ No items found for required category "$category"');
        // For party occasions, try alternative approach (dress OR top+bottom)
        if (occasion == Occasion.party && category == ClothingCategory.dresses) {
          print('🔄 Party outfit: Looking for top + bottom as alternative to dress');
          final tops = items.where((item) => item.category == ClothingCategory.tops).toList();
          final bottoms = items.where((item) => item.category == ClothingCategory.bottoms).toList();
          
          if (tops.isNotEmpty && bottoms.isNotEmpty) {
            outfitItems.add(tops[random.nextInt(tops.length)]);
            outfitItems.add(bottoms[random.nextInt(bottoms.length)]);
            print('✅ Added top + bottom for party outfit');
          }
        }
      }
    }
    
    // If we couldn't find items for required categories, try a more flexible approach
    if (outfitItems.isEmpty) {
      print('🔄 No required category items found, trying flexible approach...');
      
      // Try to get at least a top and bottom, or a dress
      final tops = items.where((item) => item.category == ClothingCategory.tops).toList();
      final bottoms = items.where((item) => item.category == ClothingCategory.bottoms).toList();
      final dresses = items.where((item) => item.category == ClothingCategory.dresses).toList();
      
      if (dresses.isNotEmpty) {
        outfitItems.add(dresses[random.nextInt(dresses.length)]);
        print('✅ Added dress for complete outfit');
      } else if (tops.isNotEmpty && bottoms.isNotEmpty) {
        outfitItems.add(tops[random.nextInt(tops.length)]);
        outfitItems.add(bottoms[random.nextInt(bottoms.length)]);
        print('✅ Added top and bottom for complete outfit');
      } else if (tops.isNotEmpty) {
        outfitItems.add(tops[random.nextInt(tops.length)]);
        print('✅ Added top only');
      } else if (items.isNotEmpty) {
        // Last resort: add any item
        outfitItems.add(items[random.nextInt(items.length)]);
        print('✅ Added random item as last resort');
      }
    }
    
    // Add optional accessories if available
    final availableAccessories = items.where((item) => 
      item.category == ClothingCategory.accessories &&
      !outfitItems.contains(item)
    ).toList();
    
    if (availableAccessories.isNotEmpty && random.nextBool()) {
      outfitItems.add(availableAccessories[random.nextInt(availableAccessories.length)]);
      print('✅ Added accessory');
    }
    
    // Add shoes if not already included and available
    final availableShoes = items.where((item) => 
      item.category == ClothingCategory.shoes &&
      !outfitItems.contains(item)
    ).toList();
    
    if (availableShoes.isNotEmpty && !outfitItems.any((item) => item.category == ClothingCategory.shoes)) {
      outfitItems.add(availableShoes[random.nextInt(availableShoes.length)]);
      print('✅ Added shoes');
    }
    
    print('Final outfit has ${outfitItems.length} items: ${outfitItems.map((e) => e.name).join(", ")}');
    
    if (outfitItems.isNotEmpty) {
      final outfitName = _generateOutfitName(occasion, mood);
      print('🎉 Created outfit: "$outfitName"');
      
      return Outfit(
        name: outfitName,
        items: outfitItems,
        occasion: occasion,
        weather: weather?.condition ?? 'Unknown',
        mood: mood,
        createdAt: DateTime.now(),
      );
    }
    
    print('❌ Could not create outfit - no suitable items found');
    return null;
  }

  List<String> _getRequiredCategories(String occasion) {
    switch (occasion) {
      case Occasion.formal:
        return [ClothingCategory.tops, ClothingCategory.bottoms];
      case Occasion.work:
        return [ClothingCategory.tops, ClothingCategory.bottoms];
      case Occasion.party:
        return [ClothingCategory.dresses]; // Allow dresses OR tops+bottoms
      case Occasion.sport:
        return [ClothingCategory.tops, ClothingCategory.bottoms];
      case Occasion.casual:
      default:
        return [ClothingCategory.tops, ClothingCategory.bottoms];
    }
  }

  String _generateOutfitName(String occasion, String mood) {
    final occasionAdjectives = {
      Occasion.casual: ['Relaxed', 'Comfortable', 'Easy'],
      Occasion.work: ['Professional', 'Sharp', 'Polished'],
      Occasion.formal: ['Elegant', 'Sophisticated', 'Classic'],
      Occasion.party: ['Fun', 'Vibrant', 'Stylish'],
      Occasion.date: ['Romantic', 'Charming', 'Sweet'],
      Occasion.sport: ['Active', 'Dynamic', 'Sporty'],
      Occasion.travel: ['Practical', 'Versatile', 'Convenient'],
      Occasion.home: ['Cozy', 'Comfortable', 'Relaxed'],
    };

    final moodAdjectives = {
      Mood.confident: ['Bold', 'Strong', 'Powerful'],
      Mood.comfortable: ['Soft', 'Easy', 'Gentle'],
      Mood.elegant: ['Refined', 'Graceful', 'Chic'],
      Mood.fun: ['Playful', 'Bright', 'Cheerful'],
      Mood.professional: ['Crisp', 'Clean', 'Structured'],
      Mood.relaxed: ['Chill', 'Laid-back', 'Casual'],
      Mood.romantic: ['Feminine', 'Soft', 'Dreamy'],
      Mood.edgy: ['Modern', 'Edgy', 'Contemporary'],
    };

    final random = Random();
    final occasionAdj = occasionAdjectives[occasion]?[random.nextInt(occasionAdjectives[occasion]!.length)] ?? 'Perfect';
    final moodAdj = moodAdjectives[mood]?[random.nextInt(moodAdjectives[mood]!.length)] ?? 'Great';
    
    return '$occasionAdj $moodAdj Look';
  }

  bool _isDuplicateOutfit(Outfit newOutfit, List<Outfit> existingOutfits) {
    for (Outfit existing in existingOutfits) {
      if (_outfitsAreSimilar(newOutfit, existing)) {
        return true;
      }
    }
    return false;
  }

  bool _outfitsAreSimilar(Outfit outfit1, Outfit outfit2) {
    if (outfit1.items.length != outfit2.items.length) return false;
    
    for (ClothingItem item in outfit1.items) {
      if (!outfit2.items.any((item2) => item.id == item2.id)) {
        return false;
      }
    }
    return true;
  }

  // Get outfit suggestions based on specific criteria
  List<ClothingItem> suggestItemsForWeather(List<ClothingItem> items, Weather weather) {
    List<ClothingItem> suggestions = [];
    
    if (weather.isCold) {
      suggestions.addAll(items.where((item) => 
        item.category == ClothingCategory.outerwear ||
        item.tags.contains('warm') ||
        item.season == Season.winter
      ));
    }
    
    if (weather.isRainy) {
      suggestions.addAll(items.where((item) => 
        item.tags.contains('waterproof') ||
        item.category == ClothingCategory.outerwear
      ));
    }
    
    if (weather.isHot) {
      suggestions.addAll(items.where((item) => 
        item.tags.contains('light') ||
        item.tags.contains('breathable') ||
        item.season == Season.summer
      ));
    }
    
    return suggestions;
  }
}
