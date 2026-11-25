import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/devices/devices_bloc.dart';
import '../logic/devices/devices_event.dart';
import '../logic/devices/devices_state.dart';

class RemoteDevicesSection extends StatelessWidget {
  const RemoteDevicesSection({super.key});

  void _showAddDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Новий хмарний вузол'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Назва сценарію / лампи'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Скасувати'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<DevicesBloc>().add(AddDeviceEvent(controller.text));
              Navigator.pop(dialogCtx);
            },
            child: const Text('Додати'),
          ),
        ],
      ),
    );
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
                  'Хмарні сценарії (BLoC)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, size: 22),
                      onPressed: () => _showAddDialog(context),
                      tooltip: 'Додати вузол',
                    ),
                    IconButton(
                      icon: const Icon(Icons.sync, size: 20),
                      onPressed: () => context
                          .read<DevicesBloc>()
                          .add(const LoadDevicesEvent()),
                      tooltip: 'Оновити з сервера',
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<DevicesBloc, DevicesState>(
              builder: (context, state) {
                if (state is DevicesLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is DevicesError) {
                  return Center(
                    child: Text(state.message,
                        style: const TextStyle(color: Colors.redAccent)),
                  );
                }
                final devices = state is DevicesLoaded ? state.devices : [];
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
                          item.isActive ? Icons.cloud_done : Icons.lightbulb_outline,
                          color: item.isActive
                              ? Colors.greenAccent
                              : const Color(0xFF818CF8),
                        ),
                        title: Text('Вузол #${item.id}: ${item.title}',
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.redAccent),
                          onPressed: () => context
                              .read<DevicesBloc>()
                              .add(DeleteDeviceEvent(item.id)),
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