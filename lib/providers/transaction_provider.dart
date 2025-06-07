import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../services/database_helper.dart';
import '../services/auth_service.dart';

class TransactionProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final AuthService _authService;
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  bool _hasWelcomeTransaction = false;

  TransactionProvider(this._authService) {
    _authService.authStateChanges.listen((user) async {
      if (user != null) {
        await loadTransactions();
        // Only add welcome transaction if we haven't added it before
        if (!_hasWelcomeTransaction) {
          await addWelcomeTransaction();
          _hasWelcomeTransaction = true;
        }
      } else {
        _transactions = [];
        _hasWelcomeTransaction = false;
        notifyListeners();
      }
    });
  }

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  Future<void> loadTransactions() async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) return;

      final db = await DatabaseHelper.instance.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'transactions',
        where: 'userId = ?',
        whereArgs: [userId],
        orderBy: 'date DESC',
      );

      _transactions = maps.map((map) => Transaction.fromMap(map)).toList();

      // Remove the welcome transaction check from here since it's handled in the auth listener
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading transactions: $e');
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    try {
      await _db.insertTransaction(transaction);
      _transactions.add(transaction);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding transaction: $e');
      rethrow;
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) return;

      await _db.deleteTransaction(id, userId);
      _transactions.removeWhere((t) => t.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
      rethrow;
    }
  }

  Future<double> getTotalBalance() async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) return 0.0;
      return await _db.getTotalBalance(userId);
    } catch (e) {
      debugPrint('Error getting total balance: $e');
      return 0.0;
    }
  }

  // Add a method to check if user has any transactions
  Future<bool> hasTransactions() async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) return false;

      final db = await DatabaseHelper.instance.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'transactions',
        where: 'userId = ?',
        whereArgs: [userId],
      );

      return maps.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking transactions: $e');
      return false;
    }
  }

  // Add a method to check if welcome transaction exists
  Future<bool> hasWelcomeTransaction() async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) return false;

      final db = await DatabaseHelper.instance.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'transactions',
        where: 'userId = ? AND title = ?',
        whereArgs: [userId, 'Welcome to TrackMySpend! 👋'],
      );

      return maps.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking welcome transaction: $e');
      return false;
    }
  }

  // Add a method to add welcome transaction
  Future<void> addWelcomeTransaction() async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) return;

      // Check if welcome transaction already exists
      final hasWelcome = await hasWelcomeTransaction();
      if (hasWelcome) {
        _hasWelcomeTransaction = true;
        return;
      }

      // Check if user has any other transactions
      final hasExistingTransactions = await hasTransactions();
      if (hasExistingTransactions) return;

      final welcomeTransaction = Transaction(
        id: const Uuid().v4(),
        userId: userId,
        title: 'Welcome to TrackMySpend! 👋',
        amount: 0,
        date: DateTime.now(),
        category: 'Income',
        description:
            'Start tracking your expenses by adding your first transaction.',
        isExpense: false,
      );

      await addTransaction(welcomeTransaction);
      _hasWelcomeTransaction = true;
    } catch (e) {
      debugPrint('Error adding welcome transaction: $e');
    }
  }
}
