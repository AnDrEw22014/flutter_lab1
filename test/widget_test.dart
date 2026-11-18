import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/domain/models/iot_device_model.dart';
import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('App initializes and renders root widget', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  test('IoTDeviceModel correctly parses fromJson and serializes toJson', () {
    final json = {'id': 1, 'title': 'Smart Lamp Node', 'completed': true};
    final device = IoTDeviceModel.fromJson(json);

    expect(device.id, 1);
    expect(device.title, 'Smart Lamp Node');
    expect(device.isActive, true);
    expect(device.toJson(), json);
  });
}