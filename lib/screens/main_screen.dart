import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/services/mqtt_service.dart';
import '../data/services/network_service.dart';
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
    // Запускаємо підключення до MQTT-брокера після побудови першого кадру
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MqttService>().connectAndListen();
      }
    });
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

  // Діалогове вікно підтвердження виходу (Confirmation Dialog)
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(dialogContext); // Закриваємо діалог
              context.read<MqttService>().disconnect(); // Відключаємо MQTT
              await _authRepo.logout(); // Видаляємо сесію із SecureStorage
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
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
    // Слухаємо зміни мережі та MQTT через Provider
    final isConnected = context.watch<NetworkService>().isConnected;
    final mqttService = context.watch<MqttService>();

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
            onPressed: _confirmLogout, // Викликаємо діалог підтвердження
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // 1. Перманентне попередження при втраті мережі
          if (!isConnected)
            Container(
              width: double.infinity,
              color: Colors.redAccent,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Немає з\'єднання з мережею. Режим обмеженої функціональності.',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

          // 2. Картка телеметрії IoT (MQTT)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF312E81), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: mqttService.isBrokerConnected
                    ? Colors.greenAccent.withAlpha(100)
                    : Colors.orangeAccent.withAlpha(100),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.sensors, color: Color(0xFF818CF8)),
                        SizedBox(width: 8),
                        Text(
                          'IoT Датчик (MQTT)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: mqttService.isBrokerConnected
                                ? Colors.greenAccent
                                : Colors.orangeAccent,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          mqttService.isBrokerConnected ? 'Online' : 'Offline',
                          style: TextStyle(
                            fontSize: 12,
                            color: mqttService.isBrokerConnected
                                ? Colors.greenAccent
                                : Colors.orangeAccent,
                          ),
                        ),
                        if (!mqttService.isBrokerConnected && isConnected)
                          IconButton(
                            icon: const Icon(Icons.refresh, size: 18, color: Colors.white70),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => mqttService.connectAndListen(),
                            tooltip: 'Перепідключити MQTT',
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Топік: ${MqttService.topic}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 6),
                Text(
                  'Отримано: ${mqttService.latestPayload}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // 3. Ваш основний список режимів (CRUD)
          Expanded(
            child: _isLoading
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
          ),
        ],
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