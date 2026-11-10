import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/auth_repository_impl.dart';
import 'login_screen.dart';
import 'user_profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _authRepo = AuthRepositoryImpl();
  List<String> _items = [];
  bool _isLoading = true;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = await _authRepo.getCurrentUserName();
    final savedItemsJson = prefs.getString('crud_items');

    setState(() {
      _userName = name ?? 'Користувач';
      if (savedItemsJson != null) {
        _items = List<String>.from(jsonDecode(savedItemsJson));
      } else {
        _items = ['Фокус-сесія #1 (30 хв)', 'Режим читання (20 хв)'];
      }
      _isLoading = false;
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('crud_items', jsonEncode(_items));
  }

  void _addItem(String title) {
    if (title.trim().isEmpty) return;
    setState(() => _items.add(title.trim()));
    _saveData();
  }

  void _editItem(int index, String newTitle) {
    if (newTitle.trim().isEmpty) return;
    setState(() => _items[index] = newTitle.trim());
    _saveData();
  }

  void _deleteItem(int index) {
    setState(() => _items.removeAt(index));
    _saveData();
  }

  void _showItemDialog({int? index}) {
    final isEditing = index != null;
    final controller = TextEditingController(text: isEditing ? _items[index] : '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isEditing ? 'Редагувати режим' : 'Новий режим'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Назва сесії / освітлення',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Скасувати', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              if (isEditing) {
                _editItem(index, controller.text);
              } else {
                _addItem(controller.text);
              }
              Navigator.pop(context);
            },
            child: Text(isEditing ? 'Зберегти' : 'Додати', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _logout() async {
    await _authRepo.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Вітаємо, $_userName!'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, size: 26),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 24),
            onPressed: _logout,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(
                  child: Text(
                    'Список порожній.\nНатисніть + щоб додати режим!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E293B), Color(0xFF334155)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(50),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withAlpha(40),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.lightbulb_outline, color: Color(0xFF818CF8)),
                        ),
                        title: Text(
                          _items[index],
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, color: Color(0xFF38BDF8)),
                              onPressed: () => _showItemDialog(index: index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Color(0xFFF87171)),
                              onPressed: () => _deleteItem(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF6366F1),
        onPressed: () => _showItemDialog(),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Додати', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}