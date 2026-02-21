# 🚀 Quick Start - Wanderly Firebase

## TL;DR - Minimal Steps

### 1. Setup Firebase (±20 menit)
```bash
1. Buka https://console.firebase.google.com/
2. Create project "Wanderly"
3. Authentication → Enable "Email/Password"
4. Firestore → Create database (test mode, asia-southeast2)
5. Android icon → Register app (com.example.wanderly)
6. Download google-services.json → Copy ke android/app/
```

### 2. Deploy Security Rules (±2 menit)
```bash
1. Di Firestore, tab "Rules"
2. Copy dari file: firestore.rules
3. Click "Publish"
```

### 3. Configure Project (±5 menit)
```bash
# Install tools (jika belum)
npm install -g firebase-tools
dart pub global activate flutterfire_cli

# Configure
firebase login
flutterfire configure
```

### 4. Update Build Files (±2 menit)
File: `android/app/build.gradle.kts`

Add this line in plugins section:
```kotlin
id("com.google.gms.google-services")
```

### 5. Run! (±2 menit)
```bash
flutter clean
flutter pub get
flutter run
```

## ✅ Quick Test

### Test 1: Register
1. Run app
2. Click "Daftar"
3. Email: `test@example.com`
4. Password: `password123`
5. Submit → Should go to Home

### Test 2: Firestore
1. Add a trip
2. Open Firebase Console → Firestore
3. Should see "trips" collection with your data

### Test 3: Filter & Sort
1. Add 3 trips with different dates
2. Click Filter icon → Select "Upcoming"
3. Click Sort icon → Select "Date (Newest First)"

### Test 4: Dark Mode
1. Go to Profile
2. Toggle "Dark Mode"
3. UI should turn dark instantly

## 📸 Screenshots Needed

**Dark Mode:**
- My Trips screen with filter/sort active

**Firebase Console:**
- Firestore trips collection
- Document detail showing fields

## 🆘 If Stuck

1. Check `SETUP_GUIDE.md` for detailed steps
2. Check `README_FIREBASE.md` for troubleshooting
3. Check `CHECKLIST.md` for what to test

## 🎯 Success Criteria

- ✅ Can register & login
- ✅ Can add trip → Shows in Firestore
- ✅ Can filter trips
- ✅ Can sort trips
- ✅ Dark mode works & persists

**That's it! 🎉**
