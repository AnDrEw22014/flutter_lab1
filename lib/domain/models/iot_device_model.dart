class IoTDeviceModel {
  final int id;
  final String title;
  final bool isActive;

  const IoTDeviceModel({
    required this.id,
    required this.title,
    required this.isActive,
  });

  factory IoTDeviceModel.fromJson(Map<String, dynamic> json) {
    return IoTDeviceModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? 'Smart Lamp Node',
      isActive: json['completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'completed': isActive,
    };
  }
}