import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/services/mqtt_service.dart';
import '../data/services/network_service.dart';
import '../logic/auth/auth_cubit.dart';
import '../logic/auth/auth_state.dart';
import '../widgets/mqtt_telemetry_card.dart';
import '../widgets/remote_devices_section.dart';
import 'login_screen.dart';
import 'user_profile_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Підтвердження виходу'),
        content: const Text('Ви дійсно бажаєте вийти з облікового запису?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Скасувати'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<MqttService>().disconnect();
              context.read<AuthCubit>().logout();
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

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              final name = state is AuthAuthenticated ? state.name : 'Користувач';
              return Text('Вітаємо, $name!');
            },
          ),
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
              onPressed: () => _confirmLogout(context),
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
      ),
    );
  }
}