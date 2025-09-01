import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/clothing_item.dart';
import '../../models/outfit.dart';
import '../../models/weather.dart';
import '../../services/storage_service.dart';
import '../../services/weather_service.dart';
import '../../services/ai_recommendation_service.dart';

// Wardrobe Events
abstract class WardrobeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadWardrobeEvent extends WardrobeEvent {}

class AddClothingItemEvent extends WardrobeEvent {
  final ClothingItem item;
  AddClothingItemEvent(this.item);
  
  @override
  List<Object> get props => [item];
}

class UpdateClothingItemEvent extends WardrobeEvent {
  final ClothingItem item;
  UpdateClothingItemEvent(this.item);
  
  @override
  List<Object> get props => [item];
}

class DeleteClothingItemEvent extends WardrobeEvent {
  final int id;
  DeleteClothingItemEvent(this.id);
  
  @override
  List<Object> get props => [id];
}

class SearchClothingItemsEvent extends WardrobeEvent {
  final String query;
  SearchClothingItemsEvent(this.query);
  
  @override
  List<Object> get props => [query];
}

class FilterByCategoryEvent extends WardrobeEvent {
  final String category;
  FilterByCategoryEvent(this.category);
  
  @override
  List<Object> get props => [category];
}

class LoadWeatherEvent extends WardrobeEvent {
  final String? city;
  LoadWeatherEvent([this.city]);
  
  @override
  List<Object?> get props => [city];
}

class GenerateRecommendationsEvent extends WardrobeEvent {
  final String occasion;
  final String mood;
  final int maxRecommendations;
  
  GenerateRecommendationsEvent({
    required this.occasion,
    required this.mood,
    this.maxRecommendations = 5,
  });
  
  @override
  List<Object> get props => [occasion, mood, maxRecommendations];
}

class LoadOutfitsEvent extends WardrobeEvent {}

class AddOutfitEvent extends WardrobeEvent {
  final Outfit outfit;
  AddOutfitEvent(this.outfit);
  
  @override
  List<Object> get props => [outfit];
}

class UpdateOutfitEvent extends WardrobeEvent {
  final Outfit outfit;
  UpdateOutfitEvent(this.outfit);
  
  @override
  List<Object> get props => [outfit];
}

class DeleteOutfitEvent extends WardrobeEvent {
  final int id;
  DeleteOutfitEvent(this.id);
  
  @override
  List<Object> get props => [id];
}

// Wardrobe State
class WardrobeState extends Equatable {
  final List<ClothingItem> clothingItems;
  final List<ClothingItem> filteredItems;
  final List<Outfit> outfits;
  final List<Outfit> recommendations;
  final Weather? currentWeather;
  final bool isLoading;
  final bool isLoadingRecommendations;
  final String selectedCategory;
  final String searchQuery;
  final String? error;

  const WardrobeState({
    this.clothingItems = const [],
    this.filteredItems = const [],
    this.outfits = const [],
    this.recommendations = const [],
    this.currentWeather,
    this.isLoading = false,
    this.isLoadingRecommendations = false,
    this.selectedCategory = 'All',
    this.searchQuery = '',
    this.error,
  });

  WardrobeState copyWith({
    List<ClothingItem>? clothingItems,
    List<ClothingItem>? filteredItems,
    List<Outfit>? outfits,
    List<Outfit>? recommendations,
    Weather? currentWeather,
    bool? isLoading,
    bool? isLoadingRecommendations,
    String? selectedCategory,
    String? searchQuery,
    String? error,
  }) {
    return WardrobeState(
      clothingItems: clothingItems ?? this.clothingItems,
      filteredItems: filteredItems ?? this.filteredItems,
      outfits: outfits ?? this.outfits,
      recommendations: recommendations ?? this.recommendations,
      currentWeather: currentWeather ?? this.currentWeather,
      isLoading: isLoading ?? this.isLoading,
      isLoadingRecommendations: isLoadingRecommendations ?? this.isLoadingRecommendations,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    clothingItems,
    filteredItems,
    outfits,
    recommendations,
    currentWeather,
    isLoading,
    isLoadingRecommendations,
    selectedCategory,
    searchQuery,
    error,
  ];
}

// Wardrobe BLoC
class WardrobeBloc extends Bloc<WardrobeEvent, WardrobeState> {
  final StorageService _storageService = StorageService.instance;
  final WeatherService _weatherService = WeatherService();
  final AIRecommendationService _aiRecommendationService = AIRecommendationService();

