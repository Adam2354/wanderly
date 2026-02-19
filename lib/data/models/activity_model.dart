import 'package:hive/hive.dart';

part 'activity_model.g.dart';

@HiveType(typeId: 0)
class ActivityModel extends HiveObject {
  @HiveField(0)
  late String name;

  @HiveField(1)
  late String location;

  @HiveField(2)
  late String notes;

  @HiveField(3)
  late DateTime? date;

  @HiveField(4)
  late String? imagePath;

  @HiveField(5)
  late String category;

  ActivityModel({
    required this.name,
    required this.location,
    required this.notes,
    required this.category,
    this.date,
    this.imagePath,
  });

  ActivityModel.empty() {
    name = '';
    location = '';
    notes = '';
    category = '';
    date = null;
    imagePath = null;
  }

  ActivityModel copyWith({
    String? name,
    String? location,
    String? notes,
    DateTime? date,
    String? imagePath,
    String? category,
  }) {
    return ActivityModel(
      name: name ?? this.name,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      date: date ?? this.date,
      imagePath: imagePath ?? this.imagePath,
      category: category ?? this.category,
    );
  }
}
