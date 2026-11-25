import '../../domain/models/iot_device_model.dart';

abstract class DevicesState {
  const DevicesState();
}

class DevicesInitial extends DevicesState {
  const DevicesInitial();
}

class DevicesLoading extends DevicesState {
  const DevicesLoading();
}

class DevicesLoaded extends DevicesState {
  final List<IoTDeviceModel> devices;
  const DevicesLoaded(this.devices);
}

class DevicesError extends DevicesState {
  final String message;
  const DevicesError(this.message);
}