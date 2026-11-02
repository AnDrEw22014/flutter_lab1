import 'user_profile_screen.dart';
import 'package:flutter/material.dart';
import '../widgets/device_status_badge.dart';
import '../widgets/focus_mode_card.dart';

// StatefulWidget використовуємо, щоб повзунок яскравості міг рухатися
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  double _brightness = 75.0; // Mock-дані яскравості

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Керування лампою'),
        actions: [
          const Center(child: DeviceStatusBadge()),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserProfileScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView( // Запобігає overflow по вертикалі
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Поточна сесія (Pomodoro)',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blueAccent, width: 4),
                ),
                child: const Center(
                  child: Text(
                    '25:00', // Mock-дані таймера
                    style: TextStyle(fontSize: 56, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Row( // Використання Row + Expanded для респонсивності
                children: [
                  const Icon(Icons.lightbulb_outline),
                  Expanded(
                    child: Slider(
                      value: _brightness,
                      min: 0,
                      max: 100,
                      activeColor: Colors.blueAccent,
                      onChanged: (value) {
                        setState(() {
                          _brightness = value;
                        });
                      },
                    ),
                  ),
                  const Icon(Icons.lightbulb),
                ],
              ),
              const SizedBox(height: 32),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Режими освітлення',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  FocusModeCard(title: 'Кодинг', icon: Icons.code, color: Colors.blue),
                  SizedBox(width: 12),
                  FocusModeCard(title: 'Читання', icon: Icons.menu_book, color: Colors.orange),
                  SizedBox(width: 12),
                  FocusModeCard(title: 'Релакс', icon: Icons.coffee, color: Colors.green),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}