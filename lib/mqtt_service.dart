import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
// Remove web import for now
// import 'package:mqtt_client/mqtt_browser_client.dart';


class MqttService {
  static final MqttService _instance = MqttService._internal();
  factory MqttService() => _instance;
  MqttService._internal();

  MqttClient? client;

  void Function(String topic, String msg)? onMessage;
  bool _isConnected = false;

  // --------------------------------------
  // MQTT CONFIGURATION
  // --------------------------------------
  // Broker MQTT lokal (Laptop)
  static const String MQTT_BROKER = '192.168.141.138';
  static const int MQTT_PORT = 1883;
  static const String MQTT_WS_URL = 'ws://broker.hivemq.com:8000/mqtt';  // WebSocket untuk Web

  // -------------------------------------- 
  // MQTT TOPICS
  // --------------------------------------
  // --- MQTT TOPICS (PUBLISH dari ESP32 / SUBSCRIBE di Flutter) ---
  static const String TOPIC_SUHU              = "kelompok/iot/sensor/suhu";
  static const String TOPIC_LEMBAP            = "kelompok/iot/sensor/kelembapan";
  static const String TOPIC_CAHAYA            = "kelompok/iot/sensor/cahaya";
  static const String TOPIC_WAKTU             = "kelompok/iot/info/waktu";
  static const String TOPIC_STATUS_LAMPU      = "kelompok/iot/status/lampu";
  static const String TOPIC_STATUS_KUNCI      = "kelompok/iot/status/kunci";
  static const String TOPIC_STATUS_KIPAS      = "kelompok/iot/status/kipas";
  static const String TOPIC_STATUS_MODE_KUNCI = "kelompok/iot/status/modeKunci";
  static const String TOPIC_STATUS_MODE_KIPAS = "kelompok/iot/status/modeKipas";
  static const String TOPIC_LOG_KEAMANAN      = "kelompok/iot/log/keamanan";

  // --- MQTT TOPICS (SUBSCRIBE dari ESP32 / PUBLISH dari Flutter) ---
  static const String TOPIC_CMD_KUNCI         = "kelompok/iot/perintah/kunci";
  static const String TOPIC_CMD_LAMPU         = "kelompok/iot/perintah/lampu";
  static const String TOPIC_CMD_KIPAS         = "kelompok/iot/perintah/kipas";
  static const String TOPIC_CMD_MODE_KUNCI    = "kelompok/iot/perintah/modeKunci";
  static const String TOPIC_CMD_MODE_KIPAS    = "kelompok/iot/perintah/modeKipas";

  // --------------------------------------
  // CONNECT TO MQTT BROKER
  // --------------------------------------
  Future<void> connect() async {
    try {
      final String clientId = 'flutter_smart_home_${DateTime.now().millisecondsSinceEpoch}';
      
      print('🔌 Creating MQTT Client...');
      
      // Use TCP only for now (mobile/desktop)
      // if (kIsWeb) {
      //   print('🌐 Platform: Web (using WebSocket)');
      //   print('📍 Broker: $MQTT_WS_URL');
      //   client = MqttBrowserClient(MQTT_WS_URL, clientId);
      // } else {
        print('📱 Platform: Mobile/Desktop (using TCP)');
        print('📍 Broker: $MQTT_BROKER:$MQTT_PORT');
        client = MqttServerClient(MQTT_BROKER, clientId);
        (client as MqttServerClient).port = MQTT_PORT;
      // }
      
      print('🆔 Client ID: $clientId');
      
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
    subscribe(TOPIC_CAHAYA);

    // Subscribe to info topics
    subscribe(TOPIC_WAKTU);

    // Subscribe to device status topics
    subscribe(TOPIC_STATUS_LAMPU);
    subscribe(TOPIC_STATUS_KUNCI);
    subscribe(TOPIC_STATUS_KIPAS);
    subscribe(TOPIC_STATUS_MODE_KUNCI);
    subscribe(TOPIC_STATUS_MODE_KIPAS);
    
    // Subscribe to log topics
    subscribe(TOPIC_LOG_KEAMANAN);

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
    // Note: subscriptionsManager is protected in mqtt_client
    // We'll maintain our own list of subscribed topics
    return [
      TOPIC_SUHU,
      TOPIC_LEMBAP,
      TOPIC_CAHAYA,
      TOPIC_WAKTU,
      TOPIC_STATUS_LAMPU,
      TOPIC_STATUS_KUNCI,
      TOPIC_STATUS_KIPAS,
      TOPIC_STATUS_MODE_KUNCI,
      TOPIC_STATUS_MODE_KIPAS,
      TOPIC_LOG_KEAMANAN,
    ];
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
