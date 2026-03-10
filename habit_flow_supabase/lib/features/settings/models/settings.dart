enum AppTheme { light, dark, system }

enum SyncType { manual, auto }

class Settings {
  Settings({
    this.theme = AppTheme.system,
    this.notificationsOn = true,
    this.reminderTime,
    this.syncType = SyncType.auto,
  });

  final AppTheme theme;
  final bool notificationsOn;
  final String? reminderTime;
  final SyncType syncType;

  Settings copyWith({
    AppTheme? theme,
    bool? notificationsOn,
    String? reminderTime,
    SyncType? syncType,
  }) {
    return Settings(
      theme: theme ?? this.theme,
      notificationsOn: notificationsOn ?? this.notificationsOn,
      reminderTime: reminderTime ?? this.reminderTime,
      syncType: syncType ?? this.syncType,
    );
  }
}
