import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/storage_keys.dart';

class StorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static Future<void> saveToken(String token) async {
    await _storage.write(key: StorageKeys.jwtToken, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: StorageKeys.jwtToken);
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: StorageKeys.jwtToken);
  }

  static Future<void> saveUserEmail(String email) async {
    await _storage.write(key: StorageKeys.userEmail, value: email);
  }

  static Future<String?> getUserEmail() async {
    return await _storage.read(key: StorageKeys.userEmail);
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
