import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/network_service.dart';
import '../../domain/repositories/iauth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final IAuthRepository _authRepo;
  final NetworkService _networkService;

  AuthCubit(this._authRepo, this._networkService) : super(const AuthInitial());

  Future<void> loadProfile() async {
    emit(const AuthLoading());
    final name = await _authRepo.getCurrentUserName() ?? 'Користувач';
    final email = await _authRepo.getCurrentUserEmail() ?? 'Невідомо';
    emit(AuthAuthenticated(name: name, email: email));
  }

  Future<void> login(String email, String password) async {
    final hasInternet = await _networkService.checkInternetNow();
    if (!hasInternet) {
      emit(const AuthFailure('Відсутнє інтернет-з\'єднання. Вхід заблоковано!'));
      return;
    }
    emit(const AuthLoading());
    final success = await _authRepo.login(email, password);
    if (success) {
      await loadProfile();
    } else {
      emit(const AuthFailure('Невірний email або пароль! Спочатку зареєструйтесь.'));
    }
  }

  Future<void> register(String email, String password, String name) async {
    emit(const AuthLoading());
    final success = await _authRepo.register(email, password, name);
    if (success) {
      await loadProfile();
    } else {
      emit(const AuthFailure('Помилка реєстрації користувача.'));
    }
  }

  Future<void> logout() async {
    await _authRepo.logout();
    emit(const AuthUnauthenticated());
  }
}