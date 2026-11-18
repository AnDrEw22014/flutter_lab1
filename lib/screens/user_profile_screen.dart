import 'package:flutter/material.dart';
import '../data/repositories/auth_repository_impl.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _authRepo = AuthRepositoryImpl();
  String _email = '';
  String _name = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final email = await _authRepo.getCurrentUserEmail();
    final name = await _authRepo.getCurrentUserName();

    setState(() {
      _email = email ?? 'Невідомо';
      _name = name ?? 'Користувач';
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профіль користувача')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        child: Icon(Icons.person, size: 40),
                      ),
                      const SizedBox(height: 20),
                      ListTile(
                        leading: const Icon(Icons.badge),
                        title: const Text("Ім'я"),
                        subtitle: Text(
                          _name,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.email),
                        title: const Text('Email'),
                        subtitle: Text(
                          _email,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}