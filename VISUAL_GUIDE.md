# 📸 Visual Guide - AI Smart Home Features

## 🎨 UI Components

### 1. AI Status Card - Kondisi Nyaman ✨
```
╔════════════════════════════════════════╗
║  ┌──────────────────────────────────┐  ║
║  │  ✨     Kondisi Nyaman           │  ║
║  │         [AI Classification]       │  ║
║  │                                   │  ║
║  │  ┌─────────────────────────────┐ │  ║
║  │  │ Suhu dan kelembaban dalam   │ │  ║
║  │  │ kondisi ideal. Lingkungan   │ │  ║
║  │  │ sangat nyaman.              │ │  ║
║  │  └─────────────────────────────┘ │  ║
║  │                                   │  ║
║  │  Rekomendasi:                     │  ║
║  │  • Pertahankan kondisi saat ini  │  ║
║  │  • Tidak perlu penyesuaian       │  ║
║  └──────────────────────────────────┘  ║
╚════════════════════════════════════════╝
```
**Warna:** Hijau 🟢  
**Kondisi:** 22-26°C, 40-60%  
**Action:** Tidak ada perubahan

---

### 2. AI Status Card - Kondisi Panas 🔥
```
╔════════════════════════════════════════╗
║  ┌──────────────────────────────────┐  ║
║  │  🔥     Kondisi Panas            │  ║
║  │         [AI Classification]       │  ║
║  │                                   │  ║
║  │  ┌─────────────────────────────┐ │  ║
║  │  │ Suhu terlalu tinggi (30.0°C)│ │  ║
║  │  │ Perlu pendinginan.          │ │  ║
║  │  └─────────────────────────────┘ │  ║
║  │                                   │  ║
║  │  Rekomendasi:                     │  ║
║  │  • Nyalakan kipas untuk sirkulasi│  ║
║  │  • Pastikan ventilasi terbuka    │  ║
║  │  • Hindari aktivitas berat       │  ║
║  └──────────────────────────────────┘  ║
╚════════════════════════════════════════╝
```
**Warna:** Deep Orange 🟠  
**Kondisi:** >28°C  
**Action:** Kipas ON

---

### 3. AI Status Card - Kondisi Lembab 💧
```
╔════════════════════════════════════════╗
║  ┌──────────────────────────────────┐  ║
║  │  💧     Kondisi Lembab           │  ║
║  │         [AI Classification]       │  ║
║  │                                   │  ║
║  │  ┌─────────────────────────────┐ │  ║
║  │  │ Kelembaban tinggi (75.0%).  │ │  ║
║  │  │ Udara terasa lembab.        │ │  ║
║  │  └─────────────────────────────┘ │  ║
║  │                                   │  ║
║  │  Rekomendasi:                     │  ║
║  │  • Aktifkan kipas untuk mengurangi│  ║
║  │    kelembaban                     │  ║
║  │  • Buka jendela untuk ventilasi  │  ║
║  │  • Gunakan dehumidifier          │  ║
║  └──────────────────────────────────┘  ║
╚════════════════════════════════════════╝
```
**Warna:** Cyan 🔵  
**Kondisi:** >70% humidity  
**Action:** Kipas ON (sirkulasi)

---

### 4. AI Status Card - Panas & Lembab 🔥💧
```
╔════════════════════════════════════════╗
║  ┌──────────────────────────────────┐  ║
║  │  🔥💧  Panas & Lembab           │  ║
║  │         [AI Classification]       │  ║
║  │                                   │  ║
║  │  ┌─────────────────────────────┐ │  ║
║  │  │ Suhu tinggi (32.0°C) dan    │ │  ║
║  │  │ kelembaban tinggi (80.0%).  │ │  ║
║  │  │ Kondisi tidak nyaman.       │ │  ║
║  │  └─────────────────────────────┘ │  ║
║  │                                   │  ║
║  │  Rekomendasi:                     │  ║
║  │  • SEGERA nyalakan kipas maksimal│  ║
║  │  • Buka semua ventilasi          │  ║
║  │  • Kurangi sumber panas          │  ║
║  │  • Pertimbangkan menggunakan AC  │  ║
║  └──────────────────────────────────┘  ║
╚════════════════════════════════════════╝
```
**Warna:** Red 🔴  
**Kondisi:** >28°C AND >70%  
**Action:** Kipas ON maksimal

---

### 5. Auto Control Button - OFF State
```
╔════════════════════════════════════════╗
║  ┌──────────────────────────────────┐  ║
║  │  🤖  Auto Control                │  ║
║  │                                   │  ║
║  │  Ketuk untuk mengaktifkan        │  ║
║  │  kontrol otomatis AI       ⏻     │  ║
║  └──────────────────────────────────┘  ║
╚════════════════════════════════════════╝
```
**Warna:** Abu-abu (Grey) ⚫  
**Icon:** Outline robot  
**Status:** Inactive

---

### 6. Auto Control Button - ON State
```
╔════════════════════════════════════════╗
║  ┌──────────────────────────────────┐  ║
║  │  🤖  🤖 Auto Control AKTIF       │  ║
║  │                                   │  ║
║  │  AI mengontrol perangkat         │  ║
║  │  secara otomatis           ⏼     │  ║
║  └──────────────────────────────────┘  ║
╚════════════════════════════════════════╝
```
**Warna:** Hijau gradient (Green) 🟢  
**Icon:** Solid robot dengan glow  
**Status:** Active - checking every 30s

---

## 📱 Full Screen Layout

```
┌──────────────────────────────────────────┐
│  🏠 Smart Home                           │
│     Monitoring System              ●Online│
└──────────────────────────────────────────┘

┌─────────────────┐  ┌─────────────────┐
│  🌡️ Suhu       │  │  💧 Kelembaban  │
│  30.0 °C    ↑  │  │  55 %       →   │
│  Online  2s ago │  │  Online  2s ago │
└─────────────────┘  └─────────────────┘

┌─────────────────┐  ┌─────────────────┐
│  ⏻ All Off     │  │  ✨ Mode Adaptif│
└─────────────────┘  └─────────────────┘

╔════════════════════════════════════════╗
║         AI STATUS CARD                  ║
║  (Lihat detail di atas)                 ║
╚════════════════════════════════════════╝

╔════════════════════════════════════════╗
║      AUTO CONTROL BUTTON                ║
║  (Lihat detail di atas)                 ║
╚════════════════════════════════════════╝

📋 Kontrol Perangkat
🏠 Lantai 1
  ┌────────────────────────────────────┐
  │ 💡 LED Lantai 1    [Online]   ⏻ON │
  └────────────────────────────────────┘
  ┌────────────────────────────────────┐
  │ 🚪 Pintu Servo     [Online]   ⏻OFF│
  └────────────────────────────────────┘
  ┌────────────────────────────────────┐
  │ 🌀 Kipas Angin     [Online]   ⏻ON │
  └────────────────────────────────────┘

🏠 Lantai 2
  ┌────────────────────────────────────┐
  │ 💡 LED 1 Lantai 2  [Online]   ⏻OFF│
  └────────────────────────────────────┘
  ┌────────────────────────────────────┐
  │ 💡 LED 2 Lantai 2  [Online]   ⏻OFF│
  └────────────────────────────────────┘
```

---

## 🎬 User Flow

### Flow 1: Melihat Status AI
```
1. User membuka app
   ↓
2. Sensor data masuk via MQTT
   ↓
3. AI analyze setiap detik
   ↓
4. AI Status Card muncul dengan:
   - Emoji kondisi
   - Warna sesuai severity
   - Deskripsi detail
   - List rekomendasi
   ↓
5. User melihat kondisi real-time
```

### Flow 2: Mengaktifkan Auto Control
```
1. User scroll ke Auto Control button
   ↓
2. Button tampil abu-abu (OFF state)
   ↓
3. User tap button
   ↓
4. Button berubah hijau (ON state)
   ↓
5. Notifikasi muncul:
   "🤖 Auto Control diaktifkan"
   ↓
6. AI langsung eksekusi kontrol pertama
   ↓
7. Notifikasi action muncul:
   "🤖 Suhu tinggi! Kipas dinyalakan..."
   ↓
8. Device state update
   ↓
9. Setiap 30 detik, AI re-evaluate
```

### Flow 3: Auto Control Execution
```
Timer tick (setiap 30 detik)
   ↓
AI analyze:
 - Temperature: 30°C
 - Humidity: 55%
 - Time: 14:00 (siang)
   ↓
AI classify: 🔥 PANAS
   ↓
AI decide:
 - Kipas: ON ✅
 - Lampu: OFF (karena siang)
   ↓
Compare dengan current state:
 - Kipas: OFF → perlu ubah ke ON
 - Lampu: OFF → sudah sesuai
   ↓
toggleDevice('fan_floor1', true)
   ↓
MQTT publish: kelompok/iot/perintah/fan → "1"
   ↓
ESP32 terima command
   ↓
Kipas nyala
   ↓
MQTT status: kelompok/iot/status/fan → "1"
   ↓
App update state
   ↓
UI update (switch berubah ON)
   ↓
Notifikasi tampil:
"🤖 Suhu tinggi! Kipas dinyalakan untuk pendinginan."
```

---

## 🎯 Notification Examples

### 1. Auto Control Activated
```
┌────────────────────────────────────┐
│ 🤖 Auto Control diaktifkan - AI    │
│    akan mengatur perangkat secara  │
│    otomatis                        │
└────────────────────────────────────┘
```
**Color:** Green  
**Duration:** 3 seconds

### 2. Hot Condition Action
```
┌────────────────────────────────────┐
│ 🤖 Suhu tinggi! Kipas dinyalakan   │
│    untuk pendinginan.              │
└────────────────────────────────────┘
```
**Color:** Blue  
**Duration:** 2 seconds

### 3. Humid Condition Action
```
┌────────────────────────────────────┐
│ 🤖 Kelembaban tinggi! Kipas        │
│    dinyalakan untuk sirkulasi udara│
└────────────────────────────────────┘
```
**Color:** Blue  
**Duration:** 2 seconds

### 4. Comfortable Condition
```
┌────────────────────────────────────┐
│ 🤖 Kondisi nyaman. Kipas dimatikan,│
│    lampu disesuaikan dengan waktu. │
└────────────────────────────────────┘
```
**Color:** Blue  
**Duration:** 2 seconds

### 5. Auto Control Deactivated
```
┌────────────────────────────────────┐
│ ⏻ Auto Control dinonaktifkan       │
└────────────────────────────────────┘
```
**Color:** Orange  
**Duration:** 2 seconds

---

## 🎨 Color Scheme

### AI Status Card Colors:
- **Nyaman:** `#4CAF50` (Green)
- **Normal:** `#2196F3` (Blue)
- **Panas:** `#FF5722` (Deep Orange)
- **Lembab:** `#00BCD4` (Cyan)
- **Panas & Lembab:** `#F44336` (Red)

### Auto Control Button:
- **OFF:** `#757575` → `#9E9E9E` (Grey gradient)
- **ON:** `#4CAF50` → `#66BB6A` (Green gradient)

### Notifications:
- **Success/Active:** `#4CAF50` (Green)
- **Info/Action:** `#2196F3` (Blue)
- **Warning/Deactivate:** `#FF5722` (Orange)

---

## 📊 State Indicators

### Device Status:
```
[Online]  ● Green dot with glow
[Offline] ● Red dot with glow
```

### Switch States:
```
ON  ⏼ Toggle right (colored)
OFF ⏻ Toggle left (grey)
```

### Trend Indicators:
```
↑ Increasing
→ Stable
↓ Decreasing
```

---

## 🎭 Animation & Transitions

### 1. AI Status Card
- **Entrance:** Fade in + slide up (300ms)
- **Update:** Smooth color transition (500ms)
- **Emoji:** Subtle scale pulse

### 2. Auto Control Button
- **Tap:** Ripple effect
- **State change:** 
  - Color transition (400ms)
  - Icon morph (300ms)
  - Shadow expand (200ms)

### 3. Notifications
- **Appear:** Slide in from bottom (250ms)
- **Disappear:** Fade out (200ms)

### 4. Device Controls
- **Switch toggle:** Smooth slide (200ms)
- **Card press:** Scale down 0.98 (100ms)

---

## 💡 Visual Tips

### For Demo:
1. **Simulate Hot:** Manually set temp > 28°C
2. **Simulate Humid:** Set humidity > 70%
3. **Test Night Mode:** Change device time to 20:00
4. **Show Auto Control:** 
   - Before: Devices OFF
   - After: Kipas ON (if hot/humid)

### For Screenshots:
- Capture each condition type
- Show auto control ON and OFF states
- Demonstrate notification appearance
- Display device state changes

---

**Visual Reference Complete! 📸**
