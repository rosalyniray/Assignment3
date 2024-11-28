import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'food_order.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE FoodItems (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            cost REAL NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE Orders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            items TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> insertSampleData() async {
    final db = await database;

    final existingData = await db.query('FoodItems');
    if (existingData.isNotEmpty) return;

await db.insert('FoodItems', {'name': 'Pizza', 'cost': 12.0});
await db.insert('FoodItems', {'name': 'Burger', 'cost': 8.0});
await db.insert('FoodItems', {'name': 'Pasta', 'cost': 10.0});
await db.insert('FoodItems', {'name': 'Sushi', 'cost': 15.0});
await db.insert('FoodItems', {'name': 'Salad', 'cost': 6.0});
await db.insert('FoodItems', {'name': 'Steak', 'cost': 20.0});
await db.insert('FoodItems', {'name': 'Sandwich', 'cost': 7.0});
await db.insert('FoodItems', {'name': 'Taco', 'cost': 5.0});
await db.insert('FoodItems', {'name': 'Fried Chicken', 'cost': 9.0});
await db.insert('FoodItems', {'name': 'Ice Cream', 'cost': 4.0});
await db.insert('FoodItems', {'name': 'Fries', 'cost': 3.0});
await db.insert('FoodItems', {'name': 'Waffles', 'cost': 8.0});
await db.insert('FoodItems', {'name': 'Pancakes', 'cost': 7.0});
await db.insert('FoodItems', {'name': 'Hot Dog', 'cost': 6.0});
await db.insert('FoodItems', {'name': 'Soup', 'cost': 5.0});
await db.insert('FoodItems', {'name': 'Rice Bowl', 'cost': 9.0});
await db.insert('FoodItems', {'name': 'Grilled Cheese', 'cost': 6.0});
await db.insert('FoodItems', {'name': 'Smoothie', 'cost': 5.0});
await db.insert('FoodItems', {'name': 'Doughnut', 'cost': 3.0});
await db.insert('FoodItems', {'name': 'BBQ Ribs', 'cost': 18.0});
  }
}
