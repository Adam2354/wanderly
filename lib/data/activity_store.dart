// 💎 Model data `ActivityItem` yang simpel tapi efektif. Penggunaan tipe data `DateTime?` 
// sangat tepat untuk fleksibilitas jadwal kunjungan. 👍
class ActivityItem {
  ActivityItem({
    required this.name,
    required this.location,
    required this.notes,
    this.date,
    this.imagePath,
  });

  String name;
  String location;
  String notes;
  DateTime? date;
  String? imagePath;
}

// 💎 Implementasi `ActivityStore` sebagai Singleton adalah keputusan arsitektur 
// yang cerdas! Ini memastikan konsistensi data di seluruh aplikasi. 🏗️✨
class ActivityStore {
  ActivityStore._() {
    _initializeSampleData();
  }

  static final ActivityStore instance = ActivityStore._();

  final List<String> categories = const [
    'Sightseeing',
    'Restaurant',
    'Nightlife',
    'Hotel',
    'Shopping',
    'Cinema',
  ];

  late final Map<String, List<ActivityItem>> _itemsByCategory = {
    for (final category in categories) category: <ActivityItem>[],
  };

  void _initializeSampleData() {
    // Sightseeing
    _itemsByCategory['Sightseeing']!.addAll([
      ActivityItem(
        name: 'Golden Pavilion',
        location: 'Kyoto, Japan',
        notes: 'Kuil Budha yang indah dengan lapisan emas',
        date: DateTime(2026, 3, 15),
        imagePath: 'assets/images/Golden Pavillion.png',
      ),
      ActivityItem(
        name: 'Fushimi Inari Shrine',
        location: 'Kyoto, Japan',
        notes: 'Terkenal dengan ribuan gerbang torii berwarna merah',
        date: DateTime(2026, 3, 16),
        imagePath: 'assets/images/Fushimi Inari.jpg',
      ),
      ActivityItem(
        name: 'Arashiyama Bamboo Grove',
        location: 'Kyoto, Japan',
        notes: 'Hutan bambu yang menakjubkan',
        date: DateTime(2026, 3, 17),
        imagePath: 'assets/images/Arashiyama-Bamboo-Grove.jpg',
      ),
    ]);

    // Restaurant
    _itemsByCategory['Restaurant']!.addAll([
      ActivityItem(
        name: 'Ichiran Ramen',
        location: 'Kyoto Station',
        notes: 'Ramen tonkotsu yang terkenal, sistem makan solo',
        date: DateTime(2026, 3, 15),
        imagePath: 'assets/images/ichiran ramen.jpg',
      ),
      ActivityItem(
        name: 'Nishiki Warai',
        location: 'Nishiki Market',
        notes: 'Okonomiyaki dan takoyaki yang enak',
        date: DateTime(2026, 3, 16),
        imagePath: 'assets/images/nishiki warai.jpg',
      ),
      ActivityItem(
        name: 'Katsukura',
        location: 'Sanjo Teramachi',
        notes: 'Tonkatsu terbaik di Kyoto',
        date: DateTime(2026, 3, 17),
        imagePath: 'assets/images/katsukura.jpg',
      ),
    ]);

    // Nightlife
    _itemsByCategory['Nightlife']!.addAll([
      ActivityItem(
        name: 'Gion District',
        location: 'Gion, Kyoto',
        notes: 'Berjalan malam di distrik geisha tradisional',
        date: DateTime(2026, 3, 15),
        imagePath: 'assets/images/gion district.jpg',
      ),
      ActivityItem(
        name: 'Bar K6',
        location: 'Pontocho Alley',
        notes: 'Bar jazz yang cozy dengan pemandangan sungai',
        date: DateTime(2026, 3, 16),
        imagePath: 'assets/images/bar k6.jpg',
      ),
    ]);

    // Hotel
    _itemsByCategory['Hotel']!.addAll([
      ActivityItem(
        name: 'Kyoto Granbell Hotel',
        location: 'Higashiyama Ward',
        notes: 'Hotel modern dengan rooftop bar',
        date: DateTime(2026, 3, 14),
        imagePath: 'assets/images/kyoto granbel.jpg',
      ),
      ActivityItem(
        name: 'Hotel Gracery Kyoto',
        location: 'Kyoto Station Area',
        notes: 'Dekat stasiun, sangat nyaman untuk transportasi',
        date: DateTime(2026, 3, 14),
        imagePath: 'assets/images/Urban Hotel.png',
      ),
    ]);

    // Shopping
    _itemsByCategory['Shopping']!.addAll([
      ActivityItem(
        name: 'Nishiki Market',
        location: 'Nakagyo Ward',
        notes: 'Pasar tradisional dengan berbagai makanan dan souvenir',
        date: DateTime(2026, 3, 16),
        imagePath: 'assets/images/nishiki warai.jpg',
      ),
      ActivityItem(
        name: 'Teramachi Shopping Street',
        location: 'Downtown Kyoto',
        notes: 'Jalan perbelanjaan dengan toko modern dan tradisional',
        date: DateTime(2026, 3, 17),
        imagePath: 'assets/images/teramachi.jpg',
      ),
      ActivityItem(
        name: 'Kyoto Station Building',
        location: 'Kyoto Station',
        notes: 'Shopping mall besar dengan berbagai brand',
        date: DateTime(2026, 3, 18),
        imagePath: 'assets/images/kinkaku ji.jpg',
      ),
    ]);

    // Cinema
    _itemsByCategory['Cinema']!.addAll([
      ActivityItem(
        name: 'TOHO Cinemas Nijojo',
        location: 'Nijo Castle Area',
        notes: 'Bioskop modern dengan layar IMAX',
        date: DateTime(2026, 3, 17),
        imagePath: 'assets/images/toho_cinema.jpg',
      ),
      ActivityItem(
        name: 'MOVIX Kyoto',
        location: 'Kyoto Station',
        notes: 'Bioskop dengan teknologi Dolby Atmos',
        date: DateTime(2026, 3, 18),
        imagePath: 'assets/images/movix kyoto.jpg',
      ),
    ]);
  }

  List<ActivityItem> itemsFor(String category) =>
      _itemsByCategory[category] ?? <ActivityItem>[];

  List<ActivityItem> allItems() {
    final List<ActivityItem> all = [];
    for (final category in categories) {
      all.addAll(_itemsByCategory[category] ?? []);
    }
    return all;
  }

  String getCategoryForItem(ActivityItem item) {
    for (final category in categories) {
      final list = _itemsByCategory[category];
      if (list != null && list.contains(item)) {
        return category;
      }
    }
    return categories.first;
  }

  int getIndexInCategory(String category, ActivityItem item) {
    final list = _itemsByCategory[category];
    if (list == null) return -1;
    return list.indexOf(item);
  }

  // 💎 Method CRUD (`addItem`, `updateItem`, `deleteItem`) di level store membuat logic 
  // UI tetap bersih dan hanya fokus pada penampilan. Good job! 🎯✅
  void addItem(String category, ActivityItem item) {
    _itemsByCategory[category]?.add(item);
  }

  void updateItem(String category, int index, ActivityItem item) {
    final list = _itemsByCategory[category];
    if (list == null || index < 0 || index >= list.length) return;
    list[index] = item;
  }

  void deleteItem(String category, int index) {
    final list = _itemsByCategory[category];
    if (list == null || index < 0 || index >= list.length) return;
    list.removeAt(index);
  }
}
