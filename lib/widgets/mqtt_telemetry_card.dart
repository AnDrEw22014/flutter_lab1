import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/services/mqtt_service.dart';
import '../data/services/network_service.dart';

class MqttTelemetryCard extends StatelessWidget {
  const MqttTelemetryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isConnected = context.watch<NetworkService>().isConnected;
    final mqttService = context.watch<MqttService>();

    return Container(
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
                  Text('IoT Датчик (MQTT)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Топік: ${MqttService.topic}',
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            'Отримано: ${mqttService.latestPayload}',
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
}