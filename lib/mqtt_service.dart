import 'dart:async';
import 'dart:io';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  static final MqttService _instance = MqttService._internal();
  factory MqttService() => _instance;
  MqttService._internal();

  MqttServerClient? client;

  void Function(String topic, String msg)? onMessage;
  bool _isConnected = false;

  // --------------------------------------
  // MQTT CONFIGURATION
  // --------------------------------------
  static const String MQTT_BROKER = '192.168.1.100';  // ⬅️ Ganti dengan IP broker Anda
  static const int MQTT_PORT = 1883;

  // --------------------------------------
  // MQTT TOPICS
  // --------------------------------------
  static const String TOPIC_SUHU              = "kelompok/iot/sensor/suhu";
  static const String TOPIC_LEMBAP            = "kelompok/iot/sensor/kelembapan";

  // --- Commands ---
  static const String TOPIC_CMD_LED_FLOOR1      = "kelompok/iot/perintah/led_floor1";
  static const String TOPIC_CMD_SERVO_DOOR      = "kelompok/iot/perintah/servo_door";
  static const String TOPIC_CMD_FAN             = "kelompok/iot/perintah/fan";
  static const String TOPIC_CMD_LED1_FLOOR2     = "kelompok/iot/perintah/led1_floor2";
  static const String TOPIC_CMD_LED2_FLOOR2     = "kelompok/iot/perintah/led2_floor2";

  // --- Status ---
  static const String TOPIC_STATUS_LED_FLOOR1   = "kelompok/iot/status/led_floor1";
  static const String TOPIC_STATUS_SERVO_DOOR   = "kelompok/iot/status/servo_door";
  static const String TOPIC_STATUS_FAN          = "kelompok/iot/status/fan";
  static const String TOPIC_STATUS_LED1_FLOOR2  = "kelompok/iot/status/led1_floor2";
  static const String TOPIC_STATUS_LED2_FLOOR2  = "kelompok/iot/status/led2_floor2";

  // --------------------------------------
  // CONNECT TO MQTT BROKER
  // --------------------------------------
  Future<void> connect() async {
    try {
      final String clientId = 'flutter_smart_home_${DateTime.now().millisecondsSinceEpoch}';
      
      print('🔌 Creating MQTT Client...');
      print('📍 Broker: $MQTT_BROKER:$MQTT_PORT');
      print('🆔 Client ID: $clientId');
      
      client = MqttServerClient(MQTT_BROKER, clientId);
      
      client!.port = MQTT_PORT;
      client!.keepAlivePeriod = 60;
      client!.logging(on: true);
      client!.autoReconnect = true;
      client!.resubscribeOnAutoReconnect = true;
      client!.connectTimeoutPeriod = 5000;

      final connMessage = MqttConnectMessage()
          .withClientIdentifier(clientId)
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);
      
      client!.connectionMessage = connMessage;

      client!.onDisconnected = _onDisconnected;
      client!.onConnected = _onConnected;
      client!.onSubscribed = _onSubscribed;
      client!.onAutoReconnect = _onAutoReconnect;
      client!.onAutoReconnected = _onAutoReconnected;

      print('🔌 Connecting to MQTT Broker...');
      await client!.connect();

      if (client!.connectionStatus!.state == MqttConnectionState.connected) {
        print('✅ MQTT Connected Successfully!');
        print('📊 Connection Status: ${client!.connectionStatus}');
        _isConnected = true;

        client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
          final MqttPublishMessage message = messages[0].payload as MqttPublishMessage;
          final String topic = messages[0].topic;
          final String payload = MqttPublishPayload.bytesToStringAsString(message.payload.message);

          print('📨 Received: $topic => $payload');

          if (onMessage != null) {
            onMessage!(topic, payload);
          }
        });

        // Subscribe to topics
        _subscribeToTopics();

      } else {
        print('❌ MQTT Connection Failed');
        print('📊 Status: ${client!.connectionStatus}');
        client!.disconnect();
        _isConnected = false;
      }

    } catch (e) {
      print('❌ MQTT Connection Error: $e');
      print('📍 Make sure MQTT broker is running at $MQTT_BROKER:$MQTT_PORT');
      print('💡 Tips:');
      print('   - Check if broker is running');
      print('   - Check firewall settings');
      print('   - Check network connection');
      print('   - Ping the broker IP: ping $MQTT_BROKER');
      
      client?.disconnect();
      _isConnected = false;
      rethrow;
    }
  }

  // --------------------------------------
  // SUBSCRIBE TO TOPICS
  // --------------------------------------
  void _subscribeToTopics() {
    print('📥 Subscribing to topics...');
    
    // Subscribe to sensor topics
    subscribe(TOPIC_SUHU);
    subscribe(TOPIC_LEMBAP);

    // Subscribe to device status topics - Lantai 1
    subscribe(TOPIC_STATUS_LED_FLOOR1);
    subscribe(TOPIC_STATUS_SERVO_DOOR);
    subscribe(TOPIC_STATUS_FAN);
    
    // Subscribe to device status topics - Lantai 2
    subscribe(TOPIC_STATUS_LED1_FLOOR2);
    subscribe(TOPIC_STATUS_LED2_FLOOR2);

    print('✅ All subscriptions completed');
  }

  // --------------------------------------
  // CALLBACKS
  // --------------------------------------
  void _onConnected() {
    print('✅ MQTT Connected Callback');
    print('📊 Server: $MQTT_BROKER:$MQTT_PORT');
    _isConnected = true;
  }

  void _onDisconnected() {
    print('❌ MQTT Disconnected Callback');
    print('📊 Reason: ${client?.connectionStatus}');
    _isConnected = false;
  }

  void _onSubscribed(String topic) {
    print('✅ Subscribed to: $topic');
  }

  void _onAutoReconnect() {
    print('🔄 Auto reconnecting to MQTT broker...');
  }

  void _onAutoReconnected() {
    print('✅ Auto reconnected successfully!');
    _isConnected = true;
  }

  // --------------------------------------
  // DISCONNECT
  // --------------------------------------
  void disconnect() {
    if (client != null) {
      print('🔌 Disconnecting from MQTT broker...');
      _isConnected = false;
      client!.disconnect();
      print('✅ MQTT Service Disconnected');
    }
  }

  // --------------------------------------
  // SUBSCRIBE TO TOPIC
  // --------------------------------------
  void subscribe(String topic) {
    if (client != null && _isConnected) {
      client!.subscribe(topic, MqttQos.atMostOnce);
      print('📥 Subscribing to: $topic');
    } else {
      print('⚠️ Cannot subscribe to $topic - Not connected');
    }
  }

  // --------------------------------------
  // UNSUBSCRIBE FROM TOPIC
  // --------------------------------------
  void unsubscribe(String topic) {
    if (client != null && _isConnected) {
      client!.unsubscribe(topic);
      print('📤 Unsubscribed from: $topic');
    }
  }

  // --------------------------------------
  // PUBLISH MESSAGE
  // --------------------------------------
  void publish(String topic, String message) {
    if (!_isConnected || client == null) {
      print('⚠️ MQTT not connected, cannot publish');
      print('📍 Topic: $topic');
      print('📝 Message: $message');
      return;
    }

    try {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      client!.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
      print('📤 Published: $topic => $message');
    } catch (e) {
      print('❌ Publish Error: $e');
      print('📍 Topic: $topic');
      print('📝 Message: $message');
    }
  }

  // --------------------------------------
  // PUBLISH WITH QOS
  // --------------------------------------
  void publishWithQos(String topic, String message, MqttQos qos) {
    if (!_isConnected || client == null) {
      print('⚠️ MQTT not connected, cannot publish');
      return;
    }

    try {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      client!.publishMessage(topic, qos, builder.payload!);
      print('📤 Published (QoS $qos): $topic => $message');
    } catch (e) {
      print('❌ Publish Error: $e');
    }
  }

  // --------------------------------------
  // PUBLISH RETAINED MESSAGE
  // --------------------------------------
  void publishRetained(String topic, String message) {
    if (!_isConnected || client == null) {
      print('⚠️ MQTT not connected, cannot publish');
      return;
    }

    try {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      client!.publishMessage(
        topic, 
        MqttQos.atMostOnce, 
        builder.payload!,
        retain: true,
      );
      print('📤 Published (Retained): $topic => $message');
    } catch (e) {
      print('❌ Publish Error: $e');
    }
  }

  // --------------------------------------
  // GETTERS
  // --------------------------------------
  bool get isConnected => _isConnected;
  
  MqttConnectionState? get connectionState => client?.connectionStatus?.state;
  
  String get connectionStatus {
    if (_isConnected) {
      return 'Connected to $MQTT_BROKER:$MQTT_PORT';
    } else {
      return 'Disconnected';
    }
  }

  // --------------------------------------
  // RECONNECT
  // --------------------------------------
  Future<void> reconnect() async {
    print('🔄 Attempting to reconnect...');
    disconnect();
    await Future.delayed(const Duration(seconds: 2));
    await connect();
  }

  // --------------------------------------
  // PING BROKER
  // --------------------------------------
  Future<bool> pingBroker() async {
    try {
      if (client != null && _isConnected) {
        return client!.connectionStatus!.state == MqttConnectionState.connected;
      }
      return false;
    } catch (e) {
      print('❌ Ping Error: $e');
      return false;
    }
  }

  // --------------------------------------
  // GET SUBSCRIBED TOPICS
  // --------------------------------------
  List<String> getSubscribedTopics() {
    if (client != null && client!.subscriptionsManager != null) {
      return client!.subscriptionsManager!.subscriptions.keys
          .map((key) => key.toString())
          .toList();
    }
    return [];
  }

  // --------------------------------------
  // CLEAR ALL SUBSCRIPTIONS
  // --------------------------------------
  void clearAllSubscriptions() {
    if (client != null && _isConnected) {
      final topics = getSubscribedTopics();
      for (var topic in topics) {
        unsubscribe(topic);
      }
      print('🗑️ All subscriptions cleared');
    }
  }
}
