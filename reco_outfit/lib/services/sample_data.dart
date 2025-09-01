import '../models/clothing_item.dart';

class SampleData {
  static List<ClothingItem> getSampleClothingItems() {
    return [
      ClothingItem(
        id: 1,
        name: 'Blue Denim Jeans',
        category: ClothingCategory.bottoms,
        color: 'Blue',
        season: Season.allSeason,
        imagePath: 'assets/images/sample_jeans.jpg',
        tags: ['casual', 'denim', 'comfortable'],
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      ClothingItem(
        id: 2,
        name: 'White Cotton T-Shirt',
        category: ClothingCategory.tops,
        color: 'White',
        season: Season.summer,
        imagePath: 'assets/images/sample_tshirt.jpg',
        tags: ['casual', 'cotton', 'basic'],
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
      ClothingItem(
        id: 3,
        name: 'Black Blazer',
        category: ClothingCategory.outerwear,
        color: 'Black',
        season: Season.allSeason,
        imagePath: 'assets/images/sample_blazer.jpg',
        tags: ['formal', 'work', 'professional'],
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      ClothingItem(
        id: 4,
        name: 'Red Summer Dress',
        category: ClothingCategory.dresses,
        color: 'Red',
        season: Season.summer,
        imagePath: 'assets/images/sample_dress.jpg',
        tags: ['party', 'elegant', 'summer'],
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      ClothingItem(
        id: 5,
        name: 'Brown Leather Shoes',
        category: ClothingCategory.shoes,
        color: 'Brown',
        season: Season.allSeason,
        imagePath: 'assets/images/sample_shoes.jpg',
        tags: ['formal', 'leather', 'work'],
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      ClothingItem(
        id: 6,
        name: 'Navy Wool Sweater',
        category: ClothingCategory.tops,
        color: 'Navy',
        season: Season.winter,
        imagePath: 'assets/images/sample_sweater.jpg',
        tags: ['warm', 'wool', 'cozy'],
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }
}
