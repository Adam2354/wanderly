class ActivityItem {
  ActivityItem({
    required this.name,
    required this.location,
    required this.notes,
  });

  String name;
  String location;
  String notes;
}

class ActivityStore {
  ActivityStore._();

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

  List<ActivityItem> itemsFor(String category) =>
      _itemsByCategory[category] ?? <ActivityItem>[];

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
