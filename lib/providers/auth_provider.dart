import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart' as app_models;

class AuthProvider extends ChangeNotifier {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  firebase_auth.User? _firebaseUser;
  app_models.User? _user;
  bool _isLoading = false;
  String? _error;

  firebase_auth.User? get firebaseUser => _firebaseUser;
  app_models.User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _firebaseUser != null;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    // Check if user is already logged in
    _firebaseUser = _auth.currentUser;

    if (_firebaseUser != null) {
      _user = app_models.User(
        id: _firebaseUser!.uid,
        email: _firebaseUser!.email ?? '',
        name: _firebaseUser!.displayName ?? '',
        photoUrl: _firebaseUser!.photoURL,
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _firebaseUser = result.user;

      if (_firebaseUser != null) {
        _user = app_models.User(
          id: _firebaseUser!.uid,
          email: _firebaseUser!.email ?? '',
          name: _firebaseUser!.displayName ?? '',
          photoUrl: _firebaseUser!.photoURL,
        );

        // Store login status locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _firebaseUser = result.user;

      if (_firebaseUser != null) {
        // Update user profile
        await _firebaseUser!.updateDisplayName(name);
        
        _user = app_models.User(
          id: _firebaseUser!.uid,
          email: _firebaseUser!.email ?? '',
          name: name,
          photoUrl: _firebaseUser!.photoURL,
        );

        // Store login status locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    await _auth.signOut();
    _firebaseUser = null;
    _user = null;

    // Clear login status locally
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _auth.sendPasswordResetEmail(email: email);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
} 