  WardrobeBloc() : super(const WardrobeState()) {
    on<LoadWardrobeEvent>(_onLoadWardrobe);
    on<AddClothingItemEvent>(_onAddClothingItem);
    on<UpdateClothingItemEvent>(_onUpdateClothingItem);
    on<DeleteClothingItemEvent>(_onDeleteClothingItem);
    on<SearchClothingItemsEvent>(_onSearchClothingItems);
    on<FilterByCategoryEvent>(_onFilterByCategory);
    on<LoadWeatherEvent>(_onLoadWeather);
    on<GenerateRecommendationsEvent>(_onGenerateRecommendations);
    on<LoadOutfitsEvent>(_onLoadOutfits);
    on<AddOutfitEvent>(_onAddOutfit);
    on<UpdateOutfitEvent>(_onUpdateOutfit);
    on<DeleteOutfitEvent>(_onDeleteOutfit);
  }

  Future<void> _onLoadWardrobe(LoadWardrobeEvent event, Emitter<WardrobeState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    
    try {
      await _storageService.initialize();
      
      final clothingItems = await _storageService.getClothingItems();
      final outfits = await _storageService.getOutfits();
      
      emit(state.copyWith(
        clothingItems: clothingItems,
        filteredItems: _getFilteredItems(clothingItems, state.selectedCategory, state.searchQuery),
        outfits: outfits,
        isLoading: false,
      ));
      
      // Load weather in background
      add(LoadWeatherEvent());
      
    } catch (e) {
      print('Error loading wardrobe: $e');
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to load wardrobe: $e',
      ));
    }
  }

  Future<void> _onAddClothingItem(AddClothingItemEvent event, Emitter<WardrobeState> emit) async {
    try {
      await _storageService.insertClothingItem(event.item);
      final updatedItems = await _storageService.getClothingItems();
      
      emit(state.copyWith(
        clothingItems: updatedItems,
        filteredItems: _getFilteredItems(updatedItems, state.selectedCategory, state.searchQuery),
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(error: 'Failed to add item: $e'));
    }
  }

  Future<void> _onUpdateClothingItem(UpdateClothingItemEvent event, Emitter<WardrobeState> emit) async {
    try {
      await _storageService.updateClothingItem(event.item);
      final updatedItems = List<ClothingItem>.from(state.clothingItems);
      final index = updatedItems.indexWhere((item) => item.id == event.item.id);
      
      if (index != -1) {
        updatedItems[index] = event.item;
        emit(state.copyWith(
          clothingItems: updatedItems,
          filteredItems: _getFilteredItems(updatedItems, state.selectedCategory, state.searchQuery),
          error: null,
        ));
      }
    } catch (e) {
      emit(state.copyWith(error: 'Failed to update item: $e'));
    }
  }

  Future<void> _onDeleteClothingItem(DeleteClothingItemEvent event, Emitter<WardrobeState> emit) async {
    try {
      await _storageService.deleteClothingItem(event.id);
      final updatedItems = state.clothingItems.where((item) => item.id != event.id).toList();
      
      emit(state.copyWith(
        clothingItems: updatedItems,
        filteredItems: _getFilteredItems(updatedItems, state.selectedCategory, state.searchQuery),
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(error: 'Failed to delete item: $e'));
    }
  }

  void _onSearchClothingItems(SearchClothingItemsEvent event, Emitter<WardrobeState> emit) {
    final filteredItems = _getFilteredItems(state.clothingItems, state.selectedCategory, event.query);
    
    emit(state.copyWith(
      searchQuery: event.query,
      filteredItems: filteredItems,
    ));
  }

  void _onFilterByCategory(FilterByCategoryEvent event, Emitter<WardrobeState> emit) {
    final filteredItems = _getFilteredItems(state.clothingItems, event.category, state.searchQuery);
    
    emit(state.copyWith(
      selectedCategory: event.category,
      filteredItems: filteredItems,
    ));
  }

  Future<void> _onLoadWeather(LoadWeatherEvent event, Emitter<WardrobeState> emit) async {
    try {
      Weather? weather;
      
      if (event.city != null && event.city!.isNotEmpty) {
        weather = await _weatherService.getCurrentWeather(event.city!);
      } else {
        weather = await _weatherService.getWeatherWithLocation();
      }
      
      weather ??= _weatherService.getMockWeather();
      
      emit(state.copyWith(currentWeather: weather, error: null));
      
    } catch (e) {
      print('Error loading weather: $e');
      final mockWeather = _weatherService.getMockWeather();
      emit(state.copyWith(currentWeather: mockWeather));
    }
  }

  Future<void> _onGenerateRecommendations(GenerateRecommendationsEvent event, Emitter<WardrobeState> emit) async {
    emit(state.copyWith(isLoadingRecommendations: true, error: null));
    
    try {
      final recommendations = await _aiRecommendationService.generateRecommendations(
        availableItems: state.clothingItems,
        occasion: event.occasion,
        mood: event.mood,
        weather: state.currentWeather,
        maxRecommendations: event.maxRecommendations,
      );
      
      emit(state.copyWith(
        recommendations: recommendations,
        isLoadingRecommendations: false,
      ));
    } catch (e) {
      print('Error generating recommendations: $e');
      emit(state.copyWith(
        recommendations: [],
        isLoadingRecommendations: false,
        error: 'Failed to generate recommendations: $e',
      ));
    }
  }

  Future<void> _onLoadOutfits(LoadOutfitsEvent event, Emitter<WardrobeState> emit) async {
    try {
      final outfits = await _storageService.getOutfits();
      emit(state.copyWith(outfits: outfits, error: null));
    } catch (e) {
      emit(state.copyWith(error: 'Failed to load outfits: $e'));
    }
  }

  Future<void> _onAddOutfit(AddOutfitEvent event, Emitter<WardrobeState> emit) async {
    try {
      await _storageService.insertOutfit(event.outfit);
      final updatedOutfits = await _storageService.getOutfits();
      
      emit(state.copyWith(outfits: updatedOutfits, error: null));
    } catch (e) {
      emit(state.copyWith(error: 'Failed to add outfit: $e'));
    }
  }

  Future<void> _onUpdateOutfit(UpdateOutfitEvent event, Emitter<WardrobeState> emit) async {
    try {
      await _storageService.updateOutfit(event.outfit);
      final updatedOutfits = List<Outfit>.from(state.outfits);
      final index = updatedOutfits.indexWhere((outfit) => outfit.id == event.outfit.id);
      
      if (index != -1) {
        updatedOutfits[index] = event.outfit;
        emit(state.copyWith(outfits: updatedOutfits, error: null));
      }
    } catch (e) {
      emit(state.copyWith(error: 'Failed to update outfit: $e'));
    }
  }

  Future<void> _onDeleteOutfit(DeleteOutfitEvent event, Emitter<WardrobeState> emit) async {
    try {
      await _storageService.deleteOutfit(event.id);
      final updatedOutfits = state.outfits.where((outfit) => outfit.id != event.id).toList();
      
      emit(state.copyWith(outfits: updatedOutfits, error: null));
    } catch (e) {
      emit(state.copyWith(error: 'Failed to delete outfit: $e'));
    }
  }

  List<ClothingItem> _getFilteredItems(List<ClothingItem> items, String category, String searchQuery) {
    var filtered = items;
    
    // Filter by category
    if (category != 'All') {
      filtered = filtered.where((item) => item.category == category).toList();
    }
    
    // Filter by search query
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((item) =>
        item.name.toLowerCase().contains(query) ||
        item.category.toLowerCase().contains(query) ||
        item.color.toLowerCase().contains(query) ||
        item.tags.any((tag) => tag.toLowerCase().contains(query))
      ).toList();
    }
    
    return filtered;
  }

  // Helper getters for backwards compatibility
  int get totalItems => state.clothingItems.length;
  int get totalOutfits => state.outfits.length;
  
  Map<String, int> getCategoryStats() {
    Map<String, int> stats = {};
    for (String category in ClothingCategory.all) {
      stats[category] = state.clothingItems.where((item) => item.category == category).length;
    }
    return stats;
  }
}
