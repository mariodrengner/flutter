import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:habit_flow/core/models/sync_status.dart';
import 'package:habit_flow/features/habits/models/habits/habit.dart';
import 'package:habit_flow/features/habits/services/habit_sync_service.dart';
import 'package:habit_flow/features/settings/state/settings_provider.dart';
import 'package:habit_flow/features/settings/models/settings.dart';
import 'package:habit_flow/features/auth/state/auth/auth_provider.dart';

class HabitNotifier extends Notifier<List<Habit>> {
  late Box<Habit> _box;

  HabitSyncService get _syncService => ref.read(habitSyncServiceProvider);

  @override
  List<Habit> build() {
    _box = Hive.box<Habit>('habits');
    try {
      return _box.values.where((h) => h.isActive).toList();
    } catch (e) {
      // Handle corrupted data by clearing the box
      _box.clear();
      return [];
    }
  }

  Future<void> addHabit({
    required String userId,
    required String name,
    String? description,
  }) async {
    final habit = Habit(
      id: const Uuid().v4(),
      userId: userId,
      name: name,
      description: description,
      syncStatus: SyncStatus.pending,
    );
    await _box.put(habit.id, habit);
    state = _box.values.where((h) => h.isActive).toList();
    await _syncIfAuto();
  }

  Future<void> updateHabit(
    String id, {
    String? name,
    String? description,
  }) async {
    final habit = _box.get(id);
    if (habit != null) {
      if (name != null) habit.name = name;
      if (description != null) habit.description = description;
      habit.syncStatus = SyncStatus.pending;
      habit.updatedAt = DateTime.now();
      await habit.save();
      state = _box.values.where((h) => h.isActive).toList();
      await _syncIfAuto();
    }
  }

  Future<void> deleteHabit(String id) async {
    final habit = _box.get(id);
    if (habit != null) {
      habit.isActive = false;
      habit.syncStatus = SyncStatus.pending;
      habit.updatedAt = DateTime.now();
      await habit.save();
      state = _box.values.where((h) => h.isActive).toList();
      await _syncIfAuto();
    }
  }

  Future<void> toggleHabitCompletion(String id) async {
    final habit = _box.get(id);
    if (habit != null) {
      if (habit.isCompletedToday) {
        habit.unmarkCompleted();
      } else {
        habit.markCompleted();
      }
      await habit.save();
      state = _box.values.where((h) => h.isActive).toList();
      await _syncIfAuto();
    }
  }

  Future<void> _syncIfAuto() async {
    final settings = await ref.read(settingsProvider.future);
    if (settings.syncType == SyncType.auto) {
      await syncToCloud();
    }
  }

  Future<bool> syncToCloud() async {
    final user = ref.read(authProvider);
    if (user == null || user.guestMode) {
      print('⚠️  Cannot sync: User is null or in guest mode');
      return false;
    }

    print('🚀 Starting cloud sync for user: ${user.id}');
    await _migrateHabitsToUser(user.id);

    final localHabits = _box.values.toList();
    final pendingHabits = localHabits
        .where((h) => h.syncStatus == SyncStatus.pending)
        .toList();

    print('📋 Local habits in box: ${localHabits.length}');
    print('⏳ Pending habits to sync: ${pendingHabits.length}');

    if (pendingHabits.isEmpty) {
      print('📥 No pending habits, fetching from cloud...');
      await fetchFromCloud();
      return true;
    }

    final result = await _syncService.syncHabits(
      userId: user.id,
      localHabits: localHabits,
    );

    if (result.success) {
      print('✅ Sync successful! Synced ${result.syncedCount} habits');
      await _markHabitsSynced(pendingHabits);
      await _removeDeletedHabits(result.deletedIds);
      await _mergeRemoteHabits(result.remoteHabits);
      await _removeLocalHabitsNotInRemote(result.remoteHabits);
      _refreshState();
      return true;
    }

    print('❌ Sync failed: ${result.errorMessage}');
    await _markHabitsError(pendingHabits);
    _refreshState();
    return false;
  }

  Future<void> fetchFromCloud() async {
    final user = ref.read(authProvider);
    if (user == null || user.guestMode) return;

    final remoteHabits = await _syncService.fetchHabitsForUser(user.id);
    await _mergeRemoteHabits(remoteHabits, skipPending: true);
    await _removeLocalHabitsNotInRemote(remoteHabits);
    _refreshState();
  }

  Future<void> _migrateHabitsToUser(String userId) async {
    for (final habit in _box.values) {
      if (habit.userId != userId) {
        habit.userId = userId;
        habit.syncStatus = SyncStatus.pending;
        await habit.save();
      }
    }
  }

  Future<void> _markHabitsSynced(List<Habit> habits) async {
    for (final habit in habits) {
      habit.syncStatus = SyncStatus.synced;
      await habit.save();
    }
  }

  Future<void> _markHabitsError(List<Habit> habits) async {
    for (final habit in habits) {
      habit.syncStatus = SyncStatus.error;
      await habit.save();
    }
  }

  Future<void> _removeDeletedHabits(List<String> ids) async {
    for (final id in ids) {
      await _box.delete(id);
    }
  }

  Future<void> _removeLocalHabitsNotInRemote(List<Habit> remoteHabits) async {
    final remoteIds = remoteHabits.map((h) => h.id).toSet();
    final localHabits = _box.values.toList();

    for (final local in localHabits) {
      if (local.syncStatus == SyncStatus.pending) continue;
      if (!remoteIds.contains(local.id)) {
        await _box.delete(local.id);
      }
    }
  }

  Future<void> _mergeRemoteHabits(
    List<Habit> remoteHabits, {
    bool skipPending = false,
  }) async {
    for (final remote in remoteHabits) {
      final local = _box.get(remote.id);

      if (local == null) {
        remote.syncStatus = SyncStatus.synced;
        await _box.put(remote.id, remote);
        continue;
      }

      if (skipPending && local.syncStatus == SyncStatus.pending) continue;
      if (!remote.updatedAt.isAfter(local.updatedAt)) continue;

      local
        ..name = remote.name
        ..description = remote.description
        ..isActive = remote.isActive
        ..completedDates = remote.completedDates
        ..currentStreak = remote.currentStreak
        ..updatedAt = remote.updatedAt
        ..syncStatus = SyncStatus.synced;
      await local.save();
    }
  }

  void _refreshState() {
    state = _box.values.where((h) => h.isActive).toList();
  }

  int get completedTodayCount => state.where((h) => h.isCompletedToday).length;

  int get totalCount => state.length;

  String get progressText => '$completedTodayCount von $totalCount erledigt';
}

final habitProvider = NotifierProvider<HabitNotifier, List<Habit>>(
  HabitNotifier.new,
);
