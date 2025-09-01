import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/clothing_item.dart';
import '../models/outfit.dart';
import '../models/weather.dart';

class AIRecommendationService {
  static final AIRecommendationService _instance = AIRecommendationService._internal();
  factory AIRecommendationService() => _instance;
  AIRecommendationService._internal();

  final Dio _dio = Dio();
  final String _baseUrl = 'https://api.mistral.ai/v1';
  
  String? get _apiKey => dotenv.env['MISTRAL_API_KEY'];

  /// Generate AI-powered outfit recommendations
  Future<List<Outfit>> generateRecommendations({
    required List<ClothingItem> availableItems,
    required String occasion,
    required String mood,
    Weather? weather,
    int maxRecommendations = 5,
  }) async {
    print('🤖 AI Recommendation Service Called');
    print('Available items: ${availableItems.length}');
    print('Occasion: $occasion, Mood: $mood');
    
    if (availableItems.isEmpty) {
      print('❌ No items available for recommendations');
      return [];
    }

    if (_apiKey == null || _apiKey!.isEmpty || _apiKey == 'NzDXEzkBwVOWBLUos6sV4XJQ8aS6lI1C') {
      print('⚠️ No valid Mistral API key found, using fallback recommendation');
      return _generateFallbackRecommendations(
        availableItems: availableItems,
        occasion: occasion,
        mood: mood,
        weather: weather,
        maxRecommendations: maxRecommendations,
      );
    }

    try {
      // Prepare context for AI
      final context = _buildContextPrompt(
        availableItems: availableItems,
        occasion: occasion,
        mood: mood,
        weather: weather,
        maxRecommendations: maxRecommendations,
      );

      print('🚀 Sending request to Mistral AI...');
      
      final response = await _dio.post(
        '$_baseUrl/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': 'mistral-small-latest',
          'messages': [
            {
              'role': 'system',
              'content': '''You are a professional fashion stylist and outfit recommendation expert. Your job is to create stylish, weather-appropriate, and occasion-specific outfit recommendations based on the user's wardrobe items.

IMPORTANT: You must respond with ONLY a valid JSON array. Do not include any explanation, markdown formatting, or additional text. Just return the JSON array directly.

Each outfit recommendation should be a JSON object with these exact fields:
- "name": A creative, descriptive outfit name
- "items": An array of item IDs from the available wardrobe
- "confidence": A number from 0.0 to 1.0 indicating how confident you are in this recommendation
- "reasoning": A brief explanation of why this outfit works well
- "style_tags": An array of style descriptors for this outfit

Consider:
- Color coordination and matching
- Seasonal appropriateness
- Occasion suitability
- Weather conditions
- Personal mood and style preferences
- Fashion trends and styling principles
- Layering for weather
- Comfort and practicality'''
            },
            {
              'role': 'user',
              'content': context,
            }
          ],
          'max_tokens': 2000,
          'temperature': 0.7,
        },
      );

      print('✅ Received response from Mistral AI');
      
      final content = response.data['choices'][0]['message']['content'];
      print('AI Response: $content');
      
      // Parse the AI response
      final outfits = await _parseAIResponse(content, availableItems, occasion, mood, weather);
      
      print('🎉 Generated ${outfits.length} AI-powered recommendations');
      return outfits;
      
    } catch (e) {
      print('❌ Error calling Mistral AI: $e');
      print('🔄 Falling back to rule-based recommendations');
      
      return _generateFallbackRecommendations(
        availableItems: availableItems,
        occasion: occasion,
        mood: mood,
        weather: weather,
        maxRecommendations: maxRecommendations,
      );
    }
  }

  String _buildContextPrompt({
    required List<ClothingItem> availableItems,
    required String occasion,
    required String mood,
    Weather? weather,
    required int maxRecommendations,
  }) {
    final buffer = StringBuffer();
    
    buffer.writeln('Create $maxRecommendations outfit recommendations for:');
    buffer.writeln('- Occasion: $occasion');
    buffer.writeln('- Mood: $mood');
    
    if (weather != null) {
      buffer.writeln('- Weather: ${weather.condition}, ${weather.temperature}°C');
      buffer.writeln('- Weather notes: ${weather.description}');
    }
    
    buffer.writeln('\nAvailable wardrobe items:');
    for (int i = 0; i < availableItems.length; i++) {
      final item = availableItems[i];
      buffer.writeln('${item.id}: ${item.name} (${item.category}, ${item.color}, ${item.season}, tags: ${item.tags.join(", ")})');
    }
    
    buffer.writeln('\nReturn exactly $maxRecommendations outfit recommendations as a JSON array.');
    
    return buffer.toString();
  }

  Future<List<Outfit>> _parseAIResponse(
    String content,
    List<ClothingItem> availableItems,
    String occasion,
    String mood,
    Weather? weather,
  ) async {
    try {
      // Clean the response - remove any markdown formatting
      String cleanContent = content.trim();
      if (cleanContent.startsWith('```json')) {
        cleanContent = cleanContent.substring(7);
      }
      if (cleanContent.endsWith('```')) {
        cleanContent = cleanContent.substring(0, cleanContent.length - 3);
      }
      cleanContent = cleanContent.trim();
      
      // Parse JSON
      final List<dynamic> recommendations = jsonDecode(cleanContent);
      final List<Outfit> outfits = [];
      
      for (final rec in recommendations) {
        try {
          final itemIds = List<int>.from(rec['items'] ?? []);
          final selectedItems = availableItems.where((item) => 
            itemIds.contains(item.id)
          ).toList();
          
          if (selectedItems.isNotEmpty) {
            final outfit = Outfit(
              name: rec['name'] ?? 'AI Generated Outfit',
              items: selectedItems,
              occasion: occasion,
              weather: weather?.condition ?? 'Unknown',
              mood: mood,
              createdAt: DateTime.now(),
              metadata: {
                'ai_confidence': rec['confidence']?.toString() ?? '0.8',
                'ai_reasoning': rec['reasoning'] ?? 'AI-powered recommendation',
                'style_tags': rec['style_tags']?.join(', ') ?? '',
              },
            );
            outfits.add(outfit);
          }
        } catch (e) {
          print('⚠️ Error parsing individual recommendation: $e');
          continue;
        }
      }
      
      return outfits;
    } catch (e) {
      print('❌ Error parsing AI response: $e');
      return [];
    }
  }

  /// Fallback recommendation system when AI is not available
  List<Outfit> _generateFallbackRecommendations({
    required List<ClothingItem> availableItems,
    required String occasion,
    required String mood,
    Weather? weather,
    int maxRecommendations = 5,
  }) {
    print('🔧 Using fallback recommendation system');
    
    final recommendations = <Outfit>[];
    final usedCombinations = <Set<int>>{};
    
    // Enhanced rule-based matching
    for (int i = 0; i < maxRecommendations * 3 && recommendations.length < maxRecommendations; i++) {
      final outfit = _generateSmartOutfit(
        availableItems,
        occasion,
        mood,
        weather,
        usedCombinations,
        attemptNumber: i,
      );
      
      if (outfit != null) {
        recommendations.add(outfit);
        usedCombinations.add(outfit.items.map((item) => item.id!).toSet());
      }
    }
    
    return recommendations;
  }

  Outfit? _generateSmartOutfit(
    List<ClothingItem> items,
    String occasion,
    String mood,
    Weather? weather,
    Set<Set<int>> usedCombinations, {
    int attemptNumber = 0,
  }) {
    // Smart outfit generation with better matching logic
    final seasonalItems = _filterByWeatherAndSeason(items, weather);
    final occasionItems = _filterByOccasion(seasonalItems, occasion);
    final moodItems = _filterByMood(occasionItems, mood);
    
    // Build outfit based on occasion requirements
    final outfitBuilder = _OutfitBuilder(moodItems.isNotEmpty ? moodItems : occasionItems);
    
    switch (occasion) {
      case Occasion.formal:
      case Occasion.work:
        return outfitBuilder.buildFormalOutfit(occasion, mood, weather, usedCombinations, attemptNumber);
      case Occasion.party:
      case Occasion.date:
        return outfitBuilder.buildPartyOutfit(occasion, mood, weather, usedCombinations, attemptNumber);
      case Occasion.sport:
        return outfitBuilder.buildSportOutfit(occasion, mood, weather, usedCombinations, attemptNumber);
      default:
        return outfitBuilder.buildCasualOutfit(occasion, mood, weather, usedCombinations, attemptNumber);
    }
  }

  List<ClothingItem> _filterByWeatherAndSeason(List<ClothingItem> items, Weather? weather) {
    if (weather == null) return items;
    
    return items.where((item) {
      if (weather.isCold) {
        return item.season == Season.winter || 
               item.season == Season.autumn || 
               item.season == Season.allSeason ||
               item.tags.contains('warm');
      } else if (weather.isHot) {
        return item.season == Season.summer || 
               item.season == Season.spring || 
               item.season == Season.allSeason ||
               item.tags.contains('light') ||
               item.tags.contains('breathable');
      }
      return true;
    }).toList();
  }

  List<ClothingItem> _filterByOccasion(List<ClothingItem> items, String occasion) {
    return items.where((item) {
      switch (occasion) {
        case Occasion.formal:
        case Occasion.work:
          return item.tags.contains('formal') || 
                 item.tags.contains('work') || 
                 item.tags.contains('professional');
        case Occasion.party:
        case Occasion.date:
          return item.tags.contains('party') || 
                 item.tags.contains('elegant') || 
                 item.tags.contains('dressy');
        case Occasion.sport:
          return item.tags.contains('sport') || 
                 item.tags.contains('active') || 
                 item.tags.contains('athletic');
        default:
          return true; // Casual accepts everything
      }
    }).toList();
  }

  List<ClothingItem> _filterByMood(List<ClothingItem> items, String mood) {
    if (items.length < 3) return items; // Don't filter too much if we have few items
    
    return items.where((item) {
      switch (mood) {
        case Mood.confident:
          return item.tags.contains('bold') || 
                 item.tags.contains('statement') ||
                 item.color.toLowerCase().contains('black') ||
                 item.color.toLowerCase().contains('red');
        case Mood.elegant:
          return item.tags.contains('elegant') || 
                 item.tags.contains('sophisticated') ||
                 item.category == ClothingCategory.dresses;
        case Mood.fun:
          return item.tags.contains('fun') || 
                 item.tags.contains('colorful') ||
                 item.tags.contains('bright');
        default:
          return true;
      }
    }).toList();
  }
}

