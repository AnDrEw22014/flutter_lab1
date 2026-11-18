abstract class IAuthRepository {
  Future<bool> register(String email, String password, String name);
  Future<bool> login(String email, String password);
  Future<String?> getCurrentUserEmail();
  Future<String?> getCurrentUserName();
  Future<void> logout();
}