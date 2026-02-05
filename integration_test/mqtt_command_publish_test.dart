import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import 'package:flutter_application_2/main.dart' as app;
import 'package:flutter_application_2/mqtt_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('UI publishes MQTT command topics (All Off)', (tester) async {
    final receivedAnyZero = Completer<void>();

    final subscriberClientId =
        'itest_sub_${DateTime.now().millisecondsSinceEpoch}';

    final subClient =
        MqttServerClient(MqttService.MQTT_BROKER, subscriberClientId);
    subClient.port = MqttService.MQTT_PORT;
    subClient.logging(on: false);
    subClient.keepAlivePeriod = 30;
    subClient.connectTimeoutPeriod = 8000;
    subClient.connectionMessage = MqttConnectMessage()
        .withClientIdentifier(subscriberClientId)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);

    await subClient.connect();
    expect(subClient.connectionStatus?.state, MqttConnectionState.connected);

    subClient.subscribe(MqttService.TOPIC_CMD_LAMPU, MqttQos.atMostOnce);
    subClient.subscribe(MqttService.TOPIC_CMD_KUNCI, MqttQos.atMostOnce);
    subClient.subscribe(MqttService.TOPIC_CMD_KIPAS, MqttQos.atMostOnce);

    final subscription = subClient.updates?.listen((messages) {
      if (messages.isEmpty) return;
      final message = messages.first;
      final payload = message.payload as MqttPublishMessage;
      final text = MqttPublishPayload.bytesToStringAsString(
        payload.payload.message,
      );

      if (text.trim() == '0' && !receivedAnyZero.isCompleted) {
        receivedAnyZero.complete();
      }
    });

    app.main();

    // Let the app render + init MQTT/API.
    await tester.pumpAndSettle(const Duration(seconds: 6));
    await tester.pump(const Duration(seconds: 2));

    // Trigger the built-in action that publishes '0' to command topics.
    await tester.tap(find.text('All Off'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    await receivedAnyZero.future.timeout(const Duration(seconds: 15));

    await subscription?.cancel();
    subClient.disconnect();
  });
}
