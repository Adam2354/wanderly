# Android Build Configuration untuk Firebase

## File yang Perlu Diupdate

### 1. android/build.gradle.kts (Project Level)

Tambahkan Google Services di dependencies:

```kotlin
buildscript {
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:8.1.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.0")
        classpath("com.google.gms:google-services:4.4.0") // Add this
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
```

ATAU jika menggunakan plugins DSL:

```kotlin
plugins {
    id("com.android.application") version "8.1.0" apply false
    id("org.jetbrains.kotlin.android") version "1.9.0" apply false
    id("com.google.gms.google-services") version "4.4.0" apply false // Add this
}
```

### 2. android/app/build.gradle.kts (App Level)

Di bagian **paling atas**, tambahkan plugin:

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Add this line
}
```

### 3. android/settings.gradle.kts

Pastikan ada plugin management (biasanya sudah ada):

```kotlin
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.1.0" apply false
    id("org.jetbrains.kotlin.android") version "1.9.0" apply false
}

include(":app")
```

## Langkah-Langkah

1. **Pastikan file google-services.json sudah ada**
   ```
   android/app/google-services.json
   ```

2. **Update build.gradle files** seperti di atas

3. **Sync Gradle**
   ```bash
   cd android
   ./gradlew clean
   cd ..
   ```

4. **Build ulang**
   ```bash
   flutter clean
   flutter pub get
   flutter build apk
   ```

## Verifikasi

Jika setup benar:
- Build tidak error
- Aplikasi bisa run
- Firebase initialized tanpa error

## Common Errors

### "Could not resolve com.google.gms:google-services"
**Fix**: 
- Check internet connection
- Update Gradle version
- Sync Gradle files

### "google-services.json is missing"
**Fix**:
- Download dari Firebase Console
- Letakkan di `android/app/google-services.json`

### "Duplicate class found"
**Fix**:
- Clean build: `flutter clean`
- Delete build folders manually
- Rebuild: `flutter pub get && flutter run`

## Struktur Final

```
android/
├── build.gradle.kts          ← Add Google Services plugin
├── settings.gradle.kts       ← Check plugin management
└── app/
    ├── build.gradle.kts      ← Add plugin at top
    └── google-services.json  ← Downloaded from Firebase
```

## Test Command

```bash
# Clean
flutter clean

# Get dependencies
flutter pub get

# Build (ini akan validate gradle setup)
flutter build apk --debug

# Jika sukses, run
flutter run
```
