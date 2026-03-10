import 'package:hive_ce/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:habit_flow/core/models/sync_status.dart';

part 'habit.g.dart';

@HiveType(typeId: 1)
@JsonSerializable(explicitToJson: true)
class Habit extends HiveObject {
  Habit({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.isActive = true,
    this.completedDates = const [],
    this.currentStreak = 0,
    this.syncStatus = SyncStatus.synced,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Habit.fromJson(Map<String, dynamic> json) => _$HabitFromJson(json);

  @HiveField(0)
  @JsonKey(name: 'id')
  String id;

  @HiveField(1)
  @JsonKey(name: 'user_id')
  String userId;

  @HiveField(2)
  @JsonKey(name: 'name')
  String name;

  @HiveField(3)
  @JsonKey(name: 'description')
  String? description;

  @HiveField(4)
  @JsonKey(name: 'is_active')
  bool isActive;

  @HiveField(5)
  @JsonKey(name: 'completed_dates')
  List<DateTime> completedDates;

  @HiveField(6)
  @JsonKey(name: 'current_streak')
  int currentStreak;

  @HiveField(7)
  @JsonKey(includeFromJson: false, includeToJson: false)
  SyncStatus syncStatus;

  @HiveField(8)
  @JsonKey(name: 'created_at')
  DateTime createdAt;

  @HiveField(9)
  @JsonKey(name: 'updated_at')
  DateTime updatedAt;

  Map<String, dynamic> toJson() {
    final json = _$HabitToJson(this);
    json['created_at'] = createdAt.toUtc().toIso8601String();
    json['updated_at'] = updatedAt.toUtc().toIso8601String();
    json['completed_dates'] = completedDates
        .map((e) => e.toUtc().toIso8601String())
        .toList();
    return json;
  }

  bool get isCompletedToday {
    final today = DateTime.now();
    return completedDates.any(
      (d) =>
          d.year == today.year && d.month == today.month && d.day == today.day,
    );
  }

  void markCompleted() {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    if (!isCompletedToday) {
      completedDates = [...completedDates, todayOnly];
      syncStatus = SyncStatus.pending;
      updatedAt = DateTime.now();
    }
  }

  void unmarkCompleted() {
    final today = DateTime.now();
    completedDates = completedDates
        .where(
          (d) =>
              !(d.year == today.year &&
                  d.month == today.month &&
                  d.day == today.day),
        )
        .toList();
    syncStatus = SyncStatus.pending;
    updatedAt = DateTime.now();
  }
}