class _OutfitBuilder {
  final List<ClothingItem> items;
  
  _OutfitBuilder(this.items);

  Outfit? buildFormalOutfit(String occasion, String mood, Weather? weather, Set<Set<int>> usedCombinations, int attemptNumber) {
    final tops = items.where((i) => i.category == ClothingCategory.tops).toList();
    final bottoms = items.where((i) => i.category == ClothingCategory.bottoms).toList();
    final outerwear = items.where((i) => i.category == ClothingCategory.outerwear).toList();
    final shoes = items.where((i) => i.category == ClothingCategory.shoes).toList();
    
    if (tops.isEmpty || bottoms.isEmpty) return null;
    
    // Shuffle lists based on attempt number to get different combinations
    tops.shuffle();
    bottoms.shuffle();
    outerwear.shuffle();
    shoes.shuffle();
    
    // Try different combinations until we find an unused one
    for (int i = 0; i < tops.length && i < 3; i++) {
      for (int j = 0; j < bottoms.length && j < 3; j++) {
        final selectedItems = <ClothingItem>[];
        
        // Use different indices based on attempt number
        final topIndex = (i + attemptNumber) % tops.length;
        final bottomIndex = (j + attemptNumber) % bottoms.length;
        
        selectedItems.add(tops[topIndex]);
        selectedItems.add(bottoms[bottomIndex]);
        
        if (outerwear.isNotEmpty) {
          final outerIndex = attemptNumber % outerwear.length;
          selectedItems.add(outerwear[outerIndex]);
        }
        if (shoes.isNotEmpty) {
          final shoeIndex = attemptNumber % shoes.length;
          selectedItems.add(shoes[shoeIndex]);
        }
        
        final combination = selectedItems.map((item) => item.id!).toSet();
        if (!usedCombinations.contains(combination)) {
          return Outfit(
            name: 'Professional ${mood.capitalize()} Look ${attemptNumber + 1}',
            items: selectedItems,
            occasion: occasion,
            weather: weather?.condition ?? 'Unknown',
            mood: mood,
            createdAt: DateTime.now(),
          );
        }
      }
    }
    return null;
  }

