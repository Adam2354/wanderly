# Wanderly - Travel Planning App

Aplikasi mobile untuk merencanakan dan mengelola perjalanan dengan fitur authentication, cloud storage, dark mode, dan filtering/sorting.

## ✨ Fitur Utama

### 1. **Firebase Authentication**
- Login dan Register dengan Email/Password
- Logout functionality
- Protected routes (hanya user yang login yang bisa akses data)
- Error handling untuk berbagai kasus auth

### 2. **Cloud Migration (Firebase Firestore)**
- Migrasi dari Hive (local database) ke Firestore (cloud database)
- Real-time synchronization
- Data ter-isolasi per user (berdasarkan userId)
- CRUD operations: Create, Read, Update, Delete trips

### 3. **Smart UX Logic (Filter & Sort)**
- **Filter berdasarkan Status:**
  - All Trips
  - Upcoming (belum dimulai)
  - Ongoing (sedang berlangsung)
  - Completed (sudah selesai)
- **Sort berdasarkan:**
  - Date (Newest First / Oldest First)
  - Name (A-Z / Z-A)
- Auto-update status berdasarkan tanggal perjalanan

### 4. **Dark Mode**
- Toggle Dark/Light mode
- Konsisten di seluruh aplikasi (Background, Card, Text)
- Tersimpan di SharedPreferences (persistent)
- Smooth transition antar theme

### 5. **State Management**
- Menggunakan Riverpod untuk state management
- Filter dan sort tidak mengubah data di Firestore
- UI reaktif dan efisien

## 📱 Screenshots

### Light Mode
- Login Screen dengan Firebase Authentication
- Home Screen dengan list trips
- Filter & Sort UI
- Trip Details

### Dark Mode  
- Seluruh UI konsisten dengan tema dark
- Background: `#121212`
- Cards: `#1E1E1E`
- Text: White dengan opacity variants

## 🏗️ Struktur Project

```
lib/
├── main.dart                          # Entry point dengan Firebase init
├── firebase_options.dart              # Firebase configuration
├── data/
│   ├── models/
│   │   ├── activity_model.dart        # Model lama (Hive)
│   │   └── trip_model.dart           # Model baru (Firestore)
│   ├── services/
│   │   ├── hive_service.dart         # Service untuk Hive (backward compatibility)
│   │   ├── firebase_auth_service.dart # Service untuk Authentication
│   │   └── firestore_service.dart    # Service untuk Firestore CRUD
│   └── providers/
│       ├── activity_provider.dart    # Provider lama (Hive)
│       ├── auth_provider.dart        # Provider untuk Authentication
│       ├── trip_provider.dart        # Provider untuk Trips dengan Filter & Sort
│       └── theme_provider.dart       # Provider untuk Dark Mode
└── screens/
    ├── auth/
    │   ├── login_screen.dart         # Login dengan Firebase
    │   └── register_screen.dart      # Register dengan Firebase
    ├── trips/
    │   └── my_trips_screen.dart      # Screen dengan Filter & Sort
    └── ... (screens lainnya)
```

## 🔧 Setup & Installation

### 1. Clone Project
```bash
git clone <repository-url>
cd wanderly
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Setup Firebase

#### A. Create Firebase Project
1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Klik "Add Project" atau "Create a project"
3. Masukkan nama project: **Wanderly**
4. Enable Google Analytics (optional)
5. Klik "Create Project"

#### B. Add Android App
1. Di Firebase Console, klik ⚙️ (Settings) > Project Settings
2. Scroll ke "Your apps" dan klik Android icon
3. Register app dengan package name: `com.example.wanderly`
4. Download `google-services.json`
5. Copy file ke: `android/app/google-services.json`

#### C. Add iOS App (Optional)
1. Klik iOS icon di Firebase Console
2. Register app dengan bundle ID: `com.example.wanderly`
3. Download `GoogleService-Info.plist`
4. Copy file ke: `ios/Runner/GoogleService-Info.plist`

#### D. Enable Authentication
1. Di Firebase Console, pilih **Authentication**
2. Klik **Get Started**
3. Pilih tab **Sign-in method**
4. Enable **Email/Password**
5. Klik **Save**

#### E. Setup Firestore Database
1. Di Firebase Console, pilih **Firestore Database**
2. Klik **Create Database**
3. Pilih **Start in test mode** (untuk development)
4. Pilih location (asia-southeast2 untuk Indonesia)
5. Klik **Enable**

#### F. Configure Security Rules
Setelah Firestore dibuat, update Security Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read/write only if user is authenticated
    match /trips/{tripId} {
      allow read, write: if request.auth != null && 
                         request.auth.uid == resource.data.userId;
      allow create: if request.auth != null && 
                    request.auth.uid == request.resource.data.userId;
    }
  }
}
```

