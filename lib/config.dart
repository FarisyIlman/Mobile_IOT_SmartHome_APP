class AppConfig {
  // ⬇️ KONFIGURASI SERVER ANDA ⬇️
  
  // MQTT Configuration
  // Edit MQTT_BROKER dan MQTT_PORT di mqtt_service.dart
  // static const String MQTT_BROKER = '192.168.1.100';  // ❌ Tidak digunakan
  // static const int MQTT_PORT = 1883;                   // ❌ Tidak digunakan
  
  // REST API Configuration (Laravel)
  static const String API_HOST = '192.168.141.138';
  static const int API_PORT = 8000;
  static const String API_BASE_URL = 'http://$API_HOST:$API_PORT/api';
  
  // MQTT Topics - Didefinisikan di mqtt_service.dart
  // Gunakan MqttService.TOPIC_* untuk akses topic
  
  // Timeout Configuration
  static const Duration API_TIMEOUT = Duration(seconds: 10);
  static const Duration MQTT_TIMEOUT = Duration(seconds: 5);
  
  // App Settings
  static const String APP_NAME = 'Smart Home Monitoring';
  static const String APP_VERSION = '1.0.0';
}