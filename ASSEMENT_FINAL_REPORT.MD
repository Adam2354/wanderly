# Assessment Mission 6 🚀 Wanderly

Halo student HSB-1026! 👋  

Terima kasih sudah menyelesaikan Mission 6 pada Bootcamp Flutter Batch 1.

Aplikasi berjalan dan Hive + Riverpod sudah masuk, tetapi logika bisnis masih banyak berada di UI dan pemakaian `setState` masih dominan, sehingga separation of concerns mission belum tercapai.

---

## 📊 Aspek Penilaian

| Aspek Penilaian | Detail Item Penilaian | Poin Maksimal |
|-----------------|----------------------|---------------|
| Feature Completeness | Semua fitur sesuai instruction | 20 |
| Riverpod Implementation | StateNotifier/Notifier usage, state flow | 15 |
| Hive Integration | Persistensi data & adapter | 15 |
| Architecture & Structure | Separation of concerns | 15 |
| Clean Code | Naming, readability, modularity | 10 |
| Error Handling | Try-catch, fallback state | 10 |
| UI States | Loading, Empty, Error state | 10 |
| Maintainability | Scalability & structure | 5 |

---

## 📝 Raport Skor

| Aspek Penilaian | Skor Dicapai | Komentar Ramah & Kritis |
|-----------------|-------------|--------------------------|
| Feature Completeness | 17/20 | Fitur itinerary/hive berjalan, tetapi flow state tidak sepenuhnya provider-driven. |
| Riverpod Implementation | 12/15 | Provider ada, namun CRUD flow masih bercampur dengan logic di UI. |
| Hive Integration | 13/15 | Persistensi aktif dan load data awal tersedia. |
| Architecture & Structure | 12/15 | Layer data ada, tetapi screen masih memegang logic besar. |
| Clean Code | 9/10 | Struktur cukup jelas, tapi banyak kode UI panjang dan campuran concern. |
| Error Handling | 8/10 | Beberapa error hanya `print`, tidak diteruskan ke state/UI. |
| UI States | 10/10 | Loading/error ada di beberapa titik, tetapi tidak konsisten di semua flow. |
| Maintainability | 4/5 | Dengan state flow tersebar, pengembangan fitur baru berisiko tinggi. |

**Total Skor: 85 / 100 🎯**

---

## 2️⃣ Temuan Detail per File

### ✅ Hal yang Sudah Bagus
- `lib/data/providers/activity_provider.dart` sudah menggunakan `AsyncValue` untuk load state.
- `lib/data/services/hive_service.dart` sudah membuka box dan menyiapkan persistensi.
- Terdapat loading/error UI pada `MyItineraryScreen`.

### ⚠️ Perlu Peningkatan
- UI screen masih jadi pusat logika mutasi data.
- Error di notifier kategori disilent via `print`.
- Banyak pemakaian `setState` di area yang seharusnya bisa reactive via provider.

---

## 3️⃣ Inline Review Simulation

lib/screens/itinerary/itinerary_screen.dart

Line 273:  
❌ Objek `ActivityModel` dibangun langsung di UI dengan nilai hardcoded lalu langsung dipersist.
Suggestion: Pindahkan pembuatan entity + validasi ke notifier/usecase agar UI hanya memicu intent.

Severity: High  
Impact: Business logic tersebar di UI dan sulit diuji.

lib/data/providers/activity_provider.dart

Line 104:  
❌ Error ditangani dengan `print` saja di `ActivitiesByCategoryNotifier`.
Suggestion: Gunakan state error yang eksplisit (`AsyncValue`/sealed state) agar UI bisa menampilkan fallback aman.

Severity: Medium  
Impact: Failure bisa tersembunyi dan user tidak tahu operasi gagal.

lib/data/services/hive_service.dart

Line 21:  
⚠️ `Hive.registerAdapter(ActivityModelAdapter())` dipanggil tanpa guard `isAdapterRegistered`.
Suggestion: Tambahkan guard untuk mencegah exception saat re-init/hot restart scenario.

Severity: Medium  
Impact: Potensi runtime error pada lifecycle tertentu.

lib/main.dart

Line 75:  
❌ Template counter page masih tertinggal di project mission.
Suggestion: Hapus dead code `MyHomePage` agar codebase lebih bersih dan fokus.

Severity: Low  
Impact: Menambah noise dan membingungkan reviewer/maintainer.

---

## 💡 Saran Pengembangan Berikutnya

1. Refactor screen itinerary agar semua CRUD intent lewat notifier (UI hanya kirim input).
2. Standardisasi error handling ke satu model state, hindari `print` sebagai fallback utama.
3. Bersihkan sisa template/dead code dan kurangi `setState` untuk state aplikasi.

---

## 🧠 Kesimpulan Teknis

Project sudah memiliki komponen utama mission, tetapi belum memenuhi kualitas arsitektur yang diminta karena business logic belum benar-benar terpisah dari UI dan state flow masih campuran.
