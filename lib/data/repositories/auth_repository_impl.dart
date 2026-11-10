import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/iauth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
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
    return true;
  }

  @override
  Future<bool> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final normalizedEmail = email.trim().toLowerCase();
    final savedPassword = prefs.getString('user_$normalizedEmail');

    if (savedPassword != null && savedPassword == password) {
      await prefs.setString('current_user', normalizedEmail);
      return true;
    }
    return false;
  }

  @override
  Future<String?> getCurrentUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('current_user');
  }

  @override
  Future<String?> getCurrentUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('current_user');
    if (email == null) return null;
    return prefs.getString('name_$email');
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
  }
}