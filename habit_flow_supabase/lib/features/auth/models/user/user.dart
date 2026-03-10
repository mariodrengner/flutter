import 'package:hive_ce/hive.dart';
import 'package:habit_flow/core/models/sync_status.dart';

part 'user.g.dart';

@HiveType(typeId: 2)
class User extends HiveObject {
  User({
    required this.id,
    required this.email,
    this.name,
    this.guestMode = true,
    this.syncStatus = SyncStatus.synced,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  @HiveField(0)
  String id;

  @HiveField(1)
  String email;

  @HiveField(2)
  String? name;

  @HiveField(3)
  bool guestMode;

  @HiveField(4)
  SyncStatus syncStatus;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime updatedAt;

  bool get isAuthenticated => !guestMode;
}
