import 'data/repositories/remote_device_repository.dart';
import 'domain/repositories/idevice_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/services/mqtt_service.dart';
import 'data/services/network_service.dart';
import 'data/services/secure_storage_service.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider робить NetworkService та MqttService доступними на всіх екранах
    // і автоматично викликає їх метод dispose() при закритті застосунку
    return MultiProvider(
      providers: [
  ChangeNotifierProvider(create: (_) => NetworkService()),
  ChangeNotifierProvider(create: (_) => MqttService()),
  Provider<IDeviceRepository>(create: (_) => RemoteDeviceRepository()),
],
      child: MaterialApp(
        title: 'IoT Smart App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(useMaterial3: true), // Ваша темна тема Material 3
        home: const AuthCheckScreen(),
      ),
    );
  }
}

/// Екран-розподільник, який перевіряє наявність сесії при старті (Auto-login)
class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  final SecureStorageService _storageService = SecureStorageService();

  @override
  void initState() {
    super.initState();
    _checkSessionAndNavigate();
  }

  Future<void> _checkSessionAndNavigate() async {
    // Читаємо збережений токен/email із зашифрованого сховища
    final session = await _storageService.getSession();

    if (!mounted) return;

    if (session != null && session.isNotEmpty) {
      // Сесія існує -> перекидаємо на Головний екран (навіть якщо немає інтернету!)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else {
      // Сесії немає -> відкриваємо Екран логіну
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Поки йде перевірка (кілька мілісекунд), показуємо індикатор завантаження
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}