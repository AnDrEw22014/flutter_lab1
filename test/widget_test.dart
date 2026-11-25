import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/core/di/injection_container.dart';
import 'package:flutter_application_1/main.dart';

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
    setupDependencies();
  });

  testWidgets('App initializes and renders root widget', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(MyApp), findsOneWidget);
  });
}