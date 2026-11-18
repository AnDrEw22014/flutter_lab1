import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/iot_device_model.dart';
import '../../domain/repositories/idevice_repository.dart';

class RemoteDeviceRepository implements IDeviceRepository {
  static const String _apiUrl =
      'https://jsonplaceholder.typicode.com/todos?_limit=5';
  static const String _cacheKey = 'cached_iot_devices';

  final http.Client _client;

  RemoteDeviceRepository({http.Client? client})
      : _client = client ?? http.Client();

  @override
  Future<List<IoTDeviceModel>> getDevices() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final response = await _client
          .get(Uri.parse(_apiUrl))
          .timeout(const Duration(seconds: 6));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> decoded = jsonDecode(response.body) as List<dynamic>;
        final devices = decoded
            .map((e) => IoTDeviceModel.fromJson(e as Map<String, dynamic>))
            .toList();

        // Зберігаємо актуальний JSON у локальний кеш (Offline-First)
        await prefs.setString(_cacheKey, response.body);
        return devices;
      } else {
        throw Exception('Помилка сервера: HTTP ${response.statusCode}');
      }
    } catch (e) {
      // Якщо інтернету немає або сервер не відповідає — беремо дані з кешу
      final cachedJson = prefs.getString(_cacheKey);
      if (cachedJson != null && cachedJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(cachedJson) as List<dynamic>;
        return decoded
            .map((e) => IoTDeviceModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Немає мережі та відсутній локальний кеш ($e)');
    }
  }
}