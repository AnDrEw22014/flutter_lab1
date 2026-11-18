import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService extends ChangeNotifier {
  static const String broker = 'broker.hivemq.com';
  static const int port = 1883;
  static const String topic = 'lviv_poly/iot/lab4/lashta/temperature';

  late final MqttServerClient _client;
  StreamSubscription<List<MqttReceivedMessage<MqttMessage>>>? _updatesSub;

  bool _isBrokerConnected = false;
  String _latestPayload = 'Очікування даних...';

  bool get isBrokerConnected => _isBrokerConnected;
  String get latestPayload => _latestPayload;

  MqttService() {
    final clientId =
        'flutter_lashta_${DateTime.now().millisecondsSinceEpoch}';
    _client = MqttServerClient.withPort(broker, clientId, port);
    _client.logging(on: false);
    _client.keepAlivePeriod = 20;
    _client.autoReconnect = true;

    // Колбек при успішному підключенні або автоперепідключенні
    _client.onConnected = _onConnected;
    _client.onAutoReconnected = _onConnected;

    // Перевірка на пропадання з'єднання з брокером (обрив мережі / тайм-аут Keep-Alive)
    _client.onDisconnected = _onDisconnected;
    _client.onAutoReconnect = _onDisconnected;
  }

  void _onConnected() {
    _isBrokerConnected = true;
    notifyListeners();
  }

  void _onDisconnected() {
    _isBrokerConnected = false;
    notifyListeners();
  }

  Future<void> connectAndListen() async {
    if (_client.connectionStatus?.state == MqttConnectionState.connected) {
      return;
    }

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(_client.clientIdentifier)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    _client.connectionMessage = connMessage;

    try {
      await _client.connect();
    } catch (e) {
      debugPrint('Помилка підключення до MQTT-брокера: $e');
      _client.disconnect();
      _isBrokerConnected = false;
      notifyListeners();
      return;
    }

    if (_client.connectionStatus?.state == MqttConnectionState.connected) {
      _isBrokerConnected = true;
      notifyListeners();

      _client.subscribe(topic, MqttQos.atMostOnce);

      // Скасовуємо попередню підписку, якщо вона існувала, щоб уникнути дублювання
      await _updatesSub?.cancel();

      // Зберігаємо підписку на потік для подальшого закриття та обробки помилок
      _updatesSub = _client.updates?.listen(
        (messages) {
          if (messages.isEmpty) return;

          try {
            final recMess = messages[0].payload as MqttPublishMessage;
            final payload = MqttPublishPayload.bytesToStringAsString(
              recMess.payload.message,
            );

            _latestPayload = payload;
            notifyListeners();
          } catch (e) {
            debugPrint('Помилка розбору MQTT-повідомлення: $e');
          }
        },
        // Перевірка на помилку потоку або його закриття при втраті мережі
        onError: (Object error) {
          debugPrint('Помилка потоку MQTT updates: $error');
          _isBrokerConnected = false;
          notifyListeners();
        },
        onDone: () {
          debugPrint('Потік MQTT updates закрито');
          _isBrokerConnected = false;
          notifyListeners();
        },
        cancelOnError: false,
      );
    } else {
      _isBrokerConnected = false;
      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    await _updatesSub?.cancel();
    _updatesSub = null;
    _client.disconnect();
    _isBrokerConnected = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _updatesSub?.cancel();
    _client.disconnect();
    super.dispose();
  }
}