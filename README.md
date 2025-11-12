# Robodu Mobile Apps

Robodu Mobile Apps adalah aplikasi mobile berbasis **Flutter** yang dirancang untuk mengendalikan dan memantau robot secara real-time melalui koneksi **Bluetooth** atau **WiFi**.  
Aplikasi ini memberikan pengalaman interaktif, mulai dari kendali pergerakan robot hingga menampilkan data dan video dari robot.

---

## 🚀 Teknologi yang Digunakan
- [Flutter](https://flutter.dev/) - Framework utama aplikasi mobile (Android & iOS).
- [Dart](https://dart.dev/) - Bahasa pemrograman utama.
- [Bluetooth / WiFi Connectivity] - Untuk komunikasi dengan robot.
- [Camera Streaming] - Integrasi video dari robot.
- [Audio Input] - Mengirimkan masukan suara ke robot.

---

## 📱 Spesifikasi & Kebutuhan Aplikasi
- **Kontrol Robot**
  - Maju, berbelok (kiri/kanan), dan berhenti.
  - Menggerakkan tangan robot (naik/turun).
- **Koneksi**
  - Mendukung koneksi **Bluetooth** maupun **WiFi**.
- **Monitoring Robot**
  - Menampilkan data sensor dari robot
  - Menampilkan video real-time dari kamera robot.
- **Interaksi Tambahan**
  - Mengirimkan input suara yang dapat diproses oleh robot.
- **Lainnya**
  - UI responsif dan mudah digunakan.
  - Dukungan mode terang & gelap.

---

## 📦 Instalasi & Menjalankan Project
1. **Clone repository**
   ```bash
   git clone https://github.com/username/robodu-mobile-apps.git
   cd robodu-mobile-apps

1. **Install Dependencies**
   ```bash
   flutter pub get

1. **Jalankan aplikasi**
   ```bash
   flutter run


## 📁 Penjelasan Folder
- **`ui/core/`** komponen dan tema umum
- **`ui/<features>`** fitur aplikasi
- **`ui/<features>/screen`** UI yang spesifik untuk fitur
- **`ui/<features>/view_model`** pengelola state dan logika presentasi fitur
- **`domain/models`** model (entity / business object)
- **`data/repositories`** implementasi sumber data
- **`data/services`** layanan eksternal dan utilitas data
- **`main.dart`** titik masuk utama aplikasi