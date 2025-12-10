import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
// ganti dengan path projectmu jika Anda punya implementasi nyata:
// import 'package:your_project/mqtt/mqtt_service.dart';   // ganti dengan path projectmu

// Minimal local stub for MqttService used by this example.
// Replace this stub with your real mqtt_service implementation.
class MqttService {
  void Function(String topic, String msg)? onMessage;

  Future<void> connect() async {
    // Implement real connection logic here.
    // This stub just waits briefly to simulate async startup.
    await Future.delayed(const Duration(milliseconds: 100));
  }

  // Optional helper to simulate incoming messages during development.
  void simulateIncoming(String topic, String msg) {
    if (onMessage != null) onMessage!(topic, msg);
  }
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Home Monitoring',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const MonitoringScreen(),
    );
  }
}

class SensorData {
  final double value;
  final DateTime timestamp;
  final bool isOnline;

  SensorData(this.value, this.timestamp, this.isOnline);
}

class DeviceState {
  final bool isOn;
  final bool isOnline;
  final DateTime lastUpdate;
  final String? errorMessage;

  DeviceState({
    required this.isOn,
    required this.isOnline,
    required this.lastUpdate,
    this.errorMessage,
  });
}

class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({super.key});

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> with TickerProviderStateMixin {
  final List<double> temperatureHistory = [25.5];
  final List<double> humidityHistory = [60.0];
  
  late SensorData temperature;
  late SensorData humidity;
  DateTime lastSync = DateTime.now();
  
  Map<String, DeviceState> devices = {
    'lamp_living': DeviceState(isOn: false, isOnline: true, lastUpdate: DateTime.now()),
    'fan_bedroom': DeviceState(isOn: false, isOnline: true, lastUpdate: DateTime.now()),
    'lamp_bedroom': DeviceState(isOn: false, isOnline: true, lastUpdate: DateTime.now()),
    'ac_living': DeviceState(isOn: false, isOnline: false, lastUpdate: DateTime.now()),
    'lamp_bathroom': DeviceState(isOn: false, isOnline: true, lastUpdate: DateTime.now()),
    'exhaust_bathroom': DeviceState(isOn: false, isOnline: true, lastUpdate: DateTime.now()),
    'lamp_kitchen': DeviceState(isOn: false, isOnline: true, lastUpdate: DateTime.now()),
    'hood_kitchen': DeviceState(isOn: false, isOnline: true, lastUpdate: DateTime.now()),
    'tv_living': DeviceState(isOn: false, isOnline: true, lastUpdate: DateTime.now()),
    'curtain_living': DeviceState(isOn: false, isOnline: true, lastUpdate: DateTime.now()),
  };
  
  Timer? _sensorTimer;
  Timer? _syncTimer;
  late AnimationController _pulseController;
  
  String selectedRoom = 'Semua';
  final List<String> rooms = ['Semua', 'Ruang Tamu', 'Kamar Tidur', 'Dapur', 'Kamar Mandi'];
  bool isAdaptiveMode = false;

  @override
  void initState() {
    super.initState();

  final mqtt = MqttService();

  mqtt.onMessage = (topic, msg) {
    print("MQTT → $topic : $msg");

    setState(() {
      // SENSOR
      if (topic == "home/sensors/temperature") {
        final value = double.tryParse(msg) ?? 0;
        temperature = SensorData(value, DateTime.now(), true);
        temperatureHistory.add(value);
      }

      if (topic == "home/sensors/humidity") {
        final value = double.tryParse(msg) ?? 0;
        humidity = SensorData(value, DateTime.now(), true);
        humidityHistory.add(value);
      }

      // STATUS PERANGKAT
      if (topic.startsWith("home/devices/")) {
        final device = topic.split("/").last;
        final isOn = msg == "1";

        if (devices.containsKey(device)) {
          devices[device] = DeviceState(
            isOn: isOn,
            isOnline: true,
            lastUpdate: DateTime.now(),
          );
        }
      }
    });
  };

  mqtt.connect();

    
    temperature = SensorData(25.5, DateTime.now(), true);
    humidity = SensorData(60.0, DateTime.now(), true);
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _sensorTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        final newTemp = Random().nextDouble() * 10 + 20;
        final newHumid = Random().nextDouble() * 30 + 50;
        
        temperature = SensorData(newTemp, DateTime.now(), Random().nextBool() || true);
        humidity = SensorData(newHumid, DateTime.now(), Random().nextBool() || true);
        
        temperatureHistory.add(newTemp);
        humidityHistory.add(newHumid);
        
        if (temperatureHistory.length > 20) temperatureHistory.removeAt(0);
        if (humidityHistory.length > 20) humidityHistory.removeAt(0);
        
        lastSync = DateTime.now();
      });
    });

    _syncTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      setState(() {
        devices['ac_living'] = DeviceState(
          isOn: devices['ac_living']!.isOn,
          isOnline: Random().nextBool(),
          lastUpdate: DateTime.now(),
        );
      });
    });
  }

  @override
  void dispose() {
    _sensorTimer?.cancel();
    _syncTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void toggleDevice(String deviceId, bool value) async {
    if (!devices.containsKey(deviceId)) return;
    
    setState(() {
      final currentDevice = devices[deviceId];
      if (currentDevice != null) {
        devices[deviceId] = DeviceState(
          isOn: value,
          isOnline: currentDevice.isOnline,
          lastUpdate: DateTime.now(),
        );
        if (value) {
          // Simulate sending MQTT command to turn on the device
          print("MQTT ← home/devices/$deviceId : on");
        } else {
          // Simulate sending MQTT command to turn off the device
          print("MQTT ← home/devices/$deviceId : off");
        }
      }
    });
    
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Perintah terkirim: ${value ? "Nyalakan" : "Matikan"} perangkat'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void allOff() {
    setState(() {
      devices.forEach((key, value) {
        if (value.isOnline) {
          devices[key] = DeviceState(
            isOn: false,
            isOnline: value.isOnline,
            lastUpdate: DateTime.now(),
          );
        }
      });
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Semua perangkat dimatikan'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
      ),
    );
  }

  String getTrendIcon(List<double> history) {
    if (history.length < 2) return '→';
    final recent = history.sublist(history.length - 3);
    final avg = recent.reduce((a, b) => a + b) / recent.length;
    if (recent.last > avg + 0.5) return '↑';
    if (recent.last < avg - 0.5) return '↓';
    return '→';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3C72),
              Color(0xFF2A5298),
              Color(0xFF7E8BA3),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Smart Home',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Monitoring System',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.75),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: Colors.greenAccent,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.greenAccent,
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'Online',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Sync ${lastSync.hour.toString().padLeft(2, '0')}:${lastSync.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white.withOpacity(0.65),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Sensor Cards
                  Row(
                    children: [
                      Expanded(
                        child: ModernSensorCard(
                          title: 'Suhu',
                          value: temperature.value.toStringAsFixed(1),
                          unit: '°C',
                          gradientColors: const [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                          pulseController: _pulseController,
                          isOnline: temperature.isOnline,
                          lastUpdate: temperature.timestamp,
                          trendIcon: getTrendIcon(temperatureHistory),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ModernSensorCard(
                          title: 'Kelembaban',
                          value: humidity.value.toStringAsFixed(0),
                          unit: '%',
                          gradientColors: const [Color(0xFF4E65FF), Color(0xFF92EFFD)],
                          pulseController: _pulseController,
                          isOnline: humidity.isOnline,
                          lastUpdate: humidity.timestamp,
                          trendIcon: getTrendIcon(humidityHistory),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Quick Actions
                  Row(
                    children: [
                      Expanded(
                        child: QuickActionButton(
                          icon: Icons.power_settings_new_rounded,
                          label: 'All Off',
                          onTap: allOff,
                          isActive: false,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: QuickActionButton(
                          icon: Icons.auto_awesome_rounded,
                          label: isAdaptiveMode ? 'Adaptive ON' : 'Mode Adaptif',
                          isActive: isAdaptiveMode,
                          onTap: () {
                            setState(() {
                              isAdaptiveMode = !isAdaptiveMode;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isAdaptiveMode 
                                    ? 'Mode adaptif diaktifkan - Sistem akan menyesuaikan otomatis' 
                                    : 'Mode adaptif dinonaktifkan'
                                ),
                                behavior: SnackBarBehavior.floating,
                                margin: const EdgeInsets.all(16),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Room Filter Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Kontrol Perangkat',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                            width: 1,
                          ),
                        ),
                        child: DropdownButton<String>(
                          value: selectedRoom,
                          dropdownColor: const Color(0xFF2A5298),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          underline: Container(),
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          isDense: true,
                          items: rooms.map((room) {
                            return DropdownMenuItem(value: room, child: Text(room));
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedRoom = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Device Cards - Ruang Tamu
                  if (selectedRoom == 'Semua' || selectedRoom == 'Ruang Tamu') ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 10),
                      child: Text(
                        'Ruang Tamu',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.7),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    ModernControlCard(
                      title: 'Lampu',
                      subtitle: 'LED Strip RGB',
                      isOn: devices['lamp_living']?.isOn ?? false,
                      isOnline: devices['lamp_living']?.isOnline ?? false,
                      lastUpdate: devices['lamp_living']?.lastUpdate ?? DateTime.now(),
                      onToggle: (value) => toggleDevice('lamp_living', value),
                      activeColor: const Color(0xFFFFA726),
                      icon: '💡',
                    ),
                    const SizedBox(height: 10),
                    ModernControlCard(
                      title: 'AC',
                      subtitle: 'Smart AC 1.5 PK',
                      isOn: devices['ac_living']?.isOn ?? false,
                      isOnline: devices['ac_living']?.isOnline ?? false,
                      lastUpdate: devices['ac_living']?.lastUpdate ?? DateTime.now(),
                      onToggle: (value) => toggleDevice('ac_living', value),
                      activeColor: const Color(0xFF66BB6A),
                      icon: '❄️',
                    ),
                    const SizedBox(height: 10),
                    ModernControlCard(
                      title: 'Smart TV',
                      subtitle: '55" 4K Android TV',
                      isOn: devices['tv_living']?.isOn ?? false,
                      isOnline: devices['tv_living']?.isOnline ?? false,
                      lastUpdate: devices['tv_living']?.lastUpdate ?? DateTime.now(),
                      onToggle: (value) => toggleDevice('tv_living', value),
                      activeColor: const Color(0xFF7E57C2),
                      icon: '📺',
                    ),
                    const SizedBox(height: 10),
                    ModernControlCard(
                      title: 'Smart Curtain',
                      subtitle: 'Motorized',
                      isOn: devices['curtain_living']?.isOn ?? false,
                      isOnline: devices['curtain_living']?.isOnline ?? false,
                      lastUpdate: devices['curtain_living']?.lastUpdate ?? DateTime.now(),
                      onToggle: (value) => toggleDevice('curtain_living', value),
                      activeColor: const Color(0xFFEC407A),
                      icon: '🪟',
                    ),
                    const SizedBox(height: 20),
                  ],
                  
                  // Device Cards - Kamar Tidur
                  if (selectedRoom == 'Semua' || selectedRoom == 'Kamar Tidur') ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 10),
                      child: Text(
                        'Kamar Tidur',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.7),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    ModernControlCard(
                      title: 'Kipas Angin',
                      subtitle: 'Smart Fan',
                      isOn: devices['fan_bedroom']?.isOn ?? false,
                      isOnline: devices['fan_bedroom']?.isOnline ?? false,
                      lastUpdate: devices['fan_bedroom']?.lastUpdate ?? DateTime.now(),
                      onToggle: (value) => toggleDevice('fan_bedroom', value),
                      activeColor: const Color(0xFF42A5F5),
                      icon: '🌀',
                    ),
                    const SizedBox(height: 10),
                    ModernControlCard(
                      title: 'Lampu Tidur',
                      subtitle: 'Dimmable',
                      isOn: devices['lamp_bedroom']?.isOn ?? false,
                      isOnline: devices['lamp_bedroom']?.isOnline ?? false,
                      lastUpdate: devices['lamp_bedroom']?.lastUpdate ?? DateTime.now(),
                      onToggle: (value) => toggleDevice('lamp_bedroom', value),
                      activeColor: const Color(0xFFFFB74D),
                      icon: '🛋️',
                    ),
                    const SizedBox(height: 20),
                  ],
                  
                  // Device Cards - Kamar Mandi
                  if (selectedRoom == 'Semua' || selectedRoom == 'Kamar Mandi') ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 10),
                      child: Text(
                        'Kamar Mandi',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.7),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    ModernControlCard(
                      title: 'Lampu',
                      subtitle: 'LED Waterproof',
                      isOn: devices['lamp_bathroom']?.isOn ?? false,
                      isOnline: devices['lamp_bathroom']?.isOnline ?? false,
                      lastUpdate: devices['lamp_bathroom']?.lastUpdate ?? DateTime.now(),
                      onToggle: (value) => toggleDevice('lamp_bathroom', value),
                      activeColor: const Color(0xFF26C6DA),
                      icon: '💡',
                    ),
                    const SizedBox(height: 10),
                    ModernControlCard(
                      title: 'Exhaust Fan',
                      subtitle: 'Ventilasi Otomatis',
                      isOn: devices['exhaust_bathroom']?.isOn ?? false,
                      isOnline: devices['exhaust_bathroom']?.isOnline ?? false,
                      lastUpdate: devices['exhaust_bathroom']?.lastUpdate ?? DateTime.now(),
                      onToggle: (value) => toggleDevice('exhaust_bathroom', value),
                      activeColor: const Color(0xFF78909C),
                      icon: '💨',
                    ),
                    const SizedBox(height: 20),
                  ],
                  
                  // Device Cards - Dapur
                  if (selectedRoom == 'Semua' || selectedRoom == 'Dapur') ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 10),
                      child: Text(
                        'Dapur',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.7),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    ModernControlCard(
                      title: 'Lampu Dapur',
                      subtitle: 'LED Panel',
                      isOn: devices['lamp_kitchen']?.isOn ?? false,
                      isOnline: devices['lamp_kitchen']?.isOnline ?? false,
                      lastUpdate: devices['lamp_kitchen']?.lastUpdate ?? DateTime.now(),
                      onToggle: (value) => toggleDevice('lamp_kitchen', value),
                      activeColor: const Color(0xFFFFCA28),
                      icon: '💡',
                    ),
                    const SizedBox(height: 10),
                    ModernControlCard(
                      title: 'Cooker Hood',
                      subtitle: 'Smart Exhaust',
                      isOn: devices['hood_kitchen']?.isOn ?? false,
                      isOnline: devices['hood_kitchen']?.isOnline ?? false,
                      lastUpdate: devices['hood_kitchen']?.lastUpdate ?? DateTime.now(),
                      onToggle: (value) => toggleDevice('hood_kitchen', value),
                      activeColor: const Color(0xFF8D6E63),
                      icon: '🔥',
                    ),
                    const SizedBox(height: 20),
                  ],
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ModernSensorCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final List<Color> gradientColors;
  final AnimationController pulseController;
  final bool isOnline;
  final DateTime lastUpdate;
  final String trendIcon;

  const ModernSensorCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.gradientColors,
    required this.pulseController,
    required this.isOnline,
    required this.lastUpdate,
    required this.trendIcon,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final diff = now.difference(lastUpdate).inSeconds;
    
    return AnimatedBuilder(
      animation: pulseController,
      builder: (context, child) {
        final scale = 1.0 + (pulseController.value * 0.015);
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.95),
                      letterSpacing: 0.3,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: isOnline ? Colors.greenAccent : Colors.redAccent,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: isOnline ? Colors.greenAccent : Colors.redAccent,
                                blurRadius: 3,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isOnline ? 'Online' : 'Offline',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        unit,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      Text(
                        trendIcon,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Text(
                'Update: ${diff}s lalu',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.75),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ModernControlCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isOn;
  final bool isOnline;
  final DateTime lastUpdate;
  final Function(bool) onToggle;
  final Color activeColor;
  final String icon;

  const ModernControlCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isOn,
    required this.isOnline,
    required this.lastUpdate,
    required this.onToggle,
    required this.activeColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: isOn 
            ? activeColor.withOpacity(0.12) 
            : Colors.white.withOpacity(0.98),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOn 
              ? activeColor.withOpacity(0.3) 
              : Colors.grey.withOpacity(0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isOn 
                ? activeColor.withOpacity(0.15) 
                : Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isOn 
                    ? activeColor.withOpacity(0.18) 
                    : const Color(0xFFF5F7FA),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isOn 
                      ? activeColor.withOpacity(0.2) 
                      : Colors.grey.withOpacity(0.1),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: isOn ? activeColor.darken(0.1) : const Color(0xFF2C3E50),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isOnline 
                              ? Colors.green.withOpacity(0.12) 
                              : Colors.red.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isOnline ? 'Online' : 'Offline',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: isOnline ? Colors.green[700] : Colors.red[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isOn 
                              ? activeColor.withOpacity(0.15) 
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isOn ? 'ON' : 'OFF',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isOn ? activeColor.darken(0.2) : Colors.grey[600],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${DateTime.now().difference(lastUpdate).inSeconds}s ago',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Transform.scale(
              scale: 0.9,
              child: Switch(
                value: isOn,
                onChanged: isOnline ? onToggle : null,
                activeThumbColor: activeColor,
                activeTrackColor: activeColor.withOpacity(0.4),
                inactiveThumbColor: Colors.grey[400],
                inactiveTrackColor: Colors.grey[300],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: isActive 
              ? Colors.white.withOpacity(0.25)
              : Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive 
                ? Colors.white.withOpacity(0.4)
                : Colors.white.withOpacity(0.2),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon, 
              color: Colors.white, 
              size: 19,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                  letterSpacing: 0.3,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Extension helper untuk darken color//
extension ColorExtension on Color {
  Color darken(double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final darkened = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return darkened.toColor();
  }
}