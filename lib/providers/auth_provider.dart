import 'package:flutter/material.dart';
import '../services/secure_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final SecureStorageService _secureStorage = SecureStorageService();
  bool _isAuthenticated = false;
  bool _isPinSet = false;
  bool _isInitialized = false;

  bool get isAuthenticated => _isAuthenticated;
  bool get isPinSet => _isPinSet;
  bool get isInitialized => _isInitialized;

  AuthProvider() {
    checkPinStatus();
  }

  Future<void> checkPinStatus() async {
    try {
      _isPinSet = await _secureStorage.hasPinSet();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error checking PIN status: $e');
      _isPinSet = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> setPin(String pin) async {
    if (pin.length != 4) {
      throw Exception('PIN must be 4 digits');
    }

    if (!RegExp(r'^\d{4}$').hasMatch(pin)) {
      throw Exception('PIN must contain only digits');
    }

    try {
      await _secureStorage.setPin(pin);
      _isPinSet = true;
      _isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting PIN: $e');
      rethrow;
    }
  }

  Future<bool> verifyPin(String pin) async {
    if (pin.length != 4) {
      throw Exception('PIN must be 4 digits');
    }

    if (!RegExp(r'^\d{4}$').hasMatch(pin)) {
      throw Exception('PIN must contain only digits');
    }

    try {
      final isValid = await _secureStorage.verifyPin(pin);
      if (isValid) {
        _isAuthenticated = true;
        notifyListeners();
      }
      return isValid;
    } catch (e) {
      debugPrint('Error verifying PIN: $e');
      return false;
    }
  }

  Future<void> resetPin() async {
    try {
      await _secureStorage.clearPin();
      _isPinSet = false;
      _isAuthenticated = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error resetting PIN: $e');
      rethrow;
    }
  }

  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }
}