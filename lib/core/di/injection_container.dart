import 'package:get_it/get_it.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/remote_device_repository.dart';
import '../../data/services/mqtt_service.dart';
import '../../data/services/network_service.dart';
import '../../data/services/secure_storage_service.dart';
import '../../domain/repositories/iauth_repository.dart';
import '../../domain/repositories/idevice_repository.dart';

final sl = GetIt.instance;

void setupDependencies() {
  // Services (Singletons)
  sl.registerLazySingleton<SecureStorageService>(() => SecureStorageService());
  sl.registerLazySingleton<NetworkService>(() => NetworkService());
  sl.registerLazySingleton<MqttService>(() => MqttService());

  // Repositories (Singletons)
  sl.registerLazySingleton<IAuthRepository>(() => AuthRepositoryImpl());
  sl.registerLazySingleton<IDeviceRepository>(() => RemoteDeviceRepository());
}