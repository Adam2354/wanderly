# Wanderly

Wanderly adalah aplikasi perencanaan perjalanan berbasis Flutter dengan Firebase (Auth + Firestore), state management Riverpod, serta penerapan Clean Architecture.

## Struktur Proyek (Updated)

Struktur layer saat ini sudah dirapikan agar lebih konsisten:

```text
lib/
├── core/
├── data/
│   ├── datasources/
│   │   ├── activity_store.dart
│   │   └── firebase/
│   │       ├── firebase_auth_datasource.dart
│   │       ├── firestore_datasource.dart
│   │       └── activity_firestore_datasource.dart
│   ├── mappers/
│   ├── models/
│   ├── repositories/
│   │   ├── trip_repository_impl.dart
│   │   └── activity_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── trip.dart
│   ├── repositories/
│   │   └── trip_repository.dart
│   ├── usecases/
│   │   ├── add_trip.dart
│   │   └── get_trips.dart
│   ├── activities/
│   │   └── repositories/
│   │       └── activity_repository.dart
│   └── trips/
│       ├── entities/
│       │   ├── trip.dart
│       │   └── trip_entity.dart
│       ├── repositories/
│       │   └── trip_repository.dart
│       └── usecases/
│           ├── add_trip.dart
│           ├── get_trips.dart
│           ├── query_trips_usecase.dart
│           ├── query_activity_fallback_usecase.dart
│           ├── build_trip_map_points_usecase.dart
│           └── resolve_destination_location_usecase.dart
├── presentation/
│   ├── providers/
│   │   ├── service_providers.dart
│   │   ├── auth_provider.dart
│   │   ├── activity_provider.dart
│   │   ├── trip_provider.dart
│   │   ├── location_provider.dart
│   │   └── theme_provider.dart
│   ├── screens/
│   └── utils/
├── screens/
├── shared/
├── widgets/
├── firebase_options.dart
└── main.dart
```

## Aturan Layer yang Dipakai

- `presentation/providers` untuk state management UI (Riverpod).
- `data/datasources` untuk integrasi sumber data eksternal (Firebase/API/DB).
- `domain/repositories` berisi kontrak (interface) repository utama.
- `data/repositories/*_impl.dart` berisi implementasi repository.
- `domain/usecases` dan `domain/*/usecases` berisi business logic per fitur.

## Menjalankan Proyek

1. Install dependency:

```bash
flutter pub get
```

2. Pastikan Firebase sudah dikonfigurasi (`google-services.json` dan `firebase_options.dart`).

3. Jalankan aplikasi:

```bash
flutter run
```

## Referensi Dokumen Lain

- `SETUP_GUIDE.md`
- `README_FIREBASE.md`
- `IMPLEMENTATION_SUMMARY.md`
- `CHECKLIST.md`
