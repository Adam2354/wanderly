import 'package:hive_flutter/hive_flutter.dart';
import '../models/activity_model.dart';

class HiveService {
  static const String boxName = 'activities';
  static HiveService? _instance;
  late Box<ActivityModel> _box;

  HiveService._();

  static HiveService get instance {
    _instance ??= HiveService._();
    return _instance!;
  }

  Box<ActivityModel> get box => _box;

  Future<void> initialize() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ActivityModelAdapter());
    _box = await Hive.openBox<ActivityModel>(boxName);
    await _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (_box.isEmpty) {
      await _addSampleData();
    }
  }

  Future<void> _addSampleData() async {
    await _box.add(
      ActivityModel(
        name: 'Golden Pavilion (Kinkaku-ji)',
        location: 'Kyoto, Japan',
        notes:
            'Kuil Budha yang indah dengan lapisan emas. Salah satu destinasi paling ikonik di Kyoto dengan refleksi emas di kolam.',
        category: 'Sightseeing',
        date: DateTime(2026, 3, 15),
        imagePath: 'assets/images/Golden Pavillion.png',
      ),
    );

    await _box.add(
      ActivityModel(
        name: 'Fushimi Inari Shrine',
        location: 'Kyoto, Japan',
        notes:
            'Terkenal dengan ribuan gerbang torii berwarna merah yang membentang hingga ke puncak gunung. Kyoto Exploration highlight!',
        category: 'Sightseeing',
        date: DateTime(2026, 3, 16),
        imagePath: 'assets/images/Fushimi Inari.jpg',
      ),
    );

    await _box.add(
      ActivityModel(
        name: 'Arashiyama Bamboo Grove',
        location: 'Arashiyama, Kyoto, Japan',
        notes:
            'Hutan bambu yang menakjubkan dengan suara angin yang menenangkan. Perfect untuk Kyoto Exploration photos!',
        category: 'Sightseeing',
        date: DateTime(2026, 3, 17),
        imagePath: 'assets/images/Arashiyama-Bamboo-Grove.jpg',
      ),
    );

    await _box.add(
      ActivityModel(
        name: 'Kiyomizu-dera Temple',
        location: 'Kyoto, Japan',
        notes:
            'Kuil kayu bersejarah dengan pemandangan kota Kyoto yang spektakuler. Bagian dari Kyoto Exploration UNESCO World Heritage.',
        category: 'Sightseeing',
        date: DateTime(2026, 3, 18),
        imagePath: 'assets/images/kiyomizu.jpg',
      ),
    );

    // Kyoto Exploration - Restaurant
    await _box.add(
      ActivityModel(
        name: 'Ichiran Ramen',
        location: 'Kyoto Station',
        notes:
            'Ramen tonkotsu yang terkenal dengan sistem makan solo. Must-try di Kyoto Exploration!',
        category: 'Restaurant',
        date: DateTime(2026, 3, 15),
        imagePath: 'assets/images/ichiran ramen.jpg',
      ),
    );

    await _box.add(
      ActivityModel(
        name: 'Nishiki Warai',
        location: 'Nishiki Market, Kyoto',
        notes:
            'Okonomiyaki dan takoyaki yang enak di Nishiki Market. Local favorite untuk Kyoto Exploration food tour.',
        category: 'Restaurant',
        date: DateTime(2026, 3, 16),
        imagePath: 'assets/images/nishiki warai.jpg',
      ),
    );

    await _box.add(
      ActivityModel(
        name: 'Katsukura Tonkatsu',
        location: 'Sanjo, Kyoto, Japan',
        notes:
            'Tonkatsu terbaik di Kyoto dengan kuah miso gratis. Kyoto Exploration culinary experience.',
        category: 'Restaurant',
        date: DateTime(2026, 3, 17),
        imagePath: 'assets/images/katsukura.jpg',
      ),
    );

    await _box.add(
      ActivityModel(
        name: 'Pontocho Alley',
        location: 'Pontocho, Kyoto, Japan',
        notes:
            'Bar dan teahouse tradisional di sepanjang sungai Kamogawa. Best nightlife spot untuk Kyoto Exploration!',
        category: 'Nightlife',
        date: DateTime(2026, 3, 17),
        imagePath: 'assets/images/pontocho.jpg',
      ),
    );

    await _box.add(
      ActivityModel(
        name: 'Gion District Night Walk',
        location: 'Gion, Kyoto, Japan',
        notes:
            'Jalan-jalan malam di distrik Geisha, chance melihat Geisha atau Maiko. Kyoto Exploration cultural experience.',
        category: 'Nightlife',
        date: DateTime(2026, 3, 16),
        imagePath: 'assets/images/gion.jpg',
      ),
    );

    // Kyoto Exploration - Hotel
    await _box.add(
      ActivityModel(
        name: 'The Ritz-Carlton Kyoto',
        location: 'Kamogawa Nijo-Ohashi, Kyoto',
        notes:
            'Hotel bintang lima dengan pemandangan sungai Kamogawa dan pelayanan kelas dunia. Perfect untuk Kyoto Exploration luxury stay.',
        category: 'Hotel',
        date: DateTime(2026, 3, 15),
        imagePath: 'assets/images/ritz_carlton.jpg',
      ),
    );

    await _box.add(
      ActivityModel(
        name: 'Traditional Ryokan Yoshikawa',
        location: 'Oike, Kyoto, Japan',
        notes:
            'Penginapan tradisional Jepang dengan kaiseki dinner dan tatami rooms. Authentic Kyoto Exploration experience.',
        category: 'Hotel',
        date: DateTime(2026, 3, 16),
        imagePath: 'assets/images/ryokan.jpg',
      ),
    );

    await _box.add(
      ActivityModel(
        name: 'Nishiki Market',
        location: 'Nishiki-koji, Kyoto, Japan',
        notes:
            'Pasar tradisional dengan 400 tahun sejarah, ribuan toko jual makanan & souvenir. Kyoto Exploration shopping paradise!',
        category: 'Shopping',
        date: DateTime(2026, 3, 16),
        imagePath: 'assets/images/nishiki_market.jpg',
      ),
    );

    await _box.add(
      ActivityModel(
        name: 'Teramachi Shopping Street',
        location: 'Teramachi, Kyoto, Japan',
        notes:
            'Shopping arcade dengan toko tradisional dan modern. Great untuk Kyoto Exploration souvenir hunting.',
        category: 'Shopping',
        date: DateTime(2026, 3, 17),
        imagePath: 'assets/images/teramachi.jpg',
      ),
    );

    await _box.add(
      ActivityModel(
        name: 'Toei Kyoto Studio Park',
        location: 'Uzumasa, Kyoto, Japan',
        notes:
            'Theme park studio film jaman Edo dengan live shows dan museum. Unique Kyoto Exploration entertainment!',
        category: 'Cinema',
        date: DateTime(2026, 3, 18),
        imagePath: 'assets/images/toei_cinemas.jpg',
      ),
    );
  }

  Future<void> addActivity(ActivityModel activity) async {
    await _box.add(activity);
  }

  Future<void> updateActivity(int index, ActivityModel activity) async {
    await _box.putAt(index, activity);
  }

  Future<void> deleteActivity(int index) async {
    await _box.deleteAt(index);
  }

  List<ActivityModel> getActivities() {
    return _box.values.toList();
  }

  List<ActivityModel> getActivitiesByCategory(String category) {
    return _box.values
        .where((activity) => activity.category == category)
        .toList();
  }

  Future<void> clearAll() async {
    await _box.clear();
  }

  Future<void> reloadSampleData() async {
    await _box.clear();
    await _addSampleData();
  }
}
