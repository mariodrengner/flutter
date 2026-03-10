import 'package:habit_flow/features/habits/models/habits/habit.dart';

class SyncResult {
  SyncResult({
    required this.success,
    required this.syncedCount,
    required this.remoteHabits,
    this.errorMessage,
    this.deletedIds = const [],
  });

  final bool success;
  final int syncedCount;
  final List<Habit> remoteHabits;
  final String? errorMessage;
  final List<String> deletedIds;
}
