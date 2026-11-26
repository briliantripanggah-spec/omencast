# OmenCast — Dark Fantasy Weather App

**Nama:** Brilian Tri Panggah  
**NIM:** H1D024052  
**Mata Kuliah:** Responsi Pemrograman Mobile (Flutter)

## Deskripsi Aplikasi
**OmenCast** adalah aplikasi prakiraan cuaca berbasis Flutter bertema *Dark Fantasy* yang menampilkan data cuaca real-time, prakiraan 24 jam & 7 hari ke depan, status petualangan (*Quest Status* & *Adventurer's Index*), animasi latar belakang dinamis berdasarkan cuaca & suhu, serta manajemen kota favorit menggunakan penyimpanan lokal.

---

## Struktur Aplikasi & Penerapan MVVM
Aplikasi dibangun menggunakan pola arsitektur **Model-View-ViewModel (MVVM)** dengan **Provider** sebagai state management dan **Hive** sebagai local storage:

```text
lib/
├── core/
│   ├── theme/app_theme.dart            # Konfigurasi Material 3 Dark Theme & Typography
│   └── utils/weather_mapper.dart       # Mapping weather_code & suhu ke label, ikon, dan Quest Status
├── models/
│   ├── location_model.dart             # Model data lokasi (Geocoding API & Hive)
│   └── weather_model.dart              # Model data cuaca (Current, Hourly, Daily)
├── services/
│   ├── open_meteo_service.dart         # HTTP GET ke Open-Meteo Forecast & Geocoding API
│   └── storage_service.dart            # Penyimpanan lokal favorit & lokasi terakhir (Hive)
├── viewmodels/
│   ├── weather_viewmodel.dart          # State management cuaca (loading, error, data)
│   └── search_viewmodel.dart           # State management pencarian kota & daftar favorit
├── views/
│   ├── home_screen.dart                # Layar utama (Bento Grid, 24h, 7d, Sun Arc, Adventurer's Index)
│   ├── search_screen.dart              # Layar pencarian kota via Geocoding API
│   ├── favorites_screen.dart           # Layar daftar kota favorit (Saved Realms)
│   └── widgets/
│       └── weather_background_animation.dart # Animasi & pemandangan dinamis (CustomPainter)
└── main.dart                           # Inisialisasi Hive & MultiProvider