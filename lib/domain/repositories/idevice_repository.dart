import '../models/iot_device_model.dart';

abstract class IDeviceRepository {
  Future<List<IoTDeviceModel>> getDevices();
}