# Sync-Test Anleitung - Daten zu Supabase hochladen

Diese Anleitung führt dich Schritt für Schritt durch den Prozess, um Habits zu erstellen und mit Supabase zu synchronisieren.

## Voraussetzungen

1. ✅ `.env` Datei mit Supabase-Credentials vorhanden
2. ✅ Supabase-Projekt erstellt mit den Tabellen:
   - `profiles` (id, name, created_at, updated_at)
   - `habits` (id, user_id, name, description, is_active, completed_dates, current_streak, created_at, updated_at)

## Schritt 1: App starten

```bash
flutter run -d <device-id>
```

Die App startet mit dem Splash Screen (3 Sekunden) und navigiert dann zum Login Screen.

## Schritt 2: Neuen User registrieren

1. Klicke auf **"Registrieren"** am unteren Bildschirmrand
2. Fülle das Registrierungsformular aus:
   - **Name**: (optional) z.B. "Test User"
   - **E-Mail**: z.B. "test@example.com"
   - **Passwort**: mindestens 6 Zeichen
   - **Passwort bestätigen**: gleiches Passwort
3. Klicke auf **"Registrieren"**

### Was passiert im Hintergrund:
- Supabase Auth erstellt den User
- Ein Eintrag in der `profiles` Tabelle wird erstellt
- Der User wird automatisch eingeloggt
- Navigation zur Home Screen
- **Automatischer Sync** wird gestartet (falls Auto-Sync aktiviert)

### Debug-Output im Terminal:
```
🚀 Starting cloud sync for user: <user-id>
📋 Local habits in box: 0
⏳ Pending habits to sync: 0
📥 No pending habits, fetching from cloud...
📥 Fetching habits for user: <user-id>
📦 Received 0 habits from Supabase
```

## Schritt 3: Habits erstellen

1. Auf dem Home Screen (HabitScreen) siehst du:
   - AppBar mit "Habit Flow" Titel
   - Sync-Button (Icons.sync) oben rechts
   - Leere Liste mit "Noch keine Habits vorhanden"
   - Textfeld am unteren Rand zum Hinzufügen von Habits

2. Erstelle mehrere Habits:
   - Gebe "Sport machen" ein und drücke das Plus-Icon
   - Gebe "Wasser trinken" ein und drücke das Plus-Icon
   - Gebe "Lesen" ein und drücke das Plus-Icon

### Was passiert im Hintergrund:
- Jedes Habit wird in Hive gespeichert
- `syncStatus` wird auf `SyncStatus.pending` gesetzt
- Wenn **Auto-Sync aktiviert** ist, wird nach jedem Habit automatisch synchronisiert

### Debug-Output im Terminal:
```
(Nach Erstellen eines Habits bei Auto-Sync)
🚀 Starting cloud sync for user: <user-id>
📋 Local habits in box: 1
⏳ Pending habits to sync: 1
🔄 Starting sync for user: <user-id>
📊 Local habits count: 1
⏳ Pending habits: 1
🗑️  Deleted habits: 0
🔄 Uploading 1 habits to Supabase...
📦 Data: [{id: ..., user_id: ..., name: Sport machen, ...}]
✅ Upload completed successfully!
📥 Fetching habits for user: <user-id>
📦 Received 1 habits from Supabase
✅ Sync completed successfully!
✅ Sync successful! Synced 1 habits
```

## Schritt 4: Manueller Sync mit Sync-Button

Falls Auto-Sync deaktiviert ist oder du manuell synchronisieren möchtest:

1. Klicke auf den **Sync-Button** (Icons.sync) oben rechts in der AppBar
2. Du siehst kurz einen CircularProgressIndicator
3. Eine SnackBar erscheint mit:
   - ✅ "Synchronisierung erfolgreich" (bei Erfolg)
   - ❌ "Synchronisierung fehlgeschlagen" (bei Fehler)

### Debug-Output im Terminal:
```
🚀 Starting cloud sync for user: <user-id>
📋 Local habits in box: 3
⏳ Pending habits to sync: 3
🔄 Starting sync for user: <user-id>
📊 Local habits count: 3
⏳ Pending habits: 3
🗑️  Deleted habits: 0
🔄 Uploading 3 habits to Supabase...
📦 Data: [
  {id: abc-123, user_id: xyz-789, name: Sport machen, description: null, is_active: true, completed_dates: [], current_streak: 0, created_at: 2025-12-21T..., updated_at: 2025-12-21T...},
  {id: def-456, user_id: xyz-789, name: Wasser trinken, ...},
  {id: ghi-789, user_id: xyz-789, name: Lesen, ...}
]
✅ Upload completed successfully!
📥 Fetching habits for user: <user-id>
📦 Received 3 habits from Supabase
✅ Sync completed successfully!
✅ Sync successful! Synced 3 habits
```

## Schritt 5: In Supabase überprüfen

1. Öffne dein Supabase Dashboard: https://supabase.com/dashboard
2. Navigiere zu deinem Projekt
3. Gehe zu **Table Editor** → **habits**
4. Du solltest jetzt deine 3 Habits sehen:

| id | user_id | name | description | is_active | completed_dates | current_streak | created_at | updated_at |
|----|---------|------|-------------|-----------|-----------------|----------------|------------|------------|
| abc-123 | xyz-789 | Sport machen | null | true | [] | 0 | 2025-12-21... | 2025-12-21... |
| def-456 | xyz-789 | Wasser trinken | null | true | [] | 0 | 2025-12-21... | 2025-12-21... |
| ghi-789 | xyz-789 | Lesen | null | true | [] | 0 | 2025-12-21... | 2025-12-21... |

5. Überprüfe auch die **profiles** Tabelle:

| id | name | created_at | updated_at |
|----|------|------------|------------|
| xyz-789 | Test User | 2025-12-21... | 2025-12-21... |

## Schritt 6: Sync von Supabase zu App testen

Um zu testen, ob Daten aus Supabase geladen werden:

### Option A: In Supabase neue Habits hinzufügen

1. Gehe zu **Table Editor** → **habits**
2. Klicke auf **Insert row**
3. Fülle die Felder aus:
   - `id`: Generiere eine UUID (oder nutze einen UUID-Generator)
   - `user_id`: Kopiere die User-ID aus der `profiles` Tabelle
   - `name`: z.B. "Meditieren"
   - `is_active`: true
   - `completed_dates`: []
   - `current_streak`: 0
4. Klicke auf **Save**

5. In der App: Drücke den **Sync-Button**
6. Das neue Habit "Meditieren" sollte jetzt in der App erscheinen

### Option B: App neu starten

1. Stoppe die App
2. Lösche die App-Daten (Hive-Boxen)
3. Starte die App neu
4. Melde dich mit demselben Account an
5. Alle Habits werden aus Supabase geladen

## Troubleshooting

### Problem: "Melde dich an, um zu synchronisieren"

**Ursache**: Du bist als Guest-User angemeldet

**Lösung**:
- Logout und melde dich mit einem echten Account an
- Oder registriere einen neuen Account

### Problem: Sync schlägt fehl

**Debug-Output prüfen**:
```
❌ Sync failed: <error-message>
```

**Häufige Fehler**:

1. **Supabase-Credentials falsch**
   - Überprüfe `.env` Datei
   - `SUPABASE_URL` und `SUPABASE_ANON_KEY` korrekt?

2. **Tabelle existiert nicht**
   - Überprüfe in Supabase, ob die `habits` Tabelle existiert
   - Schema korrekt?

3. **Permissions-Fehler**
   - Row Level Security (RLS) policies prüfen
   - User hat Schreibrechte auf `habits` Tabelle?

4. **Netzwerkfehler**
   - Internetverbindung vorhanden?
   - Supabase-Server erreichbar?

### Problem: Keine Debug-Ausgaben

**Lösung**:
- Terminal beobachten, nicht den Emulator
- `flutter run` im Terminal ausführen
- Debug-Mode verwenden (nicht Release)

## Auto-Sync Einstellungen

Auto-Sync kann in den Einstellungen aktiviert/deaktiviert werden:

- **Auto-Sync aktiviert**: Sync nach jeder Änderung (addHabit, updateHabit, deleteHabit, toggleHabitCompletion)
- **Auto-Sync deaktiviert**: Nur manueller Sync über Sync-Button

Settings befinden sich in `SharedPreferences` unter dem Key `syncType`:
- `SyncType.auto` (Index: 0)
- `SyncType.manual` (Index: 1)

## Wichtige Code-Stellen

- **Sync-Button**: `lib/features/habits/ui/widgets/habit_app_bar_actions.dart:37`
- **Sync-Methode**: `lib/features/habits/ui/screens/habit_screen.dart:35`
- **HabitNotifier.syncToCloud()**: `lib/features/habits/state/habit_provider.dart:95`
- **HabitSyncService**: `lib/features/habits/services/habit_sync_service.dart`

## Erwartetes Ergebnis

Nach erfolgreichem Test:

✅ User kann sich registrieren
✅ Habits werden lokal in Hive gespeichert
✅ Habits werden zu Supabase hochgeladen (manuell oder auto)
✅ Habits sind in Supabase-Tabelle sichtbar
✅ Habits können aus Supabase geladen werden
✅ Debug-Output zeigt alle Sync-Schritte
