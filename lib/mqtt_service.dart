import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  static final MqttService _instance = MqttService._internal();
  factory MqttService() => _instance;
  MqttService._internal();

  late MqttServerClient client;

  Function(String topic, String message)? onMessage;

  // --------------------------------------
  // MQTT TOPICS (DART VERSION)
  // --------------------------------------
  static const String TOPIC_SUHU              = "kelompok/iot/sensor/suhu";
  static const String TOPIC_LEMBAP            = "kelompok/iot/sensor/kelembapan";

  // --- Commands ---
  static const String TOPIC_CMD_KUNCI      = "kelompok/iot/perintah/kunci";
  static const String TOPIC_CMD_LAMPU      = "kelompok/iot/perintah/lampu";
  static const String TOPIC_CMD_KIPAS      = "kelompok/iot/perintah/kipas";
  static const String TOPIC_CMD_MODE_KUNCI = "kelompok/iot/perintah/modeKunci";
  static const String TOPIC_CMD_MODE_KIPAS = "kelompok/iot/perintah/modeKipas";

  // --------------------------------------

  Future<void> connect() async {
    client = MqttServerClient('broker.hivemq.com', 'flutter_smart_home');
    client.port = 1883;
    client.keepAlivePeriod = 20;
    client.logging(on: false);

    client.onDisconnected = () {
      print("MQTT Disconnected");
    };

    client.onConnected = () {
      print("MQTT Connected");
    };

    // LISTEN TO INCOMING MESSAGES
    client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> event) {
      final MqttPublishMessage message =
          event.first.payload as MqttPublishMessage;

      final String payload =
          MqttPublishPayload.bytesToStringAsString(message.payload.message);

      if (onMessage != null) {
        onMessage!(event.first.topic, payload);
      }
    });

    try {
      await client.connect();

      print("MQTT CONNECTED SUCCESS");

      // Example auto-subscribe:
      subscribe(TOPIC_CMD_LAMPU);
      subscribe(TOPIC_CMD_KUNCI);
      subscribe(TOPIC_CMD_KIPAS);

    } catch (e) {
      client.disconnect();
      print("MQTT ERROR: $e");
    }
  }

  void subscribe(String topic) {
    client.subscribe(topic, MqttQos.atMostOnce);
    print("Subscribed to: $topic");
  }

  void publish(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
    print("Publish: $topic => $message");
  }
}
