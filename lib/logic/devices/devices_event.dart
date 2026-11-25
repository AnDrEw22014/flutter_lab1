abstract class DevicesEvent {
  const DevicesEvent();
}

class LoadDevicesEvent extends DevicesEvent {
  const LoadDevicesEvent();
}

class AddDeviceEvent extends DevicesEvent {
  final String title;
  const AddDeviceEvent(this.title);
}

class DeleteDeviceEvent extends DevicesEvent {
  final int id;
  const DeleteDeviceEvent(this.id);
}