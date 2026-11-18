import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/iauth_repository.dart';
import '../services/secure_storage_service.dart';

class AuthRepositoryImpl implements IAuthRepository {
  // Підключаємо сервіс безпечного сховища
  final SecureStorageService _secureStorage = SecureStorageService();

  @override
  Future<bool> register(String email, String password, String name) async {
    final prefs = await SharedPreferences.getInstance();
    final normalizedEmail = email.trim().toLowerCase();

    if (prefs.containsKey('user_$normalizedEmail')) {
      return false; // Користувач вже існує
    }

    await prefs.setString('user_$normalizedEmail', password);
    await prefs.setString('name_$normalizedEmail', name);
    await prefs.setString('current_user', normalizedEmail);
    
    // 1. Зберігаємо сесію в SecureStorage при реєстрації
    await _secureStorage.saveSession(normalizedEmail);
    
    return true;
  }

  @override
  Future<bool> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final normalizedEmail = email.trim().toLowerCase();
    final savedPassword = prefs.getString('user_$normalizedEmail');

    if (savedPassword != null && savedPassword == password) {
      await prefs.setString('current_user', normalizedEmail);
      
      // 2. Зберігаємо сесію в SecureStorage при успішному вході
      await _secureStorage.saveSession(normalizedEmail);
      
      return true;
    }
    return false;
  }

  @override
  Future<String?> getCurrentUserEmail() async {
    // 3. Читаємо поточну сесію із зашифрованого сховища
    return await _secureStorage.getSession();
  }

  @override
  Future<String?> getCurrentUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final email = await getCurrentUserEmail();
    if (email == null) return null;
    return prefs.getString('name_$email');
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
    
    // 4. Обов'язково видаляємо сесію із SecureStorage при виході
    await _secureStorage.clearSession();
  }
}