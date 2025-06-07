import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart';
import '../models/transaction.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static sqflite.Database? _database;

  DatabaseHelper._init();

  Future<sqflite.Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('expenses.db');
    return _database!;
  }

  Future<sqflite.Database> _initDB(String filePath) async {
    final dbPath = await sqflite.getDatabasesPath();
    final path = join(dbPath, filePath);

    return await sqflite.openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(
      sqflite.Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      // Drop and recreate the table to ensure proper schema
      await db.execute('DROP TABLE IF EXISTS transactions');
      await _createDB(db, newVersion);
    }
  }

  Future<void> _createDB(sqflite.Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions(
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        isExpense INTEGER NOT NULL,
        category TEXT NOT NULL,
        description TEXT,
        dueDate TEXT
      )
    ''');
  }

  Future<int> insertTransaction(Transaction transaction) async {
    final db = await database;
    try {
      final map = transaction.toMap();
      // Ensure isExpense is an integer
      map['isExpense'] = transaction.isExpense ? 1 : 0;
      return await db.insert('transactions', map);
    } catch (e) {
      print('Error inserting transaction: $e');
      rethrow;
    }
  }

  Future<List<Transaction>> getAllTransactions(String userId) async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'transactions',
        where: 'userId = ?',
        whereArgs: [userId],
        orderBy: 'date DESC',
      );
      return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
    } catch (e) {
      print('Error getting transactions: $e');
      return [];
    }
  }

  Future<int> deleteTransaction(String id, String userId) async {
    final db = await database;
    try {
      return await db.delete(
        'transactions',
        where: 'id = ? AND userId = ?',
        whereArgs: [id, userId],
      );
    } catch (e) {
      print('Error deleting transaction: $e');
      rethrow;
    }
  }

  Future<double> getTotalBalance(String userId) async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> result = await db.rawQuery('''
        SELECT 
          COALESCE(SUM(CASE WHEN isExpense = 1 THEN -amount ELSE amount END), 0) as balance
        FROM transactions
        WHERE userId = ?
      ''', [userId]);
      return result.first['balance'] as double? ?? 0.0;
    } catch (e) {
      print('Error calculating balance: $e');
      return 0.0;
    }
  }
}
