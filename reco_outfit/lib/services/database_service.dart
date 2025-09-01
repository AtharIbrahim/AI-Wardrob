import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/clothing_item.dart';
import '../models/outfit.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'wardrobe.db');
    
    return await openDatabase(
      path,
      version: 2, // Increment version to trigger upgrade
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create clothing_items table
    await db.execute('''
      CREATE TABLE clothing_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        color TEXT NOT NULL,
        season TEXT NOT NULL,
        imagePath TEXT NOT NULL,
        tags TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    // Create outfits table with metadata field
    await db.execute('''
      CREATE TABLE outfits(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        itemIds TEXT NOT NULL,
        occasion TEXT NOT NULL,
        weather TEXT NOT NULL,
        mood TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        rating REAL,
        metadata TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add metadata column to outfits table
      await db.execute('ALTER TABLE outfits ADD COLUMN metadata TEXT');
    }
  }

  // Clothing Items CRUD operations
  Future<int> insertClothingItem(ClothingItem item) async {
    final db = await database;
    return await db.insert('clothing_items', item.toMap());
  }

  Future<List<ClothingItem>> getAllClothingItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('clothing_items');
    
    return List.generate(maps.length, (i) {
      return ClothingItem.fromMap(maps[i]);
    });
  }

  Future<List<ClothingItem>> getClothingItemsByCategory(String category) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'clothing_items',
      where: 'category = ?',
      whereArgs: [category],
    );
    
    return List.generate(maps.length, (i) {
      return ClothingItem.fromMap(maps[i]);
    });
  }

  Future<List<ClothingItem>> getClothingItemsBySeason(String season) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'clothing_items',
      where: 'season = ? OR season = ?',
      whereArgs: [season, 'All Season'],
    );
    
    return List.generate(maps.length, (i) {
      return ClothingItem.fromMap(maps[i]);
    });
  }

  Future<int> updateClothingItem(ClothingItem item) async {
    final db = await database;
    return await db.update(
      'clothing_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteClothingItem(int id) async {
    final db = await database;
    return await db.delete(
      'clothing_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Outfits CRUD operations
  Future<int> insertOutfit(Outfit outfit) async {
    final db = await database;
    return await db.insert('outfits', outfit.toMap());
  }

  Future<List<Outfit>> getAllOutfits() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('outfits');
    final allItems = await getAllClothingItems();
    
    return List.generate(maps.length, (i) {
      return Outfit.fromMap(maps[i], allItems);
    });
  }

  Future<int> updateOutfit(Outfit outfit) async {
    final db = await database;
    return await db.update(
      'outfits',
      outfit.toMap(),
      where: 'id = ?',
      whereArgs: [outfit.id],
    );
  }

  Future<int> deleteOutfit(int id) async {
    final db = await database;
    return await db.delete(
      'outfits',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Search functionality
  Future<List<ClothingItem>> searchClothingItems(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'clothing_items',
      where: 'name LIKE ? OR tags LIKE ? OR color LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
    );
    
    return List.generate(maps.length, (i) {
      return ClothingItem.fromMap(maps[i]);
    });
  }
}
