class AIClassifier {
  // Klasifikasi kondisi ruangan berdasarkan suhu dan kelembapan
  Map<String, dynamic> classifyRoom(double suhu, double kelembapan) {
    String kondisi;
    String emoji;
    String rekomendasi;
    bool autoKipas = false;
    bool autoLampu = false;
    double confidence;

    // AI Logic - Rule-based Classification
    if (suhu > 28) {
      kondisi = 'Panas';
      emoji = '🔴';
      rekomendasi = 'Ruangan terlalu panas. Nyalakan kipas atau AC';
      autoKipas = true;
      autoLampu = false;
      confidence = _calculateConfidence(suhu, 28, 35);
    } 
    else if (suhu < 20) {
      kondisi = 'Dingin';
      emoji = '🔵';
      rekomendasi = 'Ruangan terlalu dingin. Matikan kipas/AC';
      autoKipas = false;
      autoLampu = true;
      confidence = _calculateConfidence(suhu, 20, 15);
    } 
    else if (kelembapan > 70) {
      kondisi = 'Lembap';
      emoji = '💧';
      rekomendasi = 'Kelembapan tinggi. Nyalakan kipas untuk sirkulasi';
      autoKipas = true;
      autoLampu = false;
      confidence = _calculateConfidence(kelembapan, 70, 90);
    } 
    else if (suhu >= 20 && suhu <= 26 && kelembapan >= 40 && kelembapan <= 60) {
      kondisi = 'Nyaman';
      emoji = '🟢';
      rekomendasi = 'Kondisi ruangan ideal';
      autoKipas = false;
      autoLampu = false;
      confidence = 0.95;
    } 
    else {
      kondisi = 'Normal';
      emoji = '🟡';
      rekomendasi = 'Kondisi ruangan cukup baik';
      autoKipas = false;
      autoLampu = false;
      confidence = 0.80;
    }

    return {
      'kondisi': kondisi,
      'emoji': emoji,
      'rekomendasi': rekomendasi,
      'autoKipas': autoKipas,
      'autoLampu': autoLampu,
      'confidence': confidence,
      'suhu': suhu,
      'kelembapan': kelembapan,
      'timestamp': DateTime.now(),
    };
  }

  // Hitung confidence score (0.0 - 1.0)
  double _calculateConfidence(double value, double threshold, double max) {
    double distance = (value - threshold).abs();
    double range = (max - threshold).abs();
    double confidence = 0.7 + (distance / range * 0.3);
    return confidence.clamp(0.7, 1.0);
  }

  // Prediksi trend suhu (naik/turun/stabil)
  String predictTrend(List<double> history) {
    if (history.length < 3) return 'Belum cukup data';
    
    double avg1 = (history[0] + history[1]) / 2;
    double avg2 = (history[history.length - 2] + history.last) / 2;
    
    if (avg2 > avg1 + 1) return 'Trend Naik 📈';
    if (avg2 < avg1 - 1) return 'Trend Turun 📉';
    return 'Trend Stabil ➡️';
  }

  // Rekomendasi aksi berdasarkan klasifikasi
  Map<String, bool?> getAutoActions(String kondisi) {
    switch (kondisi) {
      case 'Panas':
        return {'kipas': true, 'lampu': false};
      case 'Lembap':
        return {'kipas': true, 'lampu': null};
      case 'Dingin':
        return {'kipas': false, 'lampu': true};
      case 'Nyaman':
      default:
        return {'kipas': null, 'lampu': null};
    }
  }

  // ✅ FITUR BARU: Execute auto control commands
  Map<String, String> getAutoControlCommands(Map<String, dynamic> aiResult) {
    Map<String, String> commands = {};
    
    if (aiResult['autoKipas'] == true) {
      commands['kipas'] = 'ON';
    } else if (aiResult['autoKipas'] == false) {
      commands['kipas'] = 'OFF';
    }
    
    if (aiResult['autoLampu'] == true) {
      commands['lampu'] = 'ON';
    } else if (aiResult['autoLampu'] == false) {
      commands['lampu'] = 'OFF';
    }
    
    return commands;
  }

  // ✅ FITUR BARU: Cek apakah perlu emergency action
  bool needsEmergencyAction(double suhu, double kelembapan) {
    return suhu > 35 || suhu < 15 || kelembapan > 90;
  }

  // ✅ FITUR BARU: Get emergency message
  String getEmergencyMessage(double suhu, double kelembapan) {
    if (suhu > 35) {
      return '🚨 BAHAYA! Suhu sangat tinggi! Segera nyalakan AC!';
    }
    if (suhu < 15) {
      return '🚨 BAHAYA! Suhu sangat rendah! Segera matikan AC!';
    }
    if (kelembapan > 90) {
      return '🚨 BAHAYA! Kelembapan ekstrem! Risiko jamur tinggi!';
    }
    return '';
  }

  // Analisis detail kondisi ruangan
  Map<String, dynamic> getDetailedAnalysis(double suhu, double kelembapan) {
    var classification = classifyRoom(suhu, kelembapan);
    var actions = getAutoActions(classification['kondisi']);
    
    return {
      ...classification,
      'actions': actions,
      'isCritical': suhu > 32 || suhu < 18 || kelembapan > 85,
      'comfortScore': _calculateComfortScore(suhu, kelembapan),
    };
  }

  // Skor kenyamanan (0-100)
  int _calculateComfortScore(double suhu, double kelembapan) {
    int score = 100;
    
    // Penalti untuk suhu di luar range ideal
    if (suhu < 20 || suhu > 26) {
      double deviation = (suhu - 23).abs();
      score -= (deviation * 5).toInt();
    }
    
    // Penalti untuk kelembapan di luar range ideal
    if (kelembapan < 40 || kelembapan > 60) {
      double deviation = (kelembapan - 50).abs();
      score -= (deviation / 2).toInt();
    }
    
    return score.clamp(0, 100);
  }
}
