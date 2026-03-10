import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_flow/core/services/supabase_service.dart';
import 'package:habit_flow/core/models/sync_status.dart';
import 'package:habit_flow/features/habits/models/habits/habit.dart';
import 'package:habit_flow/features/habits/models/sync_result/sync_result.dart';

class HabitSyncService {
  HabitSyncService(this._supabase);

  final SupabaseService _supabase;

  Future<void> upsertHabit(Habit habit) async {
    final json = habit.toJson();
    await _supabase.habits().upsert(json, onConflict: 'id');
  }

  Future<void> upsertHabits(List<Habit> habits) async {
    if (habits.isEmpty) return;

    final data = habits.map((h) => h.toJson()).toList();
    print('🔄 Uploading ${habits.length} habits to Supabase...');
    print('📦 Data: $data');
    print('🔑 Auth User ID: ${_supabase.currentUser?.id}');

    // Überprüfe, ob alle habits die richtige user_id haben
    for (var habit in habits) {
      print('   Habit: ${habit.name}, user_id: ${habit.userId}');
    }

    await _supabase.habits().upsert(data, onConflict: 'id');
    print('✅ Upload completed successfully!');
  }

  Future<void> deleteHabit(String habitId) async {
    await _supabase.habits().delete().eq('id', habitId);
  }

  Future<List<Habit>> fetchHabitsForUser(String userId) async {
    print('📥 Fetching habits for user: $userId');
    final response = await _supabase
        .habits()
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    print('📦 Received ${(response as List<dynamic>).length} habits from Supabase');
    return (response as List<dynamic>).map((json) {
      final habit = Habit.fromJson(json as Map<String, dynamic>);
      habit.syncStatus = SyncStatus.synced;
      return habit;
    }).toList();
  }

  Future<List<Habit>> fetchUpdatedHabits(String userId, DateTime since) async {
    final response = await _supabase
        .habits()
        .select()
        .eq('user_id', userId)
        .gt('updated_at', since.toUtc().toIso8601String())
        .order('updated_at', ascending: false);

    return (response as List<dynamic>).map((json) {
      final habit = Habit.fromJson(json as Map<String, dynamic>);
      habit.syncStatus = SyncStatus.synced;
      return habit;
    }).toList();
  }

  Future<void> deleteHabits(List<String> habitIds) async {
    if (habitIds.isEmpty) return;
    await _supabase.habits().delete().inFilter('id', habitIds);
  }

  Future<SyncResult> syncHabits({
    required String userId,
    required List<Habit> localHabits,
    DateTime? lastSyncTime,
  }) async {
    try {
      print('🔄 Starting sync for user: $userId');
      print('📊 Local habits count: ${localHabits.length}');

      final pendingHabits = localHabits
          .where((h) => h.syncStatus == SyncStatus.pending && h.isActive)
          .toList();

      final deletedHabits = localHabits
          .where((h) => h.syncStatus == SyncStatus.pending && !h.isActive)
          .toList();

      print('⏳ Pending habits: ${pendingHabits.length}');
      print('🗑️  Deleted habits: ${deletedHabits.length}');

      if (pendingHabits.isNotEmpty) {
        await upsertHabits(pendingHabits);
      }

      if (deletedHabits.isNotEmpty) {
        await deleteHabits(deletedHabits.map((h) => h.id).toList());
      }

      final remoteHabits = lastSyncTime != null
          ? await fetchUpdatedHabits(userId, lastSyncTime)
          : await fetchHabitsForUser(userId);

      print('✅ Sync completed successfully!');
      return SyncResult(
        success: true,
        syncedCount: pendingHabits.length + deletedHabits.length,
        remoteHabits: remoteHabits,
        deletedIds: deletedHabits.map((h) => h.id).toList(),
      );
    } catch (e) {
      print('❌ Sync failed: $e');
      return SyncResult(
        success: false,
        errorMessage: e.toString(),
        syncedCount: 0,
        remoteHabits: [],
      );
    }
  }
}

final habitSyncServiceProvider = Provider<HabitSyncService>((ref) {
  final supabase = ref.watch(supabaseServiceProvider);
  return HabitSyncService(supabase);
});
