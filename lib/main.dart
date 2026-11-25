import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'core/di/injection_container.dart';
import 'data/services/mqtt_service.dart';
import 'data/services/network_service.dart';
import 'data/services/secure_storage_service.dart';
import 'domain/repositories/iauth_repository.dart';
import 'domain/repositories/idevice_repository.dart';
import 'logic/auth/auth_cubit.dart';
import 'logic/devices/devices_bloc.dart';
import 'logic/devices/devices_event.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sl<NetworkService>()),
        ChangeNotifierProvider.value(value: sl<MqttService>()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => AuthCubit(sl<IAuthRepository>(), sl<NetworkService>())
              ..loadProfile(),
          ),
          BlocProvider(
            create: (_) => DevicesBloc(sl<IDeviceRepository>())
              ..add(const LoadDevicesEvent()),
          ),
        ],
        child: MaterialApp(
          title: 'IoT Smart App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark(useMaterial3: true),
          home: const AuthCheckScreen(),
        ),
      ),
    );
  }
}

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final session = await sl<SecureStorageService>().getSession();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => (session != null && session.isNotEmpty)
            ? const MainScreen()
            : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}