import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  final _storage = const FlutterSecureStorage();
  static const _pinKey = 'user_pin';

  factory SecureStorageService() => _instance;

  SecureStorageService._internal();

  Future<void> setPin(String pin) async {
    final hashedPin = _hashPin(pin);
    await _storage.write(key: _pinKey, value: hashedPin);
  }

  Future<bool> verifyPin(String pin) async {
    final storedHashedPin = await _storage.read(key: _pinKey);
    if (storedHashedPin == null) return false;
    
    final hashedInputPin = _hashPin(pin);
    return hashedInputPin == storedHashedPin;
  }

  Future<bool> hasPinSet() async {
    final pin = await _storage.read(key: _pinKey);
    return pin != null;
  }

  Future<void> clearPin() async {
    await _storage.delete(key: _pinKey);
  }

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}