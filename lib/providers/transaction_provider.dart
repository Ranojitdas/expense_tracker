import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../services/database_helper.dart';

class TransactionProvider with ChangeNotifier {
  List<Transaction> _transactions = [];
  double _balance = 0.0;

  List<Transaction> get transactions => _transactions;
  double get balance => _balance;

  Future<void> loadTransactions() async {
    _transactions = (await DatabaseHelper.instance.getAllTransactions())
        .cast<Transaction>();
    _balance = await DatabaseHelper.instance.getTotalBalance();
    notifyListeners();
  }

  Future<void> addTransaction(Transaction transaction) async {
    await DatabaseHelper.instance.insertTransaction(transaction);
    await loadTransactions();
  }

  Future<void> deleteTransaction(int id) async {
    await DatabaseHelper.instance.deleteTransaction(id);
    await loadTransactions();
  }
}
