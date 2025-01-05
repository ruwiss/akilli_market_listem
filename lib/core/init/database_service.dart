import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../../product/models/shopping_item.dart';
import '../../product/models/archived_list.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'shopping_list.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE shopping_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        unit_price REAL DEFAULT 0,
        quantity REAL NOT NULL,
        unit TEXT,
        description TEXT,
        image_url TEXT,
        market_image_url TEXT,
        is_completed INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE archived_lists(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        total_amount REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE archived_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        list_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        unit_price REAL DEFAULT 0,
        quantity REAL NOT NULL,
        unit TEXT,
        description TEXT,
        is_completed INTEGER DEFAULT 0,
        FOREIGN KEY (list_id) REFERENCES archived_lists (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      try {
        await db.execute(
            'ALTER TABLE shopping_items ADD COLUMN unit_price REAL DEFAULT 0');
        await db.execute(
            'ALTER TABLE archived_items ADD COLUMN unit_price REAL DEFAULT 0');

        await db.execute('DROP TABLE IF EXISTS archived_lists');
        await db.execute('DROP TABLE IF EXISTS archived_items');

        await db.execute('''
          CREATE TABLE archived_lists(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            total_amount REAL NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE archived_items(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            list_id INTEGER NOT NULL,
            name TEXT NOT NULL,
            price REAL NOT NULL,
            unit_price REAL DEFAULT 0,
            quantity REAL NOT NULL,
            unit TEXT,
            description TEXT,
            is_completed INTEGER DEFAULT 0,
            FOREIGN KEY (list_id) REFERENCES archived_lists (id) ON DELETE CASCADE
          )
        ''');
      } catch (e) {
        debugPrint('Veritabanı güncelleme hatası: $e');
      }
    }
  }

  // Aktif liste işlemleri
  Future<List<ShoppingItem>> getItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('shopping_items');
    return List.generate(maps.length, (i) => ShoppingItem.fromMap(maps[i]));
  }

  Future<int> insertItem(ShoppingItem item) async {
    final db = await database;
    return await db.insert('shopping_items', item.toMap());
  }

  Future<int> updateItem(ShoppingItem item) async {
    final db = await database;
    return await db.update(
      'shopping_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteItem(int id) async {
    final db = await database;
    return await db.delete(
      'shopping_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Arşiv işlemleri
  Future<int> archiveCurrentList(
      ArchivedList list, List<ArchivedItem> items) async {
    final db = await database;
    int listId = 0;

    await db.transaction((txn) async {
      // Listeyi arşivle
      listId = await txn.insert('archived_lists', {
        'date': list.date,
        'total_amount': list.totalAmount,
      });

      // Ürünleri arşivle
      for (var item in items) {
        await txn.insert('archived_items', {
          'list_id': listId,
          'name': item.name,
          'price': item.price,
          'quantity': item.quantity,
          'unit': item.unit,
          'description': item.description,
          'is_completed': item.isCompleted ? 1 : 0,
        });
      }

      // Aktif listeyi temizle
      await txn.delete('shopping_items');
    });

    return listId;
  }

  Future<List<ArchivedList>> getArchivedLists() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'archived_lists',
      orderBy: 'date DESC',
    );

    List<ArchivedList> lists = [];
    for (var map in maps) {
      // Her liste için ürünleri yükle
      final items = await getArchivedItems(map['id']);
      // ArchivedItem'ları Map'e dönüştür
      final itemMaps = items
          .map((item) => {
                'name': item.name,
                'price': item.price,
                'quantity': item.quantity,
                'unit': item.unit,
                'description': item.description,
                'isCompleted': item.isCompleted,
              })
          .toList();

      lists.add(ArchivedList(
        id: map['id'],
        date: map['date'],
        totalAmount: map['total_amount'],
        items: itemMaps,
      ));
    }
    return lists;
  }

  Future<List<ArchivedItem>> getArchivedItems(int listId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'archived_items',
      where: 'list_id = ?',
      whereArgs: [listId],
    );
    return List.generate(maps.length, (i) => ArchivedItem.fromMap(maps[i]));
  }

  Future<void> deleteArchivedList(int id) async {
    final db = await database;
    await db.transaction((txn) async {
      // Önce listeye ait ürünleri sil
      await txn.delete(
        'archived_items',
        where: 'list_id = ?',
        whereArgs: [id],
      );

      // Sonra listeyi sil
      await txn.delete(
        'archived_lists',
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }
}
