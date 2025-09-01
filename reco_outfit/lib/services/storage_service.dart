import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/clothing_item.dart';
import '../models/outfit.dart';

class StorageService {
  static const String _clothingItemsKey = 'clothing_items';
  static const String _outfitsKey = 'outfits';
  
  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();
  StorageService._();

  // Initialize the storage service
  Future<void> initialize() async {
    // SharedPreferences doesn't need explicit initialization
    print('Storage service initialized with SharedPreferences');
  }

  // Clothing Items Storage
  Future<List<ClothingItem>> getClothingItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? itemsJson = prefs.getString(_clothingItemsKey);
      
      if (itemsJson == null) {
        print('No clothing items found in storage');
        return [];
      }
      
      final List<dynamic> itemsList = json.decode(itemsJson);
      final items = itemsList.map((item) => ClothingItem.fromMap(item)).toList();
      print('Loaded ${items.length} clothing items from storage');
      return items;
    } catch (e) {
      print('Error loading clothing items: $e');
      return [];
    }
  }

  Future<void> insertClothingItem(ClothingItem item) async {
    try {
      final items = await getClothingItems();
      
      // Find the highest ID and increment it
      int newId = 1;
      if (items.isNotEmpty) {
        newId = items.map((e) => e.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
      }
      
      final newItem = ClothingItem(
        id: newId,
        name: item.name,
        category: item.category,
        color: item.color,
        season: item.season,
        imagePath: item.imagePath,
        tags: item.tags,
        createdAt: item.createdAt,
      );
      
      items.add(newItem);
      await _saveClothingItems(items);
      print('Inserted clothing item: ${newItem.name} with ID: $newId');
    } catch (e) {
      print('Error inserting clothing item: $e');
      throw Exception('Failed to save clothing item');
    }
  }

  Future<void> updateClothingItem(ClothingItem item) async {
    try {
      final items = await getClothingItems();
      final index = items.indexWhere((i) => i.id == item.id);
      
      if (index != -1) {
        items[index] = item;
        await _saveClothingItems(items);
        print('Updated clothing item: ${item.name}');
      } else {
        throw Exception('Clothing item not found');
      }
    } catch (e) {
      print('Error updating clothing item: $e');
      throw Exception('Failed to update clothing item');
    }
  }

  Future<void> deleteClothingItem(int id) async {
    try {
      final items = await getClothingItems();
      items.removeWhere((item) => item.id == id);
      await _saveClothingItems(items);
      print('Deleted clothing item with ID: $id');
    } catch (e) {
      print('Error deleting clothing item: $e');
      throw Exception('Failed to delete clothing item');
    }
  }

  Future<void> _saveClothingItems(List<ClothingItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final itemsJson = json.encode(items.map((item) => item.toMap()).toList());
    await prefs.setString(_clothingItemsKey, itemsJson);
  }

  // Outfits Storage
  Future<List<Outfit>> getOutfits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? outfitsJson = prefs.getString(_outfitsKey);
      
      if (outfitsJson == null) {
        print('No outfits found in storage');
        return [];
      }
      
      // Get all clothing items first to resolve outfit items
      final allItems = await getClothingItems();
      
      final List<dynamic> outfitsList = json.decode(outfitsJson);
      final outfits = outfitsList.map((outfit) => Outfit.fromMap(outfit, allItems)).toList();
      print('Loaded ${outfits.length} outfits from storage');
      return outfits;
    } catch (e) {
      print('Error loading outfits: $e');
      return [];
    }
  }

  Future<void> insertOutfit(Outfit outfit) async {
    try {
      final outfits = await getOutfits();
      
      // Find the highest ID and increment it
      int newId = 1;
      if (outfits.isNotEmpty) {
        newId = outfits.map((e) => e.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
      }
      
      final newOutfit = Outfit(
        id: newId,
        name: outfit.name,
        items: outfit.items,
        occasion: outfit.occasion,
        weather: outfit.weather,
        mood: outfit.mood,
        createdAt: outfit.createdAt,
        rating: outfit.rating,
        metadata: outfit.metadata,
      );
      
      outfits.add(newOutfit);
      await _saveOutfits(outfits);
      print('Inserted outfit: ${newOutfit.name} with ID: $newId');
    } catch (e) {
      print('Error inserting outfit: $e');
      throw Exception('Failed to save outfit');
    }
  }

  Future<void> updateOutfit(Outfit outfit) async {
    try {
      final outfits = await getOutfits();
      final index = outfits.indexWhere((o) => o.id == outfit.id);
      
      if (index != -1) {
        outfits[index] = outfit;
        await _saveOutfits(outfits);
        print('Updated outfit: ${outfit.name}');
      } else {
        throw Exception('Outfit not found');
      }
    } catch (e) {
      print('Error updating outfit: $e');
      throw Exception('Failed to update outfit');
    }
  }

  Future<void> deleteOutfit(int id) async {
    try {
      final outfits = await getOutfits();
      outfits.removeWhere((outfit) => outfit.id == id);
      await _saveOutfits(outfits);
      print('Deleted outfit with ID: $id');
    } catch (e) {
      print('Error deleting outfit: $e');
      throw Exception('Failed to delete outfit');
    }
  }

  Future<void> _saveOutfits(List<Outfit> outfits) async {
    final prefs = await SharedPreferences.getInstance();
    final outfitsJson = json.encode(outfits.map((outfit) => outfit.toMap()).toList());
    await prefs.setString(_outfitsKey, outfitsJson);
  }

  // Clear all data
  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_clothingItemsKey);
      await prefs.remove(_outfitsKey);
      print('Cleared all data from storage');
    } catch (e) {
      print('Error clearing data: $e');
    }
  }
}
