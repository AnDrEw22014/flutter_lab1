import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flashlight_plugin/my_flashlight_plugin.dart';
import '../logic/auth/auth_cubit.dart';
import '../logic/auth/auth_state.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  Future<void> _triggerSecretFlashlight(BuildContext context) async {
    try {
      final isOn = await MyFlashlightPlugin.toggle();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isOn ? '🔦 Easter Egg: Ліхтарик увімкнено!' : 'Ліхтарик вимкнено',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } on FlashlightUnsupportedException catch (e) {
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('Функція недоступна'),
          content: Text(e.message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Зрозуміло'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профіль користувача')),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final name = state is AuthAuthenticated ? state.name : 'Користувач';
          final email = state is AuthAuthenticated ? state.email : 'Невідомо';

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onLongPress: () => _triggerSecretFlashlight(context),
                      child: const CircleAvatar(
                        radius: 40,
                        child: Icon(Icons.person, size: 40),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ListTile(
                      leading: const Icon(Icons.badge),
                      title: const Text("Ім'я"),
                      subtitle: Text(name, style: const TextStyle(fontSize: 16)),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.email),
                      title: const Text('Email'),
                      subtitle: Text(email, style: const TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}