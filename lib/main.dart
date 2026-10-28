import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Лабораторна 1',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Лабораторна робота 1'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  final TextEditingController _inputController = TextEditingController();
  String? _errorMessage;

  void _processInput() {
    setState(() {
      _errorMessage = null; // Очищуємо попередню помилку
      String input = _inputController.text.trim();

      if (input == 'Avada Kedavra') {
        _counter = 0; // Сценарій: Скидання до нуля
        _inputController.clear();
        return;
      }

      int? parsedNumber = int.tryParse(input);
      if (parsedNumber != null) {
        _counter += parsedNumber; // Сценарій: Додавання введеного числа
        _inputController.clear();
      } else {
        _errorMessage = 'Введіть ціле число або "Avada Kedavra"'; // Сценарій: Обробка помилки
      }
    });
  }

  @override
  void dispose() {
    // Очищення контролера з пам'яті при закритті віджета
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Поточне значення лічильника:',
                style: TextStyle(fontSize: 18),
              ),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _inputController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Введіть число або закляття',
                  errorText: _errorMessage, // Відображення помилки, якщо вона є
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _processInput,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: const Text('Застосувати', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// фінальний коміт