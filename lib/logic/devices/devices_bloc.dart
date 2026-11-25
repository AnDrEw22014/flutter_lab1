import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/iot_device_model.dart';
import '../../domain/repositories/idevice_repository.dart';
import 'devices_event.dart';
import 'devices_state.dart';

class DevicesBloc extends Bloc<DevicesEvent, DevicesState> {
  final IDeviceRepository _repository;
  List<IoTDeviceModel> _currentList = [];

  DevicesBloc(this._repository) : super(const DevicesInitial()) {
    on<LoadDevicesEvent>(_onLoadDevices);
    on<AddDeviceEvent>(_onAddDevice);
    on<DeleteDeviceEvent>(_onDeleteDevice);
  }

  Future<void> _onLoadDevices(
    LoadDevicesEvent event,
    Emitter<DevicesState> emit,
  ) async {
    emit(const DevicesLoading());
    try {
      _currentList = await _repository.getDevices();
      emit(DevicesLoaded(List.unmodifiable(_currentList)));
    } catch (e) {
      emit(DevicesError(e.toString()));
    }
  }

  void _onAddDevice(AddDeviceEvent event, Emitter<DevicesState> emit) {
    final title = event.title.trim();
    if (title.isEmpty) return;
    final nextId = _currentList.isEmpty ? 1 : _currentList.last.id + 1;
    _currentList = [
      ..._currentList,
      IoTDeviceModel(id: nextId, title: title, isActive: false),
    ];
    emit(DevicesLoaded(List.unmodifiable(_currentList)));
  }

  void _onDeleteDevice(DeleteDeviceEvent event, Emitter<DevicesState> emit) {
    _currentList = _currentList.where((d) => d.id != event.id).toList();
    emit(DevicesLoaded(List.unmodifiable(_currentList)));
  }
}