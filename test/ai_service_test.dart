import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_2/ai_service.dart';

void main() {
  late AIService aiService;

  setUp(() {
    aiService = AIService();
  });

  group('AI Classification Tests', () {
    test('Kondisi Nyaman - Suhu dan kelembaban ideal', () {
      // Arrange
      final temperature = 24.0;
      final humidity = 50.0;

      // Act
      final condition = aiService.classifyEnvironment(temperature, humidity);

      // Assert
      expect(condition, EnvironmentCondition.comfortable);
      expect(aiService.getConditionLabel(condition), 'Nyaman');
    });

    test('Kondisi Panas - Suhu tinggi', () {
      // Arrange
      final temperature = 30.0;
      final humidity = 55.0;

      // Act
      final condition = aiService.classifyEnvironment(temperature, humidity);

      // Assert
      expect(condition, EnvironmentCondition.hot);
      expect(aiService.getConditionLabel(condition), 'Panas');
    });

    test('Kondisi Lembab - Kelembaban tinggi', () {
      // Arrange
      final temperature = 25.0;
      final humidity = 75.0;

      // Act
      final condition = aiService.classifyEnvironment(temperature, humidity);

      // Assert
      expect(condition, EnvironmentCondition.humid);
      expect(aiService.getConditionLabel(condition), 'Lembab');
    });

    test('Kondisi Panas & Lembab - Suhu dan kelembaban tinggi', () {
      // Arrange
      final temperature = 32.0;
      final humidity = 80.0;

      // Act
      final condition = aiService.classifyEnvironment(temperature, humidity);

      // Assert
      expect(condition, EnvironmentCondition.hotHumid);
      expect(aiService.getConditionLabel(condition), 'Panas & Lembab');
    });

    test('Kondisi Normal - Di luar range nyaman tapi tidak ekstrem', () {
      // Arrange
      final temperature = 20.0;
      final humidity = 65.0;

      // Act
      final condition = aiService.classifyEnvironment(temperature, humidity);

      // Assert
      expect(condition, EnvironmentCondition.normal);
      expect(aiService.getConditionLabel(condition), 'Normal');
    });
  });

  group('AI Recommendation Tests', () {
    test('Rekomendasi untuk kondisi panas', () {
      // Arrange
      final temperature = 30.0;
      final humidity = 55.0;
      final currentTime = DateTime(2025, 12, 10, 14, 0);

      // Act
      final recommendation = aiService.generateRecommendation(
        temperature,
        humidity,
        currentTime,
      );

      // Assert
      expect(recommendation.condition, EnvironmentCondition.hot);
      expect(recommendation.title, contains('Panas'));
      expect(recommendation.actions.length, greaterThan(0));
    });

    test('Rekomendasi untuk kondisi nyaman', () {
      // Arrange
      final temperature = 24.0;
      final humidity = 50.0;
      final currentTime = DateTime(2025, 12, 10, 14, 0);

      // Act
      final recommendation = aiService.generateRecommendation(
        temperature,
        humidity,
        currentTime,
      );

      // Assert
      expect(recommendation.condition, EnvironmentCondition.comfortable);
      expect(recommendation.title, contains('Nyaman'));
    });
  });

  group('Auto Control Logic Tests', () {
    test('Auto Control - Kondisi panas di siang hari', () {
      // Arrange
      final temperature = 30.0;
      final humidity = 55.0;
      final currentTime = DateTime(2025, 12, 10, 14, 0); // 2 PM (siang)
      final currentStates = {
        'lampu': false,
        'kipas': false,
      };

      // Act
      final decision = aiService.generateAutoControl(
        temperature,
        humidity,
        currentTime,
        currentStates,
      );

      // Assert
      expect(
          decision.deviceActions['kipas'], true); // Kipas ON karena panas
      expect(decision.deviceActions['lampu'],
          false); // Lampu OFF karena siang
      expect(decision.reason, contains('Suhu tinggi'));
    });

    test('Auto Control - Kondisi panas di malam hari', () {
      // Arrange
      final temperature = 30.0;
      final humidity = 55.0;
      final currentTime = DateTime(2025, 12, 10, 20, 0); // 8 PM (malam)
      final currentStates = {
        'lampu': false,
        'kipas': false,
      };

      // Act
      final decision = aiService.generateAutoControl(
        temperature,
        humidity,
        currentTime,
        currentStates,
      );

      // Assert
      expect(
          decision.deviceActions['kipas'], true); // Kipas ON karena panas
      expect(
          decision.deviceActions['lampu'], true); // Lampu ON karena malam
    });

    test('Auto Control - Kondisi nyaman di malam hari', () {
      // Arrange
      final temperature = 24.0;
      final humidity = 50.0;
      final currentTime = DateTime(2025, 12, 10, 20, 0); // 8 PM (malam)
      final currentStates = {
        'lampu': false,
        'kipas': false,
      };

      // Act
      final decision = aiService.generateAutoControl(
        temperature,
        humidity,
        currentTime,
        currentStates,
      );

      // Assert
      expect(decision.deviceActions['kipas'],
          false); // Kipas OFF karena nyaman
      expect(
          decision.deviceActions['lampu'], true); // Lampu ON karena malam
      expect(decision.reason, contains('nyaman'));
    });

    test('Auto Control - Kondisi lembab', () {
      // Arrange
      final temperature = 25.0;
      final humidity = 75.0;
      final currentTime = DateTime(2025, 12, 10, 14, 0);
      final currentStates = {
        'lampu': false,
        'kipas': false,
      };

      // Act
      final decision = aiService.generateAutoControl(
        temperature,
        humidity,
        currentTime,
        currentStates,
      );

      // Assert
      expect(decision.deviceActions['kipas'],
          true); // Kipas ON untuk sirkulasi
      expect(decision.reason, contains('Kelembaban tinggi'));
    });
  });

  group('Time Detection Tests', () {
    test('isDarkTime - Malam hari (20:00)', () {
      final time = DateTime(2025, 12, 10, 20, 0);
      expect(aiService.isDarkTime(time), true);
    });

    test('isDarkTime - Pagi buta (03:00)', () {
      final time = DateTime(2025, 12, 10, 3, 0);
      expect(aiService.isDarkTime(time), true);
    });

    test('isDarkTime - Siang hari (14:00)', () {
      final time = DateTime(2025, 12, 10, 14, 0);
      expect(aiService.isDarkTime(time), false);
    });

    test('isDarkTime - Pagi hari (08:00)', () {
      final time = DateTime(2025, 12, 10, 8, 0);
      expect(aiService.isDarkTime(time), false);
    });

    test('isDarkTime - Batas malam (18:00)', () {
      final time = DateTime(2025, 12, 10, 18, 0);
      expect(aiService.isDarkTime(time), true);
    });

    test('isDarkTime - Batas pagi (06:00)', () {
      final time = DateTime(2025, 12, 10, 6, 0);
      expect(aiService.isDarkTime(time), false);
    });
  });

  group('Edge Cases', () {
    test('Suhu pada batas threshold', () {
      // Exactly at hot threshold
      final condition1 = aiService.classifyEnvironment(28.0, 50.0);
      expect(condition1, EnvironmentCondition.normal); // <= 28, so normal

      // Just above hot threshold
      final condition2 = aiService.classifyEnvironment(28.1, 50.0);
      expect(condition2, EnvironmentCondition.hot);
    });

    test('Kelembaban pada batas threshold', () {
      // Exactly at humid threshold
      final condition1 = aiService.classifyEnvironment(24.0, 70.0);
      expect(condition1, EnvironmentCondition.normal); // <= 70, still in normal

      // Just above humid threshold
      final condition2 = aiService.classifyEnvironment(24.0, 70.1);
      expect(condition2, EnvironmentCondition.humid);
    });

    test('Nilai ekstrem', () {
      // Very high temperature and humidity
      final condition = aiService.classifyEnvironment(40.0, 90.0);
      expect(condition, EnvironmentCondition.hotHumid);
    });
  });
}
