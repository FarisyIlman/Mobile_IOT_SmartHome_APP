# 🤖 Fitur AI Smart Home

## 📋 Overview
Aplikasi Smart Home ini dilengkapi dengan sistem AI (Artificial Intelligence) yang dapat:
1. **Mengklasifikasikan kondisi lingkungan** secara real-time
2. **Memberikan rekomendasi** berdasarkan kondisi
3. **Auto Control** - AI secara otomatis mengontrol perangkat

---

## 🎯 Klasifikasi Kondisi Lingkungan

AI akan menganalisis suhu dan kelembaban untuk mengklasifikasikan kondisi ke dalam 5 kategori:

### 1. ✨ **Nyaman (Comfortable)**
- **Kondisi:** Suhu 22-26°C & Kelembaban 40-60%
- **Status:** Kondisi ideal dan nyaman
- **Rekomendasi:** Pertahankan kondisi saat ini

### 2. 👍 **Normal**
- **Kondisi:** Di luar range nyaman tapi masih toleransi
- **Status:** Kondisi cukup baik
- **Rekomendasi:** Monitor perubahan

### 3. 🔥 **Panas (Hot)**
- **Kondisi:** Suhu > 28°C
- **Status:** Suhu terlalu tinggi
- **Rekomendasi:** 
  - Nyalakan kipas
  - Buka ventilasi
  - Hindari aktivitas berat

### 4. 💧 **Lembab (Humid)**
- **Kondisi:** Kelembaban > 70%
- **Status:** Kelembaban tinggi
- **Rekomendasi:**
  - Aktifkan kipas untuk sirkulasi
  - Buka jendela
  - Gunakan dehumidifier

### 5. 🔥💧 **Panas & Lembab (Hot & Humid)**
- **Kondisi:** Suhu > 28°C DAN Kelembaban > 70%
- **Status:** Kondisi sangat tidak nyaman
- **Rekomendasi:**
  - SEGERA nyalakan kipas maksimal
  - Buka semua ventilasi
  - Pertimbangkan AC

---

## 🎮 Auto Control

Fitur Auto Control memungkinkan AI mengontrol perangkat secara otomatis berdasarkan kondisi lingkungan.

### Cara Kerja:
1. **Aktifkan Auto Control** dengan menekan tombol di UI
2. AI akan **menganalisis** kondisi setiap 30 detik
3. AI akan **membuat keputusan** berdasarkan:
   - Suhu dan kelembaban saat ini
   - Kondisi lingkungan yang terklasifikasi
   - Waktu (siang/malam) untuk kontrol lampu
4. AI akan **mengeksekusi** perintah ke perangkat

### Logika Auto Control:

#### 🌡️ **Kontrol Kipas**
- **Nyaman/Normal:** Kipas OFF
- **Panas:** Kipas ON (untuk pendinginan)
- **Lembab:** Kipas ON (untuk sirkulasi)
- **Panas & Lembab:** Kipas ON maksimal

#### 💡 **Kontrol Lampu**
- **Gelap (18:00 - 06:00):** Lampu ON
- **Terang (06:00 - 18:00):** Lampu OFF
- Berlaku untuk semua lampu (Lantai 1, LED 1 & 2 Lantai 2)

### Contoh Skenario:

**Skenario 1: Siang Hari, Panas**
```
Kondisi: 30°C, 55%, 14:00
AI Decision:
  ✅ Kipas: ON (karena panas)
  ❌ Lampu: OFF (karena siang)
Alasan: "Suhu tinggi! Kipas dinyalakan untuk pendinginan."
```

**Skenario 2: Malam Hari, Lembab**
```
Kondisi: 26°C, 75%, 20:00
AI Decision:
  ✅ Kipas: ON (sirkulasi udara)
  ✅ Lampu: ON (karena malam)
Alasan: "Kelembaban tinggi! Kipas dinyalakan untuk sirkulasi udara."
```

**Skenario 3: Pagi Hari, Nyaman**
```
Kondisi: 24°C, 50%, 08:00
AI Decision:
  ❌ Kipas: OFF
  ❌ Lampu: OFF
Alasan: "Kondisi nyaman. Kipas dimatikan, lampu disesuaikan dengan waktu."
```

---

## 🎨 UI Components

### 1. **AI Status Card**
Menampilkan:
- Emoji kondisi (✨🔥💧👍)
- Judul kondisi dengan warna
- Deskripsi detail
- Daftar rekomendasi

### 2. **Auto Control Button**
- **OFF State:** Abu-abu, ikon outline
- **ON State:** Hijau gradient, ikon solid, animasi
- Menampilkan status dan deskripsi

---

## ⚙️ Konfigurasi AI

File: `lib/ai_service.dart`

