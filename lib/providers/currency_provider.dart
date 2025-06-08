import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyProvider with ChangeNotifier {
  static const String _currencyKey = 'selected_currency';
  static const String _defaultCurrency = 'INR';

  late SharedPreferences _prefs;
  String _currency = _defaultCurrency;
  bool _isInitialized = false;

  String get currency => _currency;
  String get symbol => _getCurrencySymbol(_currency);

  CurrencyProvider() {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _currency = _prefs.getString(_currencyKey) ?? _defaultCurrency;
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Error initializing currency preferences: $e');
      _currency = _defaultCurrency;
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> setCurrency(String currency) async {
    if (!_isInitialized) return;

    _currency = currency;
    try {
      await _prefs.setString(_currencyKey, currency);
    } catch (e) {
      print('Error saving currency preference: $e');
    }
    notifyListeners();
  }

  String _getCurrencySymbol(String currency) {
    switch (currency) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'INR':
        return '₹';
      default:
        return currency;
    }
  }

  static final Map<String, String> supportedCurrencies = {
    'USD': 'US Dollar',
    'EUR': 'Euro',
    'GBP': 'British Pound',
    'JPY': 'Japanese Yen',
    'INR': 'Indian Rupee',
  };
}
 