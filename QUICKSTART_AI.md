# 🚀 Quick Start - Fitur AI Smart Home

## ✅ Apa yang Sudah Ditambahkan?

### 1. **File Baru**
- `lib/ai_service.dart` - Service AI untuk classification & auto control
- `test/ai_service_test.dart` - Unit tests (20 test cases)
- `AI_FEATURES.md` - Dokumentasi lengkap fitur AI

### 2. **Perubahan pada `lib/main.dart`**
- Import `ai_service.dart`
- Tambah state untuk AI (condition, recommendation, auto control)
- Method `_updateAIAnalysis()` - Update kondisi AI
- Method `toggleAutoControl()` - Toggle auto control
- Method `_executeAutoControl()` - Eksekusi auto control
- UI Widget `AIStatusCard` - Card status AI
- UI Widget `AutoControlButton` - Tombol auto control

---

## 🎯 Cara Menggunakan

### 1. **Jalankan Aplikasi**
```bash
flutter run
```

### 2. **Lihat Status AI**
- Di bawah sensor cards, akan muncul **AI Status Card**
- Menampilkan:
  - 🔥 Emoji kondisi
  - Warna sesuai kondisi (hijau/biru/orange/merah)
  - Judul kondisi (Nyaman, Panas, dll)
  - Deskripsi detail
  - Rekomendasi AI

### 3. **Aktifkan Auto Control**
- Scroll ke bawah, cari tombol **"Auto Control"**
- Tekan tombol (akan berubah hijau)
- Notifikasi: "🤖 Auto Control diaktifkan"
- AI akan langsung mengatur perangkat
- Setiap 30 detik AI akan re-evaluate

### 4. **Test dengan Skenario**

#### Skenario A: Panas (Siang)
1. Pastikan sensor suhu > 28°C
2. Aktifkan Auto Control
3. **Expected:** Kipas nyala, lampu mati
4. **Notif:** "Suhu tinggi! Kipas dinyalakan..."

#### Skenario B: Panas (Malam)
1. Pastikan sensor suhu > 28°C
2. Waktu >= 18:00 atau < 06:00
3. Aktifkan Auto Control
4. **Expected:** Kipas nyala, lampu nyala
5. **Notif:** "Suhu tinggi! Kipas dinyalakan..."

#### Skenario C: Lembab
1. Kelembaban > 70%
2. Aktifkan Auto Control
3. **Expected:** Kipas nyala untuk sirkulasi
4. **Notif:** "Kelembaban tinggi!..."

#### Skenario D: Nyaman
1. Suhu 22-26°C, Kelembaban 40-60%
2. Aktifkan Auto Control
3. **Expected:** Kipas mati, lampu sesuai waktu
4. **Notif:** "Kondisi nyaman..."

---

## 🧪 Run Tests

```bash
# Run all tests
flutter test

# Run AI tests only
flutter test test/ai_service_test.dart

# Run with coverage
flutter test --coverage
```

**Test Results:**
- ✅ 20 tests passed
- Classification: 5 tests
- Recommendation: 2 tests
- Auto Control: 4 tests
- Time Detection: 6 tests
- Edge Cases: 3 tests

---

## 🎨 UI Preview

### AI Status Card
```
┌─────────────────────────────────┐
│ 🔥  Kondisi Panas               │
│     [AI Classification]         │
│                                 │
│ Suhu terlalu tinggi (30.0°C).   │
│ Perlu pendinginan.              │
│                                 │
│ Rekomendasi:                    │
│ • Nyalakan kipas                │
│ • Pastikan ventilasi terbuka    │
│ • Hindari aktivitas berat       │
└─────────────────────────────────┘
```

### Auto Control Button
```
┌─────────────────────────────────┐
│ 🤖  🤖 Auto Control AKTIF       │
│                                 │
│ AI mengontrol perangkat         │
│ secara otomatis                 │
│                          ⏼      │
└─────────────────────────────────┘
```

---

## ⚙️ Kustomisasi

### Ubah Threshold Suhu/Kelembaban
Edit `lib/ai_service.dart`:
```dart
static const double TEMP_HOT_THRESHOLD = 28.0; // Ubah sesuai kebutuhan
static const double HUMIDITY_HIGH_THRESHOLD = 70.0;
```

### Ubah Interval Auto Control
Edit `lib/main.dart` di method `toggleAutoControl()`:
```dart
Timer.periodic(const Duration(seconds: 30), ...); // Ubah 30 ke nilai lain
```

### Ubah Jam Gelap/Terang
Edit `lib/ai_service.dart`:
```dart
static const int DARK_HOUR_START = 18; // 6 PM
static const int DARK_HOUR_END = 6;    // 6 AM
```

---

## 🐛 Troubleshooting

### AI Card Tidak Muncul
- ✅ Pastikan sensor menerima data
- ✅ Check console untuk error
- ✅ Restart aplikasi

### Auto Control Tidak Jalan
- ✅ Pastikan MQTT connected
- ✅ Lihat notifikasi "Auto Control diaktifkan"
- ✅ Check device state di console

### Device Tidak Merespon
- ✅ Pastikan device online (status Online di card)
- ✅ Check MQTT broker connection
- ✅ Verify topic MQTT di ESP32

### Lampu Tidak Sesuai Waktu
- ✅ Check waktu sistem device (DateTime.now())
- ✅ Adjust DARK_HOUR_START & END jika perlu

---

## 📊 Monitoring

### Console Logs
Saat auto control aktif, akan ada logs:
```
📨 MQTT Message: kelompok/iot/sensor/suhu => 30.0
🤖 AI Decision: fan_floor1 -> ON
✅ Command sent: kelompok/iot/perintah/fan -> 1
```

### Notifikasi UI
- Setiap auto control action akan tampil notifikasi
- Warna biru untuk info
- Hijau untuk aktif
- Orange untuk nonaktif

---

## 🎓 Penjelasan Kode

### Flow Auto Control:
```
1. Timer setiap 30 detik
2. _executeAutoControl() dipanggil
3. AI analyze: temperature + humidity + time
4. AI classify: panas/lembab/nyaman/normal
5. AI decide: kipas ON/OFF, lampu ON/OFF
6. toggleDevice() untuk setiap device
7. MQTT publish command
8. Device respond & update status
9. UI update real-time
```

### AI Classification Logic:
```dart
if (suhu > 28 && humidity > 70) -> Panas & Lembab
else if (suhu > 28) -> Panas
else if (humidity > 70) -> Lembab
else if (22 <= suhu <= 26 && 40 <= humidity <= 60) -> Nyaman
else -> Normal
```

---

## 📚 Resources

- **Dokumentasi Lengkap:** `AI_FEATURES.md`
- **AI Service Code:** `lib/ai_service.dart`
- **UI Integration:** `lib/main.dart` (line ~650-700)
- **Tests:** `test/ai_service_test.dart`

---

## ✨ Tips

1. **Demo Mode**: Ubah manual sensor value untuk test kondisi berbeda
2. **Night Mode**: Set jam sistem ke malam untuk test kontrol lampu
3. **Stress Test**: Aktifkan auto control dan ubah-ubah suhu/kelembaban
4. **Multi Device**: Test dengan semua device (5 device total)

---

## 🎉 Selamat!

Fitur AI sudah siap digunakan! 🚀

**Next Steps:**
- Test semua skenario
- Adjust threshold sesuai kebutuhan
- Customize UI jika perlu
- Deploy ke device

---

**Happy Coding! 🤖💡**