### Threshold yang Dapat Disesuaikan:

```dart
// Suhu
static const double TEMP_COMFORTABLE_MIN = 22.0;
static const double TEMP_COMFORTABLE_MAX = 26.0;
static const double TEMP_HOT_THRESHOLD = 28.0;

// Kelembaban
static const double HUMIDITY_COMFORTABLE_MIN = 40.0;
static const double HUMIDITY_COMFORTABLE_MAX = 60.0;
static const double HUMIDITY_HIGH_THRESHOLD = 70.0;

// Waktu gelap
static const int DARK_HOUR_START = 18; // 6 PM
static const int DARK_HOUR_END = 6;    // 6 AM
```

### Interval Auto Control:
```dart
// Di main.dart
Timer.periodic(const Duration(seconds: 30), ...);
```

---

## 🔧 API & Methods

### AIService Class

#### 1. **classifyEnvironment**
```dart
EnvironmentCondition classifyEnvironment(double temperature, double humidity)
```
Mengklasifikasikan kondisi berdasarkan suhu dan kelembaban.

#### 2. **generateRecommendation**
```dart
AIRecommendation generateRecommendation(
  double temperature, 
  double humidity,
  DateTime currentTime,
)
```
Generate rekomendasi lengkap dengan actions.

#### 3. **generateAutoControl**
```dart
AutoControlDecision generateAutoControl(
  double temperature,
  double humidity,
  DateTime currentTime,
  Map<String, bool> currentDeviceStates,
)
```
Generate keputusan auto control dengan device actions dan alasan.

#### 4. **isDarkTime**
```dart
bool isDarkTime(DateTime currentTime)
```
Check apakah saat ini waktu gelap (untuk kontrol lampu).

---

## 📱 Cara Menggunakan

### 1. **Melihat Status AI**
- Status AI akan otomatis muncul di bawah sensor cards
- Menampilkan kondisi real-time dengan emoji dan warna
- Rekomendasi akan update setiap detik

### 2. **Mengaktifkan Auto Control**
1. Tekan tombol **"Auto Control"** (warna abu-abu)
2. Tombol akan berubah hijau: **"🤖 Auto Control AKTIF"**
3. Notifikasi akan muncul: "Auto Control diaktifkan"
4. AI akan langsung mengeksekusi kontrol pertama
5. Setiap 30 detik AI akan evaluasi dan adjust perangkat

### 3. **Menonaktifkan Auto Control**
1. Tekan tombol **"🤖 Auto Control AKTIF"** (warna hijau)
2. Tombol akan kembali abu-abu
3. Notifikasi: "Auto Control dinonaktifkan"
4. Kontrol manual kembali aktif

---

## 🎯 Testing Scenarios

### Test Case 1: Kondisi Panas
```
Input: Temperature = 30°C, Humidity = 55%
Expected:
  - Kondisi: 🔥 Panas
  - Rekomendasi: Nyalakan kipas
  - Auto Control: Kipas ON
```

### Test Case 2: Kondisi Lembab
```
Input: Temperature = 25°C, Humidity = 75%
Expected:
  - Kondisi: 💧 Lembab
  - Rekomendasi: Aktifkan kipas untuk sirkulasi
  - Auto Control: Kipas ON
```

### Test Case 3: Panas & Lembab
```
Input: Temperature = 32°C, Humidity = 80%
Expected:
  - Kondisi: 🔥💧 Panas & Lembab
  - Rekomendasi: SEGERA nyalakan kipas maksimal
  - Auto Control: Kipas ON + Lampu (sesuai waktu)
```

### Test Case 4: Kontrol Lampu
```
Test 4a - Siang:
  Time: 14:00
  Expected: Semua lampu OFF

Test 4b - Malam:
  Time: 20:00
  Expected: Semua lampu ON
```

---

## 🚀 Future Improvements

Fitur yang bisa ditambahkan:
1. **Machine Learning Integration** - Prediksi pola penggunaan
2. **Voice Control** - Kontrol suara dengan AI
3. **Custom Schedules** - Jadwal otomatis per ruangan
4. **Energy Saving Mode** - Optimasi konsumsi listrik
5. **Smart Scenes** - Preset kondisi (Movie, Sleep, Party, dll)
6. **Weather Integration** - Prediksi cuaca untuk kontrol preventif
7. **User Preferences** - Belajar preferensi pengguna
8. **Multi-Zone Control** - Kontrol terpisah per zona/ruangan

---

## 📞 Support

Jika ada pertanyaan atau issue:
1. Check dokumentasi ini
2. Review code di `lib/ai_service.dart`
3. Test dengan berbagai kondisi suhu & kelembaban
4. Adjust threshold sesuai kebutuhan

---

**Created with ❤️ for Smart Home IoT Project**
