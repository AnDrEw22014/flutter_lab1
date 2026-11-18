import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _sessionKey = 'user_session_token';

  // Збереження сесії при логіні/реєстрації
  Future<void> saveSession(String userEmail) async {
    await _storage.write(key: _sessionKey, value: userEmail);
  }

  // Перевірка наявності збереженої сесії (для автологіну)
  Future<String?> getSession() async {
    return await _storage.read(key: _sessionKey);
  }

  // Видалення сесії при виході (Logout)
  Future<void> clearSession() async {
    await _storage.delete(key: _sessionKey);
  }
}