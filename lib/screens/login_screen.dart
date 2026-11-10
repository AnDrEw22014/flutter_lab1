import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import 'registration_screen.dart'; // Імпорт екрана реєстрації
import 'main_screen.dart';         // Імпорт головного екрана

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lightbulb_outline, size: 80, color: Colors.blueAccent),
                    const SizedBox(height: 16),
                    const Text(
                      'Smart Focus Lamp',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Керуй освітленням для кращої концентрації',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 40),
                    const CustomTextField(
                      hintText: 'Email',
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 16),
                    const CustomTextField(
                      hintText: 'Пароль',
                      icon: Icons.lock_outline,
                      isPassword: true,
                    ),
                    const SizedBox(height: 32),
                    
                    // --- ВИПРАВЛЕНІ КНОПКИ З НАВІГАЦІЄЮ ---
                    PrimaryButton(
                      text: 'Увійти',
                      onPressed: () {
                        // Перехід на головний екран (Dashboard)
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const MainScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        // Перехід на екран реєстрації
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegistrationScreen()),
                        );
                      },
                      child: const Text('Немає акаунту? Зареєструватися'),
                    ),
                    // --------------------------------------
                    
                  ],
                ),
              ),
            );
          }
        ),
      ),
    );
  }
}