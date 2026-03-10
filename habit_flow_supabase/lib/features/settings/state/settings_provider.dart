import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habit_flow/features/settings/models/settings.dart';

class SettingsNotifier extends AsyncNotifier<Settings> {
  static const _themeKey = 'theme';
  static const _notificationsOnKey = 'notificationsOn';
  static const _reminderTimeKey = 'reminderTime';
  static const _syncTypeKey = 'syncType';

  @override
  Future<Settings> build() async {
    final prefs = await SharedPreferences.getInstance();

    final themeIndex = prefs.getInt(_themeKey) ?? AppTheme.system.index;
    final notificationsOn = prefs.getBool(_notificationsOnKey) ?? true;
    final reminderTime = prefs.getString(_reminderTimeKey);
    final syncTypeIndex = prefs.getInt(_syncTypeKey) ?? SyncType.auto.index;

    return Settings(
      theme: AppTheme.values[themeIndex],
      notificationsOn: notificationsOn,
      reminderTime: reminderTime,
      syncType: SyncType.values[syncTypeIndex],
    );
  }

  Future<void> setTheme(AppTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, theme.index);

    final current = state.value;
    if (current != null) {
      state = AsyncData(current.copyWith(theme: theme));
    }
  }

  Future<void> setNotificationsOn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsOnKey, value);

    final current = state.value;
    if (current != null) {
      state = AsyncData(current.copyWith(notificationsOn: value));
    }
  }

  Future<void> setReminderTime(String? time) async {
    final prefs = await SharedPreferences.getInstance();
    if (time != null) {
      await prefs.setString(_reminderTimeKey, time);
    } else {
      await prefs.remove(_reminderTimeKey);
    }

    final current = state.value;
    if (current != null) {
      state = AsyncData(current.copyWith(reminderTime: time));
    }
  }

  Future<void> setSyncType(SyncType syncType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_syncTypeKey, syncType.index);

    final current = state.value;
    if (current != null) {
      state = AsyncData(current.copyWith(syncType: syncType));
    }
  }

  Future<void> resetToDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_themeKey);
    await prefs.remove(_notificationsOnKey);
    await prefs.remove(_reminderTimeKey);
    await prefs.remove(_syncTypeKey);

    state = AsyncData(Settings());
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, Settings>(
  SettingsNotifier.new,
);
