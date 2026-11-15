import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService extends ChangeNotifier {
  late MqttServerClient _client;
  StreamSubscription<List<MqttReceivedMessage<MqttMessage>>>? _updatesSub;

  // Унікальний топік (обов'язково вкажіть його в описі PR)
  static const String topic = 'lviv_poly/iot/lab4/lashta/temperature';

  String _latestPayload = 'Очікування даних...';
  String get latestPayload => _latestPayload;

  bool _isBrokerConnected = false;
  bool get isBrokerConnected => _isBrokerConnected;

  Future<void> connectAndListen() async {
    if (_isBrokerConnected) return;

    // Генеруємо унікальний ID клієнта, щоб брокер не розривав з'єднання
    final clientId = 'flutter_lashta_${DateTime.now().millisecondsSinceEpoch}';
    _client = MqttServerClient('broker.hivemq.com', clientId);
    _client.port = 1883;
    _client.logging(on: false);
    _client.keepAlivePeriod = 20;

    _client.onDisconnected = () {
      _isBrokerConnected = false;
      notifyListeners();
    };

    _client.onConnected = () {
      _isBrokerConnected = true;
      notifyListeners();
    };

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    _client.connectionMessage = connMessage;

    try {
      await _client.connect();
    } catch (e) {
      debugPrint('MQTT Connection failed: $e');
      _client.disconnect();
      return;
    }

    if (_client.connectionStatus?.state == MqttConnectionState.connected) {
      _isBrokerConnected = true;
      notifyListeners();

      _client.subscribe(topic, MqttQos.atMostOnce);

      // Зберігаємо підписку на потік для подальшого закриття
      _updatesSub = _client.updates?.listen((messages) {
        final recMess = messages[0].payload as MqttPublishMessage;
        final payload =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

        _latestPayload = payload;
        notifyListeners();
      });
    }
  }

  void disconnect() {
    _updatesSub?.cancel();
    if (_isBrokerConnected) {
      _client.disconnect();
    }
    _isBrokerConnected = false;
    notifyListeners();
  }

  @override
  void dispose() {
    disconnect(); // Закриваємо потік та відключаємось при знищенні
    super.dispose();
  }
}