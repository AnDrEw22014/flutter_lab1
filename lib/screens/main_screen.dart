import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/services/mqtt_service.dart';
import '../data/services/network_service.dart';
import '../widgets/mqtt_telemetry_card.dart';
import '../widgets/remote_devices_section.dart';
import 'login_screen.dart';
import 'user_profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _authRepo = AuthRepositoryImpl();
  String _userName = 'Користувач';

  @override
  void initState() {
    super.initState();
    _loadProfile();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MqttService>().connectAndListen();
      }
    });
  }

  Future<void> _loadProfile() async {
    final name = await _authRepo.getCurrentUserName();
    if (!mounted) return;
    setState(() => _userName = name ?? 'Користувач');
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Підтвердження виходу'),
        content: const Text('Ви дійсно бажаєте вийти з облікового запису?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Скасувати', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(dialogContext);
              context.read<MqttService>().disconnect();
              await _authRepo.logout();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Вийти', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = context.watch<NetworkService>().isConnected;

    return Scaffold(
      appBar: AppBar(
        title: Text('Вітаємо, $_userName!'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, size: 26),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UserProfileScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            onPressed: _confirmLogout,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          if (!isConnected)
            Container(
              width: double.infinity,
              color: Colors.redAccent,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: const Text(
                'Немає з\'єднання з мережею. Дані завантажено з кешу.',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
          const MqttTelemetryCard(),
          const RemoteDevicesSection(),
        ],
      ),
    );
  }
}