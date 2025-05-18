import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = FlutterSecureStorage();

  Future<void> writePin(String pin) async {
    await _storage.write(key: 'userPin', value: pin);
  }

  Future<String?> readPin() async {
    return await _storage.read(key: 'userPin');
  }

  Future<void> resetPin() async {
    await _storage.delete(key: 'userPin');
  }
}