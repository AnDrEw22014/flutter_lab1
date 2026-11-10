import 'package:flutter/material.dart';
import '../data/repositories/auth_repository_impl.dart';
import 'main_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authRepo = AuthRepositoryImpl();

  String _name = '';
  String _email = '';
  String _password = '';
  bool _isLoading = false;

  void _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    final success = await _authRepo.register(_email, _password, _name);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Реєстрація успішна!')),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Користувач із таким email вже існує!'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Реєстрація')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Ім'я",
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return "Введіть ім'я";
                  if (RegExp(r'\d').hasMatch(val)) {
                    return "Ім'я не повинно містити цифр";
                  }
                  return null;
                },
                onSaved: (val) => _name = val?.trim() ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Введіть email';
                  if (!val.contains('@') || !val.contains('.')) {
                    return 'Email повинен містити @ та домен';
                  }
                  return null;
                },
                onSaved: (val) => _email = val?.trim() ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Пароль (мін. 8 символів)',
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.length < 8) {
                    return 'Пароль має містити мінімум 8 символів';
                  }
                  return null;
                },
                onSaved: (val) => _password = val ?? '',
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _submitRegistration,
                      child: const Text('Зареєструватися'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}