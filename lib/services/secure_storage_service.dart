import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _apiKeyKey = 'user_api_key'; // Renamed for clarity
  static const String _userEmailKey =
      'user_email'; // New constant for email key
  static const String _userNameKey = 'user_name';
  static const String _userId = 'user_id';

  /// Saves the API key securely.
  static Future<void> saveApiKey(String key) async {
    await _storage.write(key: _apiKeyKey, value: key);
  }

  /// Retrieves the API key securely.
  static Future<String?> getApiKey() async {
    String? key = await _storage.read(key: _apiKeyKey);
    return key;
  }

  /// Deletes the API key from secure storage.
  static Future<void> deleteApiKey() async {
    await _storage.delete(key: _userId);
  }

  /// Saves the API key securely.
  static Future<void> saveUserId(String key) async {
    await _storage.write(key: _userId, value: key);
  }

  /// Retrieves the API key securely.
  static Future<String?> getUserId() async {
    String? key = await _storage.read(key: _userId);
    return key;
  }

  /// Deletes the API key from secure storage.
  static Future<void> deleteUserId() async {
    await _storage.delete(key: _apiKeyKey);
  }
  // --- New Email Functions ---

  /// Saves the user's email securely.
  static Future<void> saveEmail(String email) async {
    await _storage.write(key: _userEmailKey, value: email);
  }

  /// Retrieves the user's email securely.
  static Future<String?> getEmail() async {
    String? email = await _storage.read(key: _userEmailKey);
    return email;
  }

  /// Deletes the user's email from secure storage.
  static Future<void> deleteEmail() async {
    await _storage.delete(key: _userEmailKey);
  }
// --- New UserName Functions ---

  /// Saves the user's email securely.
  static Future<void> saveUserName(String userName) async {
    await _storage.write(key: _userNameKey, value: userName);
  }

  /// Retrieves the user's email securely.
  static Future<String?> getUserName() async {
    String? userName = await _storage.read(key: _userNameKey);
    return userName;
  }

  /// Deletes the user's email from secure storage.
  static Future<void> deleteUserName() async {
    await _storage.delete(key: _userNameKey);
  }

  // --- Convenience Function to Delete All Auth-related Data ---

  /// Deletes all authentication-related data (API key and email) from secure storage.
  static Future<void> deleteAllAuthData() async {
    await deleteApiKey();
    await deleteEmail();
    await deleteUserName();
    await deleteUserId();
  }
}
