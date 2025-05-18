import 'package:flutter/material.dart';
import '../services/secure_storage_service.dart';

class AuthProvider with ChangeNotifier {
  final SecureStorageService secureStorageService;
  bool _isAuthenticated = false;

  AuthProvider(this.secureStorageService);

  bool get isAuthenticated => _isAuthenticated;

  Future<void> setPin(String pin) async {
    await secureStorageService.writePin(pin);
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> authenticate(String pin) async {
    final storedPin = await secureStorageService.readPin();
    if (storedPin == pin) {
      _isAuthenticated = true;
      notifyListeners();
    } else {
      _isAuthenticated = false;
      notifyListeners();
    }
  }

  Future<void> reset() async {
    await secureStorageService.resetPin();
    _isAuthenticated = false;
    notifyListeners();
  }
}