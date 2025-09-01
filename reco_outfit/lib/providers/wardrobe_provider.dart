import 'package:flutter/material.dart';
import '../models/clothing_item.dart';
import '../models/outfit.dart';
import '../models/weather.dart';
import '../services/storage_service.dart';
import '../services/weather_service.dart';
import '../services/ai_recommendation_service.dart';

class WardrobeProvider with ChangeNotifier {
  final StorageService _storageService = StorageService.instance;
  final WeatherService _weatherService = WeatherService();
  final AIRecommendationService _aiRecommendationService = AIRecommendationService();

  List<ClothingItem> _clothingItems = [];
  List<Outfit> _outfits = [];
  List<Outfit> _recommendations = [];
  Weather? _currentWeather;
  bool _isLoading = false;
  String _selectedCategory = 'All';

  // Getters
  List<ClothingItem> get clothingItems => _selectedCategory == 'All' 
      ? _clothingItems 
      : _clothingItems.where((item) => item.category == _selectedCategory).toList();
  
  List<ClothingItem> get allClothingItems => _clothingItems;
  List<Outfit> get outfits => _outfits;
  List<Outfit> get recommendations => _recommendations;
  Weather? get currentWeather => _currentWeather;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;

  // Initialize the provider
  Future<void> initialize() async {
    _setLoading(true);
    
    try {
      await _storageService.initialize();
      await loadClothingItems();
      await loadOutfits();
      await loadWeather();
      
      print('Initialization complete. Items loaded: ${_clothingItems.length}');
    } catch (e) {
      print('Error during initialization: $e');
    }
    
    _setLoading(false);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Clothing Items operations
  Future<void> loadClothingItems() async {
    _clothingItems = await _storageService.getClothingItems();
    notifyListeners();
  }

  Future<void> addClothingItem(ClothingItem item) async {
    await _storageService.insertClothingItem(item);
    await loadClothingItems(); // Reload to get the item with ID
  }

  Future<void> updateClothingItem(ClothingItem item) async {
    await _storageService.updateClothingItem(item);
    final index = _clothingItems.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _clothingItems[index] = item;
      notifyListeners();
    }
  }

  Future<void> deleteClothingItem(int id) async {
    await _storageService.deleteClothingItem(id);
    _clothingItems.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  // Category filtering
  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Outfits operations
  Future<void> loadOutfits() async {
    _outfits = await _storageService.getOutfits();
    notifyListeners();
  }

  Future<void> addOutfit(Outfit outfit) async {
    await _storageService.insertOutfit(outfit);
    await loadOutfits(); // Reload to get the outfit with ID
  }

  Future<void> updateOutfit(Outfit outfit) async {
    await _storageService.updateOutfit(outfit);
    final index = _outfits.indexWhere((o) => o.id == outfit.id);
    if (index != -1) {
      _outfits[index] = outfit;
      notifyListeners();
    }
  }

  Future<void> deleteOutfit(int id) async {
    await _storageService.deleteOutfit(id);
    _outfits.removeWhere((outfit) => outfit.id == id);
    notifyListeners();
  }

  // Weather operations
  Future<void> loadWeather([String? city]) async {
    try {
      if (city != null && city.isNotEmpty) {
        // Load weather for specific city
        _currentWeather = await _weatherService.getCurrentWeather(city);
      } else {
        // Load weather for current location
        _currentWeather = await _weatherService.getWeatherWithLocation();
      }
      
      if (_currentWeather == null) {
        // Fallback to mock weather if all else fails
        _currentWeather = _weatherService.getMockWeather();
      }
      
      print('Weather loaded: ${_currentWeather!.location} - ${_currentWeather!.temperatureInCelsius}');
      notifyListeners();
    } catch (e) {
      print('Error loading weather: $e');
      _currentWeather = _weatherService.getMockWeather();
      notifyListeners();
    }
  }

  /// Load weather for current location
  Future<void> loadCurrentLocationWeather() async {
    try {
      _currentWeather = await _weatherService.getCurrentLocationWeather();
      if (_currentWeather == null) {
        _currentWeather = _weatherService.getMockWeather();
      }
      print('Location weather loaded: ${_currentWeather!.location} - ${_currentWeather!.temperatureInCelsius}');
      notifyListeners();
    } catch (e) {
      print('Error loading location weather: $e');
      _currentWeather = _weatherService.getMockWeather();
      notifyListeners();
    }
  }

  /// Check if weather service is configured properly
  bool get isWeatherConfigured => _weatherService.isConfigured();

  /// Get weather service status
  String get weatherServiceStatus => _weatherService.getStatusMessage();

  // Outfit recommendations
  Future<void> generateRecommendations({
    required String occasion,
    required String mood,
    int maxRecommendations = 5,
  }) async {
    _setLoading(true);
    
    try {
      _recommendations = await _aiRecommendationService.generateRecommendations(
        availableItems: _clothingItems,
        occasion: occasion,
        mood: mood,
        weather: _currentWeather,
        maxRecommendations: maxRecommendations,
      );
    } catch (e) {
      print('Error generating AI recommendations: $e');
      _recommendations = [];
    }
    
    _setLoading(false);
  }

  // Search functionality
  Future<List<ClothingItem>> searchClothingItems(String query) async {
    if (query.isEmpty) return _clothingItems;
    
    // Simple search implementation for SharedPreferences
    final lowercaseQuery = query.toLowerCase();
    return _clothingItems.where((item) =>
      item.name.toLowerCase().contains(lowercaseQuery) ||
      item.category.toLowerCase().contains(lowercaseQuery) ||
      item.color.toLowerCase().contains(lowercaseQuery) ||
      item.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery))
    ).toList();
  }

  // Get items by category
  List<ClothingItem> getItemsByCategory(String category) {
    return _clothingItems.where((item) => item.category == category).toList();
  }

  // Get items by season
  List<ClothingItem> getItemsBySeason(String season) {
    return _clothingItems.where((item) => 
      item.season == season || item.season == Season.allSeason
    ).toList();
  }

  // Statistics
  Map<String, int> getCategoryStats() {
    Map<String, int> stats = {};
    for (String category in ClothingCategory.all) {
      stats[category] = _clothingItems.where((item) => item.category == category).length;
    }
    return stats;
  }

  int get totalItems => _clothingItems.length;
  int get totalOutfits => _outfits.length;

  // Clear all recommendations
  void clearRecommendations() {
    _recommendations.clear();
    notifyListeners();
  }
}
