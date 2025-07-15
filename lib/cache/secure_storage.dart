import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  // Create a new instance of the secure storage
  static const storage = FlutterSecureStorage();

  // Save a value to the secure storage
  static Future<void> saveSecureStorage({
    required String key,
    required String value,
  }) async {
    await storage.write(key: key, value: value);
  }

  // Read the stored value
  static Future<String?> readSecureStorage({
    required String key,
  }) async {
    return await storage.read(key: key);
  }

  // Delete a value from the secure storage
  static Future<void> deleteSecureStorage({
    required String key,
  }) async {
    await storage.delete(key: key);
  }

  // Delete all values from the secure storage
  static Future<void> deleteAllSecureStorage() async {
    await storage.deleteAll();
  }
}
