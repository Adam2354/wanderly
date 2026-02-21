# 🚀 Quick Setup Guide - Wanderly Firebase

## Step-by-Step Setup Firebase

### 1. Install Flutter Dependencies
```bash
cd wanderly
flutter pub get
```

### 2. Setup Firebase Project

#### A. Create Firebase Project
1. Buka https://console.firebase.google.com/
2. Klik "Add Project"
3. Nama project: **Wanderly**
4. Disable Google Analytics (optional)
5. Klik "Create Project"

#### B. Enable Authentication
1. Di sidebar, klik **Authentication**
2. Klik **Get Started**
3. Tab **Sign-in method** → Enable **Email/Password**
4. Klik **Save**

#### C. Create Firestore Database
1. Di sidebar, klik **Firestore Database**
2. Klik **Create Database**
3. Pilih **Start in test mode**
4. Location: **asia-southeast2 (Jakarta)**
5. Klik **Enable**

#### D. Setup Security Rules
1. Di Firestore, tab **Rules**
2. Copy paste rules dari file `firestore.rules`
3. Klik **Publish**

### 3. Setup Android App

#### A. Register Android App
1. Di Firebase Console → ⚙️ Project Settings
2. Scroll ke "Your apps"
3. Klik **Android** icon
4. Package name: `com.example.wanderly`
5. Klik **Register app**

#### B. Download google-services.json
1. Download `google-services.json`
2. Copy ke: `android/app/google-services.json`

#### C. Update build.gradle (Project level)
File: `android/build.gradle.kts`

Tambahkan di bagian `dependencies`:
```kotlin
dependencies {
    classpath("com.google.gms:google-services:4.4.0")
}
```

Atau tambahkan di `plugins`:
```kotlin
plugins {
    id("com.google.gms.google-services") version "4.4.0" apply false
}
```

#### D. Update build.gradle (App level)
File: `android/app/build.gradle.kts`

Tambahkan di paling atas:
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Add this line
}
```

### 4. Setup iOS App (Optional)

#### A. Register iOS App
1. Di Firebase Console → ⚙️ Project Settings
2. Klik **iOS** icon
3. Bundle ID: `com.example.wanderly`
4. Klik **Register app**

#### B. Download GoogleService-Info.plist
1. Download `GoogleService-Info.plist`
2. Drag ke Xcode: `ios/Runner/GoogleService-Info.plist`

### 5. Generate Firebase Options

#### A. Install Firebase CLI
```bash
npm install -g firebase-tools
```

#### B. Install FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

#### C. Login to Firebase
```bash
firebase login
```

#### D. Configure FlutterFire
```bash
flutterfire configure
```

Pilih:
- Project: **Wanderly**
- Platforms: **android** (dan ios jika perlu)

File `lib/firebase_options.dart` akan otomatis di-generate.

### 6. Update Main.dart

File: `lib/main.dart`

Pastikan ada import:
```dart
import 'firebase_options.dart';
```

Dan di `main()`:
```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

### 7. Run App

```bash
# Check devices
flutter devices

# Run
flutter run
```

## ✅ Verification Checklist

- [ ] Dependencies installed (`flutter pub get`)
- [ ] Firebase project created
- [ ] Authentication enabled (Email/Password)
- [ ] Firestore database created
- [ ] Security rules deployed
- [ ] Android app registered
- [ ] `google-services.json` downloaded and placed
- [ ] `firebase_options.dart` generated
- [ ] App runs without Firebase errors

## 🧪 Testing

### Test Firebase Authentication
1. Run app
2. Go to Register screen
3. Create account: `test@example.com` / `password123`
4. Should navigate to Home screen
5. Check Firebase Console → Authentication → Users

### Test Firestore
1. Add a trip in the app
2. Check Firebase Console → Firestore Database
3. Should see collection `trips` with your data
4. `userId` field should match your authenticated user

### Test Dark Mode
1. Go to Profile screen
2. Toggle Dark Mode switch
3. UI should change instantly
4. Restart app → Dark mode should persist

### Test Filter & Sort
1. Go to My Trips screen
2. Add multiple trips with different dates and status
3. Click Filter icon → Select filter
4. Click Sort icon → Select sort method
5. List should update accordingly

## 🐛 Common Issues

### "No Firebase App created"
**Fix**: Pastikan `Firebase.initializeApp()` ada di `main()` sebelum `runApp()`.

### "google-services.json not found"
**Fix**: Pastikan file ada di `android/app/google-services.json`.

### Build failed "Could not resolve com.google.gms:google-services"
**Fix**: 
1. Check internet connection
2. Run `flutter clean`
3. Run `flutter pub get`
4. Rebuild

### "Permission Denied" di Firestore
**Fix**: Deploy security rules dari file `firestore.rules`.

## 📞 Need Help?

Jika ada error:
1. Check console logs
2. Check Firebase Console → Firestore → Logs
3. Verify all setup steps completed
4. Try `flutter clean` and rebuild

---

Happy Coding! 🎉