#### G. Generate Firebase Options
Install FlutterFire CLI:
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Login to Firebase
firebase login

# Configure FlutterFire
flutterfire configure
```

Pilih project **Wanderly** dan platforms yang ingin didukung (Android, iOS).

### 4. Update Build Configuration

#### Android (`android/build.gradle.kts`)
Pastikan sudah ada Google Services plugin:
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Add this
}
```

#### Android App Level (`android/app/build.gradle.kts`)
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// Add at the bottom
apply plugin: "com.google.gms.google-services"
```

### 5. Run App
```bash
# Check devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Or run in debug mode
flutter run
```

## 🔑 Test Credentials

Untuk testing, buat akun baru menggunakan:
- Email: test@example.com (atau email apapun)
- Password: password123 (minimal 6 karakter)

## 📚 Cara Menggunakan Aplikasi

### 1. Login / Register
- Buka aplikasi
- Pilih **Login** jika sudah punya akun
- Pilih **Register** untuk membuat akun baru
- Masukkan email dan password
- Klik **Continue**

### 2. Lihat Trip List
- Setelah login, akan masuk ke Home Screen
- Navigate ke **My Trips** untuk melihat daftar perjalanan

### 3. Filter Trips
- Klik icon **Filter** (funnel) di AppBar
- Pilih status: All, Upcoming, Ongoing, atau Completed
- List akan otomatis ter-filter

### 4. Sort Trips
- Klik icon **Sort** di AppBar
- Pilih urutan: Date (Newest/Oldest) atau Name (A-Z/Z-A)
- List akan otomatis ter-sort

### 5. Toggle Dark Mode
- Buka **Profile Screen**
- Toggle switch **Dark Mode**
- Theme akan berubah instant di seluruh aplikasi

### 6. Logout
- Buka **Profile Screen**
- Klik **Logout**
- Akan kembali ke Login Screen

## 🎯 Output Mission Checklist

- ✅ **Aplikasi Terintegrasi**: Login/Logout berfungsi penuh
- ✅ **CRUD Data**: Data tersimpan di Firestore dan terikat pada User ID
- ✅ **Advanced UI**: Sort dan Filter berfungsi lancar dan akurat
- ✅ **Dark Mode**: Screenshot aplikasi dalam kondisi Dark Mode
- ✅ **Firebase Console**: Screenshot struktur Collection/Document

## 🔒 Security Rules

Firestore Security Rules memastikan:
1. Hanya user yang authenticated yang bisa akses data
2. User hanya bisa baca/tulis data mereka sendiri
3. Setiap dokumen perjalanan menyimpan `userId` sebagai referensi kepemilikan

```javascript
// Firestore Security Rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /trips/{tripId} {
      // User hanya bisa read trips mereka sendiri
      allow read: if request.auth != null && 
                     request.auth.uid == resource.data.userId;
      
      // User hanya bisa create trips dengan userId mereka
      allow create: if request.auth != null && 
                       request.auth.uid == request.resource.data.userId;
      
      // User hanya bisa update/delete trips mereka sendiri
      allow update, delete: if request.auth != null && 
                               request.auth.uid == resource.data.userId;
    }
  }
}
```

## 🎨 Theme Configuration

### Light Theme
- Background: `#FFFFFF`
- Card: `#FFFFFF`
- Text: `#000000` (dengan variants)
- Primary: Blue

### Dark Theme
- Background: `#121212`
- Card: `#1E1E1E`
- Text: `#FFFFFF` (dengan variants)
- Primary: Blue

## 🧩 State Management dengan Riverpod

### Providers yang Digunakan:

1. **authNotifierProvider**: Mengelola authentication state
2. **themeModeProvider**: Mengelola Dark/Light mode
3. **tripsStreamProvider**: Stream trips dari Firestore
4. **tripFilterStatusProvider**: State untuk filter status
5. **tripSortByProvider**: State untuk sort method
6. **filteredSortedTripsProvider**: Computed state (filter + sort)

## 🚀 Features Breakdown

