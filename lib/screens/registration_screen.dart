import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar з автоматичною кнопкою "Назад"
      appBar: AppBar(
        title: const Text('Реєстрація'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
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
                    const Icon(Icons.person_add_alt_1, size: 80, color: Colors.blueAccent),
                    const SizedBox(height: 24),
                    const CustomTextField(
                      hintText: 'Ім\'я користувача',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
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
                    PrimaryButton(
                      text: 'Створити акаунт',
                      onPressed: () {
                        // Пізніше тут буде перехід на MainScreen
                      },
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        // Повернення на попередній екран (LoginScreen)
                        Navigator.pop(context);
                      },
                      child: const Text('Вже є акаунт? Увійти'),
                    )
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