# Sync-Funktionalität - Dokumentation

## Übersicht

Die HabitFlow App verwendet eine **Offline-First Architektur** mit automatischer Cloud-Synchronisation zu Supabase.

## Sync-Button

Der Sync-Button befindet sich oben rechts in der AppBar:
- **Icon**: `Icons.sync`
- **Location**: `lib/features/habits/ui/widgets/habit_app_bar_actions.dart:37`
- **Funktion**: Synchronisiert lokale Habits mit der Supabase-Datenbank

## Wie die Synchronisation funktioniert

### 1. Initialer Sync beim App-Start

Wenn ein authentifizierter User die App startet:
```dart
// lib/features/habits/ui/screens/habit_screen.dart:26
Future<void> _initializeAndSync() async {
  final user = ref.read(authProvider);
  if (user == null) {
    await ref.read(authProvider.notifier).createGuestUser();
  } else if (!user.guestMode) {
    await ref.read(habitProvider.notifier).syncToCloud();
  }
}
```

### 2. Manueller Sync über den Sync-Button

```dart
// lib/features/habits/ui/screens/habit_screen.dart:35
Future<void> _syncHabits() async {
  final ui = ref.read(habitUiProvider.notifier);
  final user = ref.read(authProvider);

  // Guest-User können nicht synchronisieren
  if (user == null || user.guestMode) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Melde dich an, um zu synchronisieren')),
    );
    return;
  }

  ui.setSyncing(true);
  final success = await ref.read(habitProvider.notifier).syncToCloud();
  ui.setSyncing(false);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        success ? 'Synchronisierung erfolgreich' : 'Synchronisierung fehlgeschlagen',
      ),
    ),
  );
}
```

### 3. Sync-Logik im HabitNotifier

```dart
// lib/features/habits/state/habit_provider.dart:95
Future<bool> syncToCloud() async {
  final user = ref.read(authProvider);
  if (user == null || user.guestMode) return false;

  await _migrateHabitsToUser(user.id);

  final localHabits = _box.values.toList();
  final pendingHabits = localHabits
      .where((h) => h.syncStatus == SyncStatus.pending)
      .toList();

  // Wenn keine pending Habits vorhanden sind, Daten aus Cloud abrufen
  if (pendingHabits.isEmpty) {
    await fetchFromCloud();
    return true;
  }

  // Pending Habits zu Supabase hochladen
  final result = await _syncService.syncHabits(
    userId: user.id,
    localHabits: localHabits,
  );

  if (result.success) {
    await _markHabitsSynced(pendingHabits);
    await _removeDeletedHabits(result.deletedIds);
    await _mergeRemoteHabits(result.remoteHabits);
    await _removeLocalHabitsNotInRemote(result.remoteHabits);
    _refreshState();
    return true;
  }

  await _markHabitsError(pendingHabits);
  _refreshState();
  return false;
}
```

## Sync-Status

Jedes Habit hat einen `SyncStatus`:
- **`synced`**: Habit ist mit Cloud synchronisiert
- **`pending`**: Habit wartet auf Synchronisation
- **`error`**: Fehler bei der Synchronisation

## Guest-Modus

**Wichtig**: Im Guest-Modus gibt es KEINE Cloud-Synchronisation!

- Guest-User werden nur lokal in Hive gespeichert
- `guestMode: true` verhindert Sync-Operationen
- Beim Drücken des Sync-Buttons erscheint: "Melde dich an, um zu synchronisieren"

## Supabase-Tabellen

### `habits` Tabelle

Schema:
```sql
CREATE TABLE habits (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  is_active BOOLEAN DEFAULT true,
  completed_dates TIMESTAMP[],
  current_streak INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### `profiles` Tabelle

Wird automatisch beim Sign-Up erstellt:
```sql
CREATE TABLE profiles (
  id UUID PRIMARY KEY,
  name TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

## Konfliktlösung

**Remote gewinnt**: Wenn `updatedAt` des Remote-Habits neuer ist, wird das Remote-Habit übernommen.

```dart
// lib/features/habits/state/habit_provider.dart:189
if (!remote.updatedAt.isAfter(local.updatedAt)) continue;
```

## Auto-Sync

Auto-Sync kann in den Einstellungen aktiviert werden:
- **`SyncType.auto`**: Sync nach jeder Änderung
- **`SyncType.manual`**: Nur manueller Sync über Button

```dart
// lib/features/habits/state/habit_provider.dart:88
Future<void> _syncIfAuto() async {
  final settings = await ref.read(settingsProvider.future);
  if (settings.syncType == SyncType.auto) {
    await syncToCloud();
  }
}
```

## Fehlerbehandlung

- Netzwerkfehler: Habits bleiben `pending`, können später synchronisiert werden
- Authentifizierungsfehler: User wird abgemeldet
- Datenbankfehler: Fehler wird geloggt, Sync schlägt fehl

## Testing

Um die Sync-Funktionalität zu testen:

1. **Guest-User testen**:
   - App starten ohne Login
   - Sync-Button drücken
   - Erwartung: "Melde dich an, um zu synchronisieren"

2. **Authentifizierter User**:
   - Registrieren/Anmelden
   - Habit erstellen
   - Sync-Button drücken
   - In Supabase Dashboard überprüfen, ob Habit gespeichert wurde

3. **Daten aus Cloud abrufen**:
   - Auf anderem Gerät/nach App-Neuinstallation anmelden
   - Sync-Button drücken
   - Erwartung: Habits werden aus Cloud geladen
