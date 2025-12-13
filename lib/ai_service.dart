/// Model untuk kondisi lingkungan
enum EnvironmentCondition {
  comfortable, // Nyaman
  normal, // Normal
  hot, // Panas
  humid, // Lembab
  hotHumid, // Panas & Lembab
}

/// Model untuk rekomendasi AI
class AIRecommendation {
  final String title;
  final String description;
  final List<String> actions;
  final EnvironmentCondition condition;

  AIRecommendation({
    required this.title,
    required this.description,
    required this.actions,
    required this.condition,
  });
}

/// Model untuk keputusan auto control
class AutoControlDecision {
  final Map<String, bool> deviceActions; // device_id -> should_turn_on
  final String reason;

  AutoControlDecision({
    required this.deviceActions,
    required this.reason,
  });
}

/// Service AI untuk klasifikasi kondisi dan auto control
class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  // Threshold untuk klasifikasi
  static const double TEMP_COMFORTABLE_MIN = 22.0;
  static const double TEMP_COMFORTABLE_MAX = 26.0;
  static const double TEMP_HOT_THRESHOLD = 28.0;

  static const double HUMIDITY_COMFORTABLE_MIN = 40.0;
  static const double HUMIDITY_COMFORTABLE_MAX = 60.0;
  static const double HUMIDITY_HIGH_THRESHOLD = 70.0;

  // Light threshold (dari sensor LDR atau waktu)
  static const int DARK_HOUR_START = 18; // 6 PM
  static const int DARK_HOUR_END = 6; // 6 AM

  /// Klasifikasi kondisi lingkungan berdasarkan suhu dan kelembaban
  EnvironmentCondition classifyEnvironment(
      double temperature, double humidity) {
    final bool isHot = temperature > TEMP_HOT_THRESHOLD;
    final bool isHumid = humidity > HUMIDITY_HIGH_THRESHOLD;
    final bool isTempComfortable = temperature >= TEMP_COMFORTABLE_MIN &&
        temperature <= TEMP_COMFORTABLE_MAX;
    final bool isHumidityComfortable = humidity >= HUMIDITY_COMFORTABLE_MIN &&
        humidity <= HUMIDITY_COMFORTABLE_MAX;

    if (isHot && isHumid) {
      return EnvironmentCondition.hotHumid;
    } else if (isHot) {
      return EnvironmentCondition.hot;
    } else if (isHumid) {
      return EnvironmentCondition.humid;
    } else if (isTempComfortable && isHumidityComfortable) {
      return EnvironmentCondition.comfortable;
    } else {
      return EnvironmentCondition.normal;
    }
  }

  /// Dapatkan label kondisi dalam bahasa Indonesia
  String getConditionLabel(EnvironmentCondition condition) {
    switch (condition) {
      case EnvironmentCondition.comfortable:
        return 'Nyaman';
      case EnvironmentCondition.normal:
        return 'Normal';
      case EnvironmentCondition.hot:
        return 'Panas';
      case EnvironmentCondition.humid:
        return 'Lembab';
      case EnvironmentCondition.hotHumid:
        return 'Panas & Lembab';
    }
  }

  /// Generate rekomendasi berdasarkan kondisi
  AIRecommendation generateRecommendation(
    double temperature,
    double humidity,
    DateTime currentTime,
  ) {
    final condition = classifyEnvironment(temperature, humidity);

    switch (condition) {
      case EnvironmentCondition.comfortable:
        return AIRecommendation(
          title: '✨ Kondisi Nyaman',
          description:
              'Suhu dan kelembaban dalam kondisi ideal. Lingkungan sangat nyaman.',
          actions: [
            'Pertahankan kondisi saat ini',
            'Tidak perlu penyesuaian',
          ],
          condition: condition,
        );

      case EnvironmentCondition.normal:
        return AIRecommendation(
          title: '👍 Kondisi Normal',
          description:
              'Kondisi lingkungan cukup baik dan masih dalam batas toleransi.',
          actions: [
            'Monitor perubahan suhu dan kelembaban',
            'Siap melakukan penyesuaian jika diperlukan',
          ],
          condition: condition,
        );

      case EnvironmentCondition.hot:
        return AIRecommendation(
          title: '🔥 Kondisi Panas',
          description:
              'Suhu terlalu tinggi (${temperature.toStringAsFixed(1)}°C). Perlu pendinginan.',
          actions: [
            'Nyalakan kipas untuk sirkulasi udara',
            'Pastikan ventilasi terbuka',
            'Hindari aktivitas berat',
          ],
          condition: condition,
        );

      case EnvironmentCondition.humid:
        return AIRecommendation(
          title: '💧 Kondisi Lembab',
          description:
              'Kelembaban tinggi (${humidity.toStringAsFixed(1)}%). Udara terasa lembab.',
          actions: [
            'Aktifkan kipas untuk mengurangi kelembaban',
            'Buka jendela untuk ventilasi',
            'Gunakan dehumidifier jika tersedia',
          ],
          condition: condition,
        );

      case EnvironmentCondition.hotHumid:
        return AIRecommendation(
          title: '🔥💧 Panas & Lembab',
          description:
              'Suhu tinggi (${temperature.toStringAsFixed(1)}°C) dan kelembaban tinggi (${humidity.toStringAsFixed(1)}%). Kondisi tidak nyaman.',
          actions: [
            'SEGERA nyalakan kipas maksimal',
            'Buka semua ventilasi',
            'Kurangi sumber panas',
            'Pertimbangkan menggunakan AC',
          ],
          condition: condition,
        );
    }
  }

  /// Check apakah saat ini gelap (untuk kontrol lampu)
  bool isDarkTime(DateTime currentTime) {
    final hour = currentTime.hour;
    return hour >= DARK_HOUR_START || hour < DARK_HOUR_END;
  }

  /// Generate keputusan auto control berdasarkan kondisi
  AutoControlDecision generateAutoControl(
    double temperature,
    double humidity,
    DateTime currentTime,
    Map<String, bool> currentDeviceStates,
  ) {
    final condition = classifyEnvironment(temperature, humidity);
    final isDark = isDarkTime(currentTime);

    Map<String, bool> actions = {};
    String reason = '';

    // Logika kontrol berdasarkan kondisi
    switch (condition) {
      case EnvironmentCondition.comfortable:
        // Kondisi nyaman: matikan kipas, kontrol lampu berdasarkan waktu
        actions['fan_floor1'] = false;
        actions['led_floor1'] = isDark;
        actions['led1_floor2'] = isDark;
        actions['led2_floor2'] = isDark;
        reason =
            'Kondisi nyaman. Kipas dimatikan, lampu disesuaikan dengan waktu.';
        break;

      case EnvironmentCondition.normal:
        // Kondisi normal: pertahankan kipas mati, kontrol lampu
        actions['fan_floor1'] = false;
        actions['led_floor1'] = isDark;
        actions['led1_floor2'] = isDark;
        actions['led2_floor2'] = isDark;
        reason =
            'Kondisi normal. Kipas tetap mati, lampu disesuaikan dengan waktu.';
        break;

      case EnvironmentCondition.hot:
        // Panas: nyalakan kipas, kontrol lampu
        actions['fan_floor1'] = true;
        actions['led_floor1'] = isDark;
        actions['led1_floor2'] = isDark;
        actions['led2_floor2'] = isDark;
        reason = 'Suhu tinggi! Kipas dinyalakan untuk pendinginan.';
        break;

      case EnvironmentCondition.humid:
        // Lembab: nyalakan kipas untuk sirkulasi
        actions['fan_floor1'] = true;
        actions['led_floor1'] = isDark;
        actions['led1_floor2'] = isDark;
        actions['led2_floor2'] = isDark;
        reason = 'Kelembaban tinggi! Kipas dinyalakan untuk sirkulasi udara.';
        break;

      case EnvironmentCondition.hotHumid:
        // Panas & Lembab: nyalakan semua kipas
        actions['fan_floor1'] = true;
        actions['led_floor1'] = isDark;
        actions['led1_floor2'] = isDark;
        actions['led2_floor2'] = isDark;
        reason = 'Kondisi panas dan lembab! Kipas dinyalakan maksimal.';
        break;
    }

    return AutoControlDecision(
      deviceActions: actions,
      reason: reason,
    );
  }

  /// Get emoji untuk kondisi
  String getConditionEmoji(EnvironmentCondition condition) {
    switch (condition) {
      case EnvironmentCondition.comfortable:
        return '✨';
      case EnvironmentCondition.normal:
        return '👍';
      case EnvironmentCondition.hot:
        return '🔥';
      case EnvironmentCondition.humid:
        return '💧';
      case EnvironmentCondition.hotHumid:
        return '🔥💧';
    }
  }

  /// Get warna untuk kondisi
  int getConditionColor(EnvironmentCondition condition) {
    switch (condition) {
      case EnvironmentCondition.comfortable:
        return 0xFF4CAF50; // Green
      case EnvironmentCondition.normal:
        return 0xFF2196F3; // Blue
      case EnvironmentCondition.hot:
        return 0xFFFF5722; // Deep Orange
      case EnvironmentCondition.humid:
        return 0xFF00BCD4; // Cyan
      case EnvironmentCondition.hotHumid:
        return 0xFFF44336; // Red
    }
  }
}
