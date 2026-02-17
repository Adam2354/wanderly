# Refactoring Wanderly - Data Persistence pake Riverpod sama Hive

## Apa aja yang diubah

Jadi gini, app Wanderly ini udah direfactor pakai Riverpod buat state management terus Hive buat simpen data lokal yang ga ilang-ilang. Soalnya sebelumnya kalo app ditutup datanya hilang, sekarang udah ga lagi.

## Fitur yang udah dikerjain

### 1. State Management pake Riverpod
- Ga pake setState lagi (soalnya ribet kalo app udah gede)
- Pake StateNotifier buat kelola state yang kompleks  
- UI nya otomatis update sendiri kalo data berubah

### 2. Simpen Data pake Hive
- Database lokal yang cepet dan ringan
- Auto save tiap kali ada perubahan
- Data tetep ada walau app udah ditutup

### 3. Sinkronisasi Data
- Otomatis sinkron antara database sama UI
- Provider nya reactive jadi UI selalu update
- Bisa add, edit, delete semua real-time

## Struktur Folder

```
lib/
├── data/
│   ├── models/
│   │   └── activity_model.dart          
│   ├── providers/
│   │   └── activity_provider.dart       
│   └── services/
│       └── hive_service.dart            
├── screens/
│   └── itinerary/
│       └── my_itinerary_screen.dart     
└── main.dart                             
```

## Dependencies yang ditambahin

```yaml
dependencies:
  flutter_riverpod: ^2.6.0    
  riverpod: ^2.6.0            
  hive: ^2.2.3                
  hive_flutter: ^1.1.0        

dev_dependencies:
  hive_generator: ^2.0.0      
  build_runner: ^2.4.0        
```

## File-file yang dibuat/diubah

### 1. `lib/data/models/activity_model.dart` - BARU
Model buat data dengan annotations Hive:
```dart
@HiveType(typeId: 0)
class ActivityModel extends HiveObject {
  @HiveField(0) late String name;
  @HiveField(1) late String location;
  @HiveField(2) late String notes;
  @HiveField(3) late DateTime? date;
  @HiveField(4) late String? imagePath;
  @HiveField(5) late String category;
  // ... methods
}
```

### 2. `lib/data/services/hive_service.dart` - BARU
Service buat operasi database:
- `initialize()` - setup Hive sama load data awal
- `addActivity()` - tambahin aktivitas baru
- `updateActivity()` - update aktivitas yang udah ada
- `deleteActivity()` - hapus aktivitas
- `getActivities()` - ambil semua aktivitas
- `getActivitiesByCategory()` - filter by kategori

### 3. `lib/data/providers/activity_provider.dart` ✅ BARU
Riverpod providers untuk state management:
- `hiveServiceProvider` - Single instance HiveService
- `activitiesProvider` - StateNotifier untuk semua aktivitas
- `activitiesByCategoryProvider` - Filtered provider by kategori
- `categoriesProvider` - List kategori yang tersedia
- `isLoadingProvider` - Loading indicator

### 4. `lib/screens/itinerary/my_itinerary_screen.dart` ✅ REFACTORED
Migrasi dari `StatefulWidget` ke `ConsumerStatefulWidget`:
- Ganti `ActivityStore` dengan Riverpod providers
- Gunakan `ref.watch()` untuk data reactivity
- Gunakan `ref.read()` untuk mutation operations
- Hapus manual state management dengan `setState()`

### 5. `lib/main.dart` ✅ UPDATED
- Tambah import Riverpod
- Initialize Hive sebelum runApp
- Wrap app dengan `ProviderScope`
- Implementasi async initialization dengan `WidgetsFlutterBinding`

## 🚀 Cara Menggunakan

### Setup Awal (Sudah Dilakukan)
```bash
# Install dependencies
flutter pub get

# Generate Hive adapters
dart run build_runner build
```

### Mengakses Data di Widget
```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch untuk auto-update UI saat data berubah
    final activities = ref.watch(activitiesProvider);
    
    return ListView.builder(
      itemCount: activities.length,
      itemBuilder: (context, index) => Text(activities[index].name),
    );
  }
}
```

### Mutasi Data (Add, Edit, Delete)
```dart
// Add
ref.read(activitiesProvider.notifier).addActivity(newActivity);

// Update
ref.read(activitiesProvider.notifier).updateActivity(index, updatedActivity);

// Delete
ref.read(activitiesProvider.notifier).deleteActivity(index);
```

## ✅ Testing Checklist

- [ ] Jalankan aplikasi tanpa error
- [ ] Tambah aktivitas baru
- [ ] Edit aktivitas yang sudah ada
- [ ] Hapus aktivitas
- [ ] Buka aplikasi kembali - data masih ada ✨
- [ ] Filter by kategori bekerja dengan baik
- [ ] Tidak ada crash ketika database kosong

## 🎯 Hasil yang Diharapkan

### Sebelumnya (Problem)
```
❌ Buka app → Tambah data → Close app → Buka app → Data hilang 😢
```

### Sekarang (Solution)
```
✅ Buka app → Tambah data → Close app → Buka app → Data masih ada! 🎉
✅ Data auto-save ke Hive
✅ UI auto-update via Riverpod
✅ No setState() clutter
```

## 🔐 Error Handling

Aplikasi sudah dilengkapi dengan error handling:
- Try-catch di semua CRUD operations
- Loading indicators untuk async operations
- Graceful degradation jika database corrupted
- Print statements untuk debugging (bisa diganti dengan proper logging)

## 📚 Referensi

- **Riverpod Docs**: https://riverpod.dev
- **Hive Docs**: https://hive.dev
- **Flutter State Management**: https://flutter.dev/docs/development/data-and-backend/state-mgmt/intro

## 🎓 Pembelajaran

### Konsep yang Diterapkan

1. **Separation of Concerns**
   - UI (Screen) terpisah dari Business Logic (Provider)
   - Database logic terisolasi di Service

2. **Reactive Programming**
   - State changes otomatis notify UI
   - No manual rebuild management

3. **Dependency Injection**
   - Riverpod provides instances yang needed
   - Easy untuk testing

4. **Data Persistence**
   - Hive menyimpan data terstruktur
   - Performant untuk aplikasi mobile

## 🚀 Next Steps (Optional)

Untuk development lebih lanjut:

1. **Implement Riverpod AsyncNotifier** untuk async operations
2. **Add Logging** mengganti print statements
3. **Unit Testing** untuk providers dan services
4. **UI/UX Improvements** dengan loading dan error states
5. **Data Encryption** untuk sensitive data
6. **Cloud Sync** untuk backup data

---

**Status**: ✅ Implementation Complete - Ready for Testing
**Last Updated**: February 17, 2026
**Version**: 1.0.0
