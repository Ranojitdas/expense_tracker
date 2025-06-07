import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _error;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthProvider() {
    _authService.authStateChanges.listen((user) {
      _isLoggedIn = user != null;
      if (user != null) {
        _error = null;
      }
      notifyListeners();
    });
  }

  Future<void> loginWithEmailAndPassword(String email, String password) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('AuthProvider: Starting email login...');
      final userCredential =
          await _authService.signInWithEmailAndPassword(email, password);

      if (userCredential != null) {
        print('AuthProvider: Login successful');
        _isLoggedIn = true;
        _error = null;
      } else {
        print('AuthProvider: Login returned null');
        _error = 'Failed to sign in. Please check your credentials.';
      }
    } catch (e) {
      print('AuthProvider: Error during login: $e');
      if (e.toString().contains('user-not-found')) {
        _error = 'No account found with this email. Please sign up first.';
      } else if (e.toString().contains('wrong-password')) {
        _error = 'Incorrect password. Please try again.';
      } else if (e.toString().contains('invalid-email')) {
        _error = 'Please enter a valid email address.';
      } else {
        _error = 'An error occurred during login. Please try again.';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('AuthProvider: Starting Google Sign-In...');
      final userCredential = await _authService.signInWithGoogle();

      if (userCredential != null) {
        print('AuthProvider: Sign-in successful');
        _isLoggedIn = true;
        _error = null;
      } else {
        print('AuthProvider: Sign-in returned null');
        _error = 'Failed to sign in with Google. Please try again.';
      }
    } catch (e) {
      print('AuthProvider: Error during login: $e');
      if (e.toString().contains('sign_in_failed')) {
        _error =
            'Google Sign-In failed. Please check your internet connection and try again.';
      } else if (e.toString().contains('network_error')) {
        _error = 'Network error. Please check your internet connection.';
      } else {
        _error = 'An error occurred during sign-in. Please try again.';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signOut();
      _isLoggedIn = false;
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('Error during logout: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signupWithEmailAndPassword(
      String email, String password, String displayName) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('AuthProvider: Starting email signup...');
      final userCredential = await _authService.signUpWithEmailAndPassword(
          email, password, displayName);

      if (userCredential != null) {
        print('AuthProvider: Signup successful');
        _isLoggedIn = true;
        _error = null;
      } else {
        print('AuthProvider: Signup returned null');
        _error = 'Failed to create account. Please try again.';
      }
    } catch (e) {
      print('AuthProvider: Error during signup: $e');
      if (e.toString().contains('email-already-in-use')) {
        _error = 'This email is already registered. Please login instead.';
      } else if (e.toString().contains('weak-password')) {
        _error = 'Password is too weak. Please use a stronger password.';
      } else if (e.toString().contains('invalid-email')) {
        _error = 'Please enter a valid email address.';
      } else {
        _error = 'An error occurred during signup. Please try again.';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