  Outfit? buildPartyOutfit(String occasion, String mood, Weather? weather, Set<Set<int>> usedCombinations, int attemptNumber) {
    final dresses = items.where((i) => i.category == ClothingCategory.dresses).toList();
    final tops = items.where((i) => i.category == ClothingCategory.tops).toList();
    final bottoms = items.where((i) => i.category == ClothingCategory.bottoms).toList();
    final accessories = items.where((i) => i.category == ClothingCategory.accessories).toList();
    
    dresses.shuffle();
    tops.shuffle();
    bottoms.shuffle();
    accessories.shuffle();
    
    final selectedItems = <ClothingItem>[];
    
    // Prefer dress, fallback to top+bottom
    if (dresses.isNotEmpty) {
      final dressIndex = attemptNumber % dresses.length;
      selectedItems.add(dresses[dressIndex]);
    } else if (tops.isNotEmpty && bottoms.isNotEmpty) {
      final topIndex = attemptNumber % tops.length;
      final bottomIndex = attemptNumber % bottoms.length;
      selectedItems.add(tops[topIndex]);
      selectedItems.add(bottoms[bottomIndex]);
    } else {
      return null;
    }
    
    if (accessories.isNotEmpty) {
      final accessoryIndex = attemptNumber % accessories.length;
      selectedItems.add(accessories[accessoryIndex]);
    }
    
    final combination = selectedItems.map((item) => item.id!).toSet();
    if (usedCombinations.contains(combination)) return null;
    
    return Outfit(
      name: 'Stylish ${mood.capitalize()} Party Look ${attemptNumber + 1}',
      items: selectedItems,
      occasion: occasion,
      weather: weather?.condition ?? 'Unknown',
      mood: mood,
      createdAt: DateTime.now(),
    );
  }

