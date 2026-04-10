# Wanderly — Travel Planner App (Flutter + Firebase)

![Wanderly Banner](./assets/images/Mobile%20Dev.png)

## 🚀 Overview
Wanderly adalah aplikasi perencanaan perjalanan (trip planner) yang dibuat dengan **Flutter** dan **Firebase**. Aplikasi ini menggunakan **Riverpod** untuk state management dan menerapkan pendekatan **Clean Architecture** untuk memisahkan tanggung jawab antar layer agar codebase lebih mudah dirawat dan dikembangkan.

---

## ✨ Key Features
- **Authentication (Firebase Auth)**: Register/Login pengguna.
- **Trip Management**: Membuat dan melihat daftar perjalanan.
- **Activities**: Menambahkan aktivitas pada rencana perjalanan.
- **Cloud Data (Firestore)**: Data tersimpan dan tersinkronisasi melalui Firestore.
- **Maps Integration**: Integrasi **Google Maps** untuk kebutuhan lokasi.
- **Clean Architecture**: Pemisahan layer **presentation / domain / data**.

---

## 🛠️ Technology Stack
| Category | Technologies |
| :--- | :--- |
| **Framework** | Flutter (Dart) |
| **State Management** | Riverpod |
| **Backend / BaaS** | Firebase (Auth, Firestore) |
| **Maps** | google_maps_flutter |

---

## 📁 Project Structure
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
│   ├── repositories/
│   ├── usecases/
│   ├── activities/
│   └── trips/
├── presentation/
│   ├── providers/
│   ├── screens/
│   └── utils/
├── shared/
├── widgets/
├── firebase_options.dart
└── main.dart
```

---

## ⚙️ Getting Started
### 1) Clone repository
```bash
git clone https://github.com/Adam2354/wanderly.git
cd wanderly
```

### 2) Install dependencies
```bash
flutter pub get
```

### 3) Setup Firebase
Pastikan Firebase sudah dikonfigurasi (mis. `google-services.json`, `GoogleService-Info.plist`, dan `firebase_options.dart`).

### 4) Run
```bash
flutter run
```

---

## 📚 Documentation
- `SETUP_GUIDE.md`
- `README_FIREBASE.md`
- `IMPLEMENTATION_SUMMARY.md`
- `CHECKLIST.md`

---

## ✉️ Contact
- GitHub: **@Adam2354**

---

## 📄 License
Harisenin.com
