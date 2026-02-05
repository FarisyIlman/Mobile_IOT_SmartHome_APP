import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_2/main.dart';

void main() {
  testWidgets('Smart Home app loads basic UI', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: MonitoringScreen(enableBackgroundTasks: false)),
    );
    await tester.pump();

    // App wrapper exists
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);

    // Header text exists (no AppBar in this UI)
    expect(find.text('Smart Home'), findsOneWidget);
    expect(find.text('Monitoring System'), findsOneWidget);
  });
}