  Outfit? buildSportOutfit(String occasion, String mood, Weather? weather, Set<Set<int>> usedCombinations, int attemptNumber) {
    final tops = items.where((i) => i.category == ClothingCategory.tops).toList();
    final bottoms = items.where((i) => i.category == ClothingCategory.bottoms).toList();
    final shoes = items.where((i) => i.category == ClothingCategory.shoes).toList();
    
    if (tops.isEmpty || bottoms.isEmpty) return null;
    
    tops.shuffle();
    bottoms.shuffle();
    shoes.shuffle();
    
    final topIndex = attemptNumber % tops.length;
    final bottomIndex = attemptNumber % bottoms.length;
    
    final selectedItems = <ClothingItem>[tops[topIndex], bottoms[bottomIndex]];
    
    if (shoes.isNotEmpty) {
      final shoeIndex = attemptNumber % shoes.length;
      selectedItems.add(shoes[shoeIndex]);
    }
    
    final combination = selectedItems.map((item) => item.id!).toSet();
    if (usedCombinations.contains(combination)) return null;
    
    return Outfit(
      name: 'Active ${mood.capitalize()} Workout ${attemptNumber + 1}',
      items: selectedItems,
      occasion: occasion,
      weather: weather?.condition ?? 'Unknown',
      mood: mood,
      createdAt: DateTime.now(),
    );
  }

  Outfit? buildCasualOutfit(String occasion, String mood, Weather? weather, Set<Set<int>> usedCombinations, int attemptNumber) {
    final tops = items.where((i) => i.category == ClothingCategory.tops).toList();
    final bottoms = items.where((i) => i.category == ClothingCategory.bottoms).toList();
    
    if (tops.isEmpty || bottoms.isEmpty) return null;
    
    tops.shuffle();
    bottoms.shuffle();
    
    final topIndex = attemptNumber % tops.length;
    final bottomIndex = attemptNumber % bottoms.length;
    
    final selectedItems = <ClothingItem>[tops[topIndex], bottoms[bottomIndex]];
    
    final combination = selectedItems.map((item) => item.id!).toSet();
    if (usedCombinations.contains(combination)) return null;
    
    return Outfit(
      name: 'Comfortable ${mood.capitalize()} Style ${attemptNumber + 1}',
      items: selectedItems,
      occasion: occasion,
      weather: weather?.condition ?? 'Unknown',
      mood: mood,
      createdAt: DateTime.now(),
    );
  }
}

extension StringCapitalize on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
