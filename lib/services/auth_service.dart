import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'image_storage_service.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final ImageStorageService _imageStorage = ImageStorageService();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      print('Signing in with email: $email');
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('Successfully signed in with email: ${userCredential.user?.email}');
      return userCredential;
    } catch (e) {
      print('Error signing in with email: $e');
      rethrow;
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      print('=== Starting Google Sign-In Process ===');

      // First, try to get the current user
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        print('User already signed in: ${currentUser.email}');
        return null; // Return null to trigger a new sign-in
      }

      print('Calling Google Sign-In...');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('Google Sign-In was cancelled by user');
        return null;
      }

      print('Successfully got Google user: ${googleUser.email}');
      print('Getting Google auth details...');

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      print('Got Google auth details:');
      print(
          '- Access Token: ${googleAuth.accessToken != null ? "Present" : "Missing"}');
      print(
          '- ID Token: ${googleAuth.idToken != null ? "Present" : "Missing"}');

      if (googleAuth.idToken == null) {
        print('Error: ID Token is missing');
        throw Exception('Failed to get ID token from Google Sign-In');
      }

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('Signing in to Firebase with Google credential...');
      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user == null) {
        print('Firebase sign-in failed: No user returned');
        return null;
      }

      print('Successfully signed in to Firebase:');
      print('- User ID: ${userCredential.user?.uid}');
      print('- Email: ${userCredential.user?.email}');
      print('- Display Name: ${userCredential.user?.displayName}');
      print('=== Google Sign-In Process Completed ===');

      return userCredential;
    } catch (e) {
      print('=== Google Sign-In Error ===');
      print('Error type: ${e.runtimeType}');
      print('Error message: $e');
      print('Stack trace: ${StackTrace.current}');
      print('===========================');

      // Sign out from Google if there's an error
      await _googleSignIn.signOut();

      // Provide more specific error messages
      if (e.toString().contains('sign_in_failed')) {
        throw Exception(
            'Google Sign-In failed. Please check your internet connection and try again.');
      } else if (e.toString().contains('network_error')) {
        throw Exception(
            'Network error. Please check your internet connection.');
      } else if (e.toString().contains('ApiException: 10')) {
        throw Exception(
            'Google Sign-In configuration error. Please contact support.');
      } else {
        throw Exception(
            'An error occurred during Google Sign-In. Please try again.');
      }
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmailAndPassword(
      String email, String password, String displayName) async {
    try {
      print('Signing up with email: $email');
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update the user's display name
      await userCredential.user?.updateDisplayName(displayName);

      print('Successfully signed up with email: ${userCredential.user?.email}');
      print('Display name set to: $displayName');
      return userCredential;
    } catch (e) {
      print('Error signing up with email: $e');
      rethrow;
    }
  }

  Future<void> updateDisplayName(String displayName) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        print('Display name updated successfully');
      }
    } catch (e) {
      print('Error updating display name: $e');
      rethrow;
    }
  }

  Future<void> updateProfileImage() async {
    try {
      final String? imagePath = await _imageStorage.pickAndSaveProfileImage();
      if (imagePath != null) {
        notifyListeners();
      }
    } catch (e) {
      print('Error updating profile image: $e');
      rethrow;
    }
  }

  Future<String?> getProfileImagePath() async {
    return await _imageStorage.getProfileImagePath();
  }

  Future<void> deleteAccount() async {
    try {
      await _imageStorage.deleteProfileImage();
      await _auth.currentUser?.delete();
      notifyListeners();
    } catch (e) {
      print('Error deleting account: $e');
      rethrow;
    }
  }
}