### Filter Logic
```dart
// Filter tidak mengubah data di Firestore
// Hanya manipulasi state di Riverpod
filtered = trips.where((trip) {
  switch (filterStatus) {
    case TripFilterStatus.upcoming:
      return trip.status == 'upcoming';
    case TripFilterStatus.ongoing:
      return trip.status == 'ongoing';
    case TripFilterStatus.completed:
      return trip.status == 'completed';
    default:
      return true;
  }
}).toList();
```

### Sort Logic
```dart
// Sort berdasarkan pilihan user
filtered.sort((a, b) {
  switch (sortBy) {
    case TripSortBy.dateAsc:
      return a.startDate!.compareTo(b.startDate!);
    case TripSortBy.dateDesc:
      return b.startDate!.compareTo(a.startDate!);
    case TripSortBy.nameAsc:
      return a.name.compareTo(b.name);
    case TripSortBy.nameDesc:
      return b.name.compareTo(a.name);
  }
});
```

### Auto Status Update
```dart
// Status otomatis update berdasarkan tanggal
String getAutoStatus() {
  if (startDate == null) return 'upcoming';
  
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final start = DateTime(startDate!.year, startDate!.month, startDate!.day);
  
  if (endDate != null) {
    final end = DateTime(endDate!.year, endDate!.month, endDate!.day);
    if (today.isAfter(end)) return 'completed';
    if (today.isAtSameMomentAs(start) || 
        (today.isAfter(start) && today.isBefore(end))) {
      return 'ongoing';
    }
  }
  
  return 'upcoming';
}
```

## 📝 Collection Structure di Firebase

### Collection: `trips`

```json
{
  "tripId_1": {
    "name": "Kyoto Adventure",
    "location": "Kyoto, Japan",
    "notes": "Visit temples and gardens",
    "category": "Sightseeing",
    "userId": "user123abc",
    "startDate": Timestamp(2026-03-15),
    "endDate": Timestamp(2026-03-20),
    "imagePath": "assets/images/kyoto.jpg",
    "status": "upcoming",
    "createdAt": Timestamp(2026-02-20),
    "updatedAt": Timestamp(2026-02-20)
  }
}
```

### Field Descriptions:
- `name`: Nama perjalanan
- `location`: Lokasi tujuan
- `notes`: Catatan/deskripsi
- `category`: Kategori (Sightseeing, Restaurant, Hotel, dll)
- `userId`: ID user pemilik (untuk security rules)
- `startDate`: Tanggal mulai perjalanan
- `endDate`: Tanggal selesai perjalanan
- `imagePath`: Path ke gambar (local asset)
- `status`: Status perjalanan (upcoming/ongoing/completed)
- `createdAt`: Timestamp saat dibuat
- `updatedAt`: Timestamp saat diupdate

## 🐛 Troubleshooting

### Error: "No Firebase App '[DEFAULT]' has been created"
**Solusi**: Pastikan `await Firebase.initializeApp()` sudah dipanggil di `main()` sebelum `runApp()`.

### Error: "FirebaseOptions cannot be null"
**Solusi**: Jalankan `flutterfire configure` untuk generate file `firebase_options.dart`.

### Error: "Permission Denied" saat akses Firestore
**Solusi**: 
1. Cek Security Rules di Firebase Console
2. Pastikan user sudah login
3. Pastikan `userId` tersimpan di setiap document

### Dark Mode tidak persistent
**Solusi**: Pastikan `SharedPreferences` sudah di-initialize dan di-override di ProviderScope.

### Filter/Sort tidak berfungsi
**Solusi**: 
1. Cek provider di Riverpod DevTools
2. Pastikan `ref.watch()` digunakan untuk listen changes
3. Cek console untuk error

## 📖 Referensi

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase for Flutter](https://firebase.flutter.dev/)
- [Riverpod Documentation](https://riverpod.dev/)
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli)

## 👨‍💻 Developer Notes

### Catatan Penting:
1. **Jangan commit** file `google-services.json` dan `GoogleService-Info.plist` ke repository public
2. **Backup Firestore Rules** sebelum deploy
3. **Test di emulator** sebelum deploy ke production
4. **Enable Analytics** untuk tracking usage

### Future Enhancements:
- [ ] Add image upload to Firebase Storage
- [ ] Add collaborative trips (multiple users)
- [ ] Add offline mode dengan caching
- [ ] Add push notifications
- [ ] Add Google Sign-In / Apple Sign-In
- [ ] Add trip sharing via link
- [ ] Add expense tracking per trip

---

## 📄 License

This project is for educational purposes.

---

**Dibuat dengan ❤️ menggunakan Flutter & Firebase**
