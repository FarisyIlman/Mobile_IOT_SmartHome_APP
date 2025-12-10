class AppConfig {
  // ⬇️ KONFIGURASI SERVER ANDA ⬇️
  
  // MQTT Configuration
  static const String MQTT_BROKER = '192.168.1.100';
  static const int MQTT_PORT = 1883;
  
  // REST API Configuration (jika dibutuhkan)
  static const String API_HOST = '192.168.1.100';
  static const int API_PORT = 3000;
  static const String API_BASE_URL = 'http://$API_HOST:$API_PORT/api';
  
  // MQTT Topics
  static const String TOPIC_SUHU = "kelompok/iot/sensor/suhu";
  static const String TOPIC_LEMBAP = "kelompok/iot/sensor/kelembapan";
  
  static const String TOPIC_CMD_LAMPU_FLOOR1 = "kelompok/iot/perintah/lampu_floor1";
  static const String TOPIC_CMD_LAMPU_FLOOR2 = "kelompok/iot/perintah/lampu_floor2";
  static const String TOPIC_CMD_CURTAIN = "kelompok/iot/perintah/curtain_floor1";
  
  static const String TOPIC_STATUS_LAMPU_FLOOR1 = "kelompok/iot/status/lampu_floor1";
  static const String TOPIC_STATUS_LAMPU_FLOOR2 = "kelompok/iot/status/lampu_floor2";
  static const String TOPIC_STATUS_CURTAIN = "kelompok/iot/status/curtain_floor1";
  
  // Timeout Configuration
  static const Duration API_TIMEOUT = Duration(seconds: 10);
  static const Duration MQTT_TIMEOUT = Duration(seconds: 5);
  
  // App Settings
  static const String APP_NAME = 'Smart Home Monitoring';
  static const String APP_VERSION = '1.0.0';
}