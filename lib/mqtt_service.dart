import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  static final MqttService _instance = MqttService._internal();
  factory MqttService() => _instance;
  MqttService._internal();

  late MqttServerClient client;

  void Function(String topic, String msg)? onMessage;
  bool _isConnected = false;

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

  void disconnect() {
    _isConnected = false;
    client.disconnect();
    print('MQTT Service Disconnected');
  }

  void subscribe(String topic) {
    client.subscribe(topic, MqttQos.atMostOnce);
    print("Subscribed to: $topic");
  }

  void publish(String topic, String message) {
    if (!_isConnected) {
      print('MQTT not connected');
      return;
    }
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
    print("Publish: $topic => $message");
  }

  void _startSimulation() {
    // Simulasi sensor data setiap 3 detik
    Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_isConnected) {
        timer.cancel();
        return;
      }
      
      // Simulasi data temperature dan humidity dari MQTT broker
      // Ganti dengan implementasi real MQTT jika sudah tersedia
    });
  }

  // Helper untuk simulasi incoming message saat development
  void simulateIncoming(String topic, String msg) {
    if (onMessage != null) {
      onMessage!(topic, msg);
    }
  }
}
