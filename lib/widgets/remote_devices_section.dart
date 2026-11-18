import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/models/iot_device_model.dart';
import '../domain/repositories/idevice_repository.dart';

class RemoteDevicesSection extends StatefulWidget {
  const RemoteDevicesSection({super.key});

  @override
  State<RemoteDevicesSection> createState() => _RemoteDevicesSectionState();
}

class _RemoteDevicesSectionState extends State<RemoteDevicesSection> {
  late Future<List<IoTDeviceModel>> _devicesFuture;

  @override
  void initState() {
    super.initState();
    _devicesFuture = context.read<IDeviceRepository>().getDevices();
  }

  void _refresh() {
    setState(() {
      _devicesFuture = context.read<IDeviceRepository>().getDevices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Хмарні сценарії (REST API)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                IconButton(
                  icon: const Icon(Icons.sync, size: 20),
                  onPressed: _refresh,
                  tooltip: 'Оновити з сервера',
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<IoTDeviceModel>>(
              future: _devicesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        '${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  );
                }
                final devices = snapshot.data ?? [];
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final item = devices[index];
                    return Card(
                      color: const Color(0xFF1E293B),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          item.isActive
                              ? Icons.cloud_done
                              : Icons.lightbulb_outline,
                          color: item.isActive
                              ? Colors.greenAccent
                              : const Color(0xFF818CF8),
                        ),
                        title: Text(
                          'Вузол #${item.id}: ${item.title}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          item.isActive ? 'Синхронізовано' : 'Очікує дії',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}