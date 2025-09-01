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
    print('🔧 Using enhanced fallback recommendation system');
    print('Weather: ${weather?.condition} ${weather?.temperature}°C');
    
    final recommendations = <Outfit>[];
    final usedItemCombinations = <Set<int>>{};
    
    // Create diverse outfit styles based on different approaches
    final outfitStrategies = [
      _createWeatherBasedOutfit,
      _createColorCoordinatedOutfit,
      _createLayeredOutfit,
      _createMinimalistOutfit,
      _createStatementOutfit,
    ];
    
    for (int i = 0; i < outfitStrategies.length && recommendations.length < maxRecommendations; i++) {
      final outfit = outfitStrategies[i](
        availableItems,
        occasion,
        mood,
        weather,
        usedItemCombinations,
        i,
      );
      
      if (outfit != null) {
        final itemIds = outfit.items.map((item) => item.id!).toSet();
        if (!usedItemCombinations.contains(itemIds)) {
          recommendations.add(outfit);
          usedItemCombinations.add(itemIds);
          print('✅ Created ${outfit.name} with ${outfit.items.length} items');
        }
      }
    }
    
    // If we still need more recommendations, try variations
    while (recommendations.length < maxRecommendations && recommendations.length < availableItems.length ~/ 2) {
      final outfit = _createVariationOutfit(
        availableItems,
        occasion,
        mood,
        weather,
        usedItemCombinations,
        recommendations.length,
      );
      
      if (outfit != null) {
        final itemIds = outfit.items.map((item) => item.id!).toSet();
        if (!usedItemCombinations.contains(itemIds)) {
          recommendations.add(outfit);
          usedItemCombinations.add(itemIds);
        }
      } else {
        break; // No more unique combinations possible
      }
    }
    
    return recommendations;
  }

  // Weather-focused outfit - prioritizes weather appropriateness
  Outfit? _createWeatherBasedOutfit(
    List<ClothingItem> items,
    String occasion,
    String mood,
    Weather? weather,
    Set<Set<int>> usedCombinations,
    int index,
  ) {
    final seasonalItems = _filterByWeatherAndSeason(items, weather);
    if (seasonalItems.length < 2) return null;
    
    final selectedItems = <ClothingItem>[];
    
    if (weather?.isCold == true) {
      // Cold weather outfit
      final warmTops = seasonalItems.where((i) => 
        i.category == ClothingCategory.tops && 
        (i.tags.contains('warm') || i.season == Season.winter)
      ).toList();
      
      final bottoms = seasonalItems.where((i) => i.category == ClothingCategory.bottoms).toList();
      final outerwear = seasonalItems.where((i) => 
        i.category == ClothingCategory.outerwear || 
        i.tags.contains('jacket') || 
        i.tags.contains('coat')
      ).toList();
      
      if (warmTops.isNotEmpty) selectedItems.add(warmTops.first);
      if (bottoms.isNotEmpty) selectedItems.add(bottoms.first);
      if (outerwear.isNotEmpty) selectedItems.add(outerwear.first);
      
      return selectedItems.length >= 2 ? Outfit(
        name: 'Cozy Winter ${mood.capitalize()} Look',
        items: selectedItems,
        occasion: occasion,
        weather: weather?.condition ?? 'Cold',
        mood: mood,
        createdAt: DateTime.now(),
        metadata: {
          'style_focus': 'Weather-appropriate layering',
          'temperature': '${weather?.temperatureCelsius.toStringAsFixed(1) ?? '0'}°C',
        },
      ) : null;
      
    } else if (weather?.isHot == true) {
      // Hot weather outfit
      final lightTops = seasonalItems.where((i) => 
        i.category == ClothingCategory.tops && 
        (i.tags.contains('light') || i.tags.contains('breathable') || i.season == Season.summer)
      ).toList();
      
      final lightBottoms = seasonalItems.where((i) => 
        i.category == ClothingCategory.bottoms && 
        (i.tags.contains('light') || i.tags.contains('shorts') || i.season == Season.summer)
      ).toList();
      
      if (lightTops.isNotEmpty) selectedItems.add(lightTops.first);
      if (lightBottoms.isNotEmpty) selectedItems.add(lightBottoms.first);
      
      return selectedItems.length >= 2 ? Outfit(
        name: 'Cool Summer ${mood.capitalize()} Style',
        items: selectedItems,
        occasion: occasion,
        weather: weather?.condition ?? 'Hot',
        mood: mood,
        createdAt: DateTime.now(),
        metadata: {
          'style_focus': 'Breathable and light fabrics',
          'temperature': '${weather?.temperatureCelsius.toStringAsFixed(1) ?? '25'}°C',
        },
      ) : null;
    }
    
    return null;
  }

  // Color-coordinated outfit - focuses on matching colors
  Outfit? _createColorCoordinatedOutfit(
    List<ClothingItem> items,
    String occasion,
    String mood,
    Weather? weather,
    Set<Set<int>> usedCombinations,
    int index,
  ) {
    final seasonalItems = _filterByWeatherAndSeason(items, weather);
    
    // Group items by color families
    final neutrals = seasonalItems.where((i) => 
      i.color.toLowerCase().contains('black') ||
      i.color.toLowerCase().contains('white') ||
      i.color.toLowerCase().contains('gray') ||
      i.color.toLowerCase().contains('navy') ||
      i.color.toLowerCase().contains('beige')
    ).toList();
    
    final colorful = seasonalItems.where((i) => !neutrals.contains(i)).toList();
    
    final selectedItems = <ClothingItem>[];
    
    if (neutrals.length >= 2) {
      // Create monochromatic neutral outfit
      final tops = neutrals.where((i) => i.category == ClothingCategory.tops).toList();
      final bottoms = neutrals.where((i) => i.category == ClothingCategory.bottoms).toList();
      
      if (tops.isNotEmpty) selectedItems.add(tops.first);
      if (bottoms.isNotEmpty) selectedItems.add(bottoms.first);
      
      // Add accent piece if available
      if (colorful.isNotEmpty && selectedItems.length >= 2) {
        selectedItems.add(colorful.first);
      }
    }
    
    return selectedItems.length >= 2 ? Outfit(
      name: 'Coordinated ${mood.capitalize()} Ensemble',
      items: selectedItems,
      occasion: occasion,
      weather: weather?.condition ?? 'Unknown',
      mood: mood,
      createdAt: DateTime.now(),
      metadata: {
        'style_focus': 'Color harmony and coordination',
        'color_scheme': selectedItems.length >= 2 ? '${selectedItems[0].color} + ${selectedItems[1].color}' : 'Mixed',
      },
    ) : null;
  }

  // Layered outfit - creates depth with multiple pieces
  Outfit? _createLayeredOutfit(
    List<ClothingItem> items,
    String occasion,
    String mood,
    Weather? weather,
    Set<Set<int>> usedCombinations,
    int index,
  ) {
    final seasonalItems = _filterByWeatherAndSeason(items, weather);
    
    final selectedItems = <ClothingItem>[];
    final tops = seasonalItems.where((i) => i.category == ClothingCategory.tops).toList();
    final bottoms = seasonalItems.where((i) => i.category == ClothingCategory.bottoms).toList();
    final outerwear = seasonalItems.where((i) => i.category == ClothingCategory.outerwear).toList();
    final accessories = seasonalItems.where((i) => i.category == ClothingCategory.accessories).toList();
    
    // Build layered look
    if (tops.length >= 2) {
      selectedItems.add(tops[0]); // Base layer
      if (outerwear.isNotEmpty) {
        selectedItems.add(outerwear.first); // Outer layer
      } else if (tops.length > 1) {
        selectedItems.add(tops[1]); // Second top as layer
      }
    } else if (tops.isNotEmpty) {
      selectedItems.add(tops.first);
      if (outerwear.isNotEmpty) selectedItems.add(outerwear.first);
    }
    
    if (bottoms.isNotEmpty) selectedItems.add(bottoms.first);
    if (accessories.isNotEmpty && selectedItems.length >= 2) selectedItems.add(accessories.first);
    
    return selectedItems.length >= 3 ? Outfit(
      name: 'Layered ${mood.capitalize()} Look',
      items: selectedItems,
      occasion: occasion,
      weather: weather?.condition ?? 'Unknown',
      mood: mood,
      createdAt: DateTime.now(),
      metadata: {
        'style_focus': 'Layered textures and depth',
        'layers': '${selectedItems.length} pieces',
      },
    ) : null;
  }

  // Minimalist outfit - simple, clean combinations
  Outfit? _createMinimalistOutfit(
    List<ClothingItem> items,
    String occasion,
    String mood,
    Weather? weather,
    Set<Set<int>> usedCombinations,
    int index,
  ) {
    final seasonalItems = _filterByWeatherAndSeason(items, weather);
    
    // Look for clean, simple pieces
    final simpleItems = seasonalItems.where((i) => 
      !i.tags.contains('bold') && 
      !i.tags.contains('statement') &&
      (i.color.toLowerCase().contains('white') ||
       i.color.toLowerCase().contains('black') ||
       i.color.toLowerCase().contains('gray') ||
       i.color.toLowerCase().contains('navy'))
    ).toList();
    
    final tops = simpleItems.where((i) => i.category == ClothingCategory.tops).toList();
    final bottoms = simpleItems.where((i) => i.category == ClothingCategory.bottoms).toList();
    
    final selectedItems = <ClothingItem>[];
    if (tops.isNotEmpty) selectedItems.add(tops.first);
    if (bottoms.isNotEmpty) selectedItems.add(bottoms.first);
    
    return selectedItems.length >= 2 ? Outfit(
      name: 'Minimalist ${mood.capitalize()} Chic',
      items: selectedItems,
      occasion: occasion,
      weather: weather?.condition ?? 'Unknown',
      mood: mood,
      createdAt: DateTime.now(),
      metadata: {
        'style_focus': 'Clean lines and simplicity',
        'aesthetic': 'Minimalist',
      },
    ) : null;
  }

  // Statement outfit - bold, attention-grabbing pieces
  Outfit? _createStatementOutfit(
    List<ClothingItem> items,
    String occasion,
    String mood,
    Weather? weather,
    Set<Set<int>> usedCombinations,
    int index,
  ) {
    final seasonalItems = _filterByWeatherAndSeason(items, weather);
    
    // Look for bold, statement pieces
    final statementItems = seasonalItems.where((i) => 
      i.tags.contains('bold') ||
      i.tags.contains('statement') ||
      i.tags.contains('bright') ||
      i.category == ClothingCategory.dresses ||
      i.color.toLowerCase().contains('red') ||
      i.color.toLowerCase().contains('purple') ||
      i.color.toLowerCase().contains('yellow')
    ).toList();
    
    if (statementItems.isEmpty) return null;
    
    final selectedItems = <ClothingItem>[];
    
    // If we have a statement dress, use it
    final dresses = statementItems.where((i) => i.category == ClothingCategory.dresses).toList();
    if (dresses.isNotEmpty) {
      selectedItems.add(dresses.first);
    } else {
      // Build around statement piece
      final statementPiece = statementItems.first;
      selectedItems.add(statementPiece);
      
      // Add complementary neutral pieces
      final neutrals = seasonalItems.where((i) => 
        !statementItems.contains(i) &&
        (i.color.toLowerCase().contains('black') ||
         i.color.toLowerCase().contains('white') ||
         i.color.toLowerCase().contains('gray'))
      ).toList();
      
      if (statementPiece.category == ClothingCategory.tops) {
        final bottoms = neutrals.where((i) => i.category == ClothingCategory.bottoms).toList();
        if (bottoms.isNotEmpty) selectedItems.add(bottoms.first);
      } else if (statementPiece.category == ClothingCategory.bottoms) {
        final tops = neutrals.where((i) => i.category == ClothingCategory.tops).toList();
        if (tops.isNotEmpty) selectedItems.add(tops.first);
      }
    }
    
    return selectedItems.length >= 1 ? Outfit(
      name: 'Bold ${mood.capitalize()} Statement',
      items: selectedItems,
      occasion: occasion,
      weather: weather?.condition ?? 'Unknown',
      mood: mood,
      createdAt: DateTime.now(),
      metadata: {
        'style_focus': 'Bold statement pieces',
        'statement_item': selectedItems.first.name,
      },
    ) : null;
  }

  // Create variation of existing outfits
  Outfit? _createVariationOutfit(
    List<ClothingItem> items,
    String occasion,
    String mood,
    Weather? weather,
    Set<Set<int>> usedCombinations,
    int index,
  ) {
    final seasonalItems = _filterByWeatherAndSeason(items, weather);
    final availableItems = seasonalItems.where((item) => 
      !usedCombinations.any((combination) => combination.contains(item.id!))
    ).toList();
    
    if (availableItems.length < 2) return null;
    
    final tops = availableItems.where((i) => i.category == ClothingCategory.tops).toList();
    final bottoms = availableItems.where((i) => i.category == ClothingCategory.bottoms).toList();
    
    final selectedItems = <ClothingItem>[];
    if (tops.isNotEmpty) selectedItems.add(tops.first);
    if (bottoms.isNotEmpty) selectedItems.add(bottoms.first);
    
    if (selectedItems.length < 2) {
      // Try any remaining combinations
      if (availableItems.length >= 2) {
        selectedItems.clear();
        selectedItems.addAll(availableItems.take(2));
      }
    }
    
    return selectedItems.length >= 2 ? Outfit(
      name: 'Alternative ${mood.capitalize()} Mix',
      items: selectedItems,
      occasion: occasion,
      weather: weather?.condition ?? 'Unknown',
      mood: mood,
      createdAt: DateTime.now(),
      metadata: {
        'style_focus': 'Creative combination',
        'variation_number': '${index + 1}',
      },
    ) : null;
  }

  List<ClothingItem> _filterByWeatherAndSeason(List<ClothingItem> items, Weather? weather) {
    if (weather == null) return items;
    
    double tempCelsius = weather.temperatureCelsius;
    print('🌡️ Filtering for weather: ${weather.condition}, ${tempCelsius.toStringAsFixed(1)}°C');
    
    return items.where((item) {
      // Very cold weather (< 0°C)
      if (tempCelsius < 0) {
        return item.season == Season.winter || 
               item.tags.contains('warm') ||
               item.tags.contains('thermal') ||
               item.tags.contains('winter') ||
               item.tags.contains('coat') ||
               item.tags.contains('heavy');
      }
      // Cold weather (0-15°C)
      else if (tempCelsius <= 15) {
        return item.season == Season.winter || 
               item.season == Season.autumn || 
               item.season == Season.allSeason ||
               item.tags.contains('warm') ||
               item.tags.contains('layer') ||
               item.tags.contains('jacket');
      }
      // Mild weather (16-24°C)
      else if (tempCelsius <= 24) {
        return item.season == Season.spring || 
               item.season == Season.autumn || 
               item.season == Season.allSeason ||
               !item.tags.contains('heavy') ||
               !item.tags.contains('thermal');
      }
      // Hot weather (> 24°C)
      else {
        return item.season == Season.summer || 
               item.season == Season.spring || 
               item.season == Season.allSeason ||
               item.tags.contains('light') ||
               item.tags.contains('breathable') ||
               item.tags.contains('cotton') ||
               item.tags.contains('linen') ||
               item.tags.contains('shorts') ||
               !item.tags.contains('warm') &&
               !item.tags.contains('heavy');
      }
    }).toList();
  }
}

extension StringCapitalize on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
