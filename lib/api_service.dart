import 'dart:convert';
import 'config.dart'; // ⬅️ Import config
import 'package:http/http.dart' as http;

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // ⬇️ MENGGUNAKAN CONFIG ⬇️
  static String get BASE_URL => AppConfig.API_BASE_URL;

  Future<Map<String, dynamic>?> getSensorData() async {
    try {
      print('📡 Fetching sensor data from: $BASE_URL/sensors');
      
      final response = await http.get(
        Uri.parse('$BASE_URL/sensors'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(AppConfig.API_TIMEOUT);

      if (response.statusCode == 200) {
        print('✅ Sensor data received');
        return json.decode(response.body);
      } else {
        print('❌ API Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ API Request Error: $e');
      return null;
    }
  }

  // POST Request - Kirim perintah device
  Future<bool> sendDeviceCommand(String deviceId, bool isOn) async {
    try {
      final response = await http.post(
        Uri.parse('$BASE_URL/devices/command'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'device_id': deviceId,
          'state': isOn ? 1 : 0,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        print('✅ Command sent successfully');
        return true;
      } else {
        print('❌ API Error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ API Request Error: $e');
      return false;
    }
  }

  // GET Request - Ambil history data
  Future<List<Map<String, dynamic>>?> getDeviceHistory(String deviceId) async {
    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/devices/$deviceId/history'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        print('❌ API Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ API Request Error: $e');
      return null;
    }
  }
}