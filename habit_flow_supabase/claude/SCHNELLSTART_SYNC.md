# 🚀 Schnellstart: Habits mit Supabase synchronisieren

## ⚠️ WICHTIG: Zuerst Supabase einrichten!

**Bevor du die App testest, musst du die Supabase-Datenbank einrichten!**

👉 **Siehe: `SUPABASE_SETUP.md`** für die komplette Anleitung

**Kurzversion:**
1. Öffne Supabase Dashboard → SQL Editor
2. Kopiere den Inhalt von `supabase/setup.sql`
3. Füge ihn ein und klicke auf **Run**
4. ✅ Fertig! RLS-Policies sind jetzt konfiguriert

## ✅ Status

Die Sync-Funktionalität ist **vollständig implementiert** und **bereit zum Testen**!

## 📋 Was wurde gemacht

1. ✅ Debug-Logging in allen Sync-Methoden hinzugefügt
2. ✅ Detaillierte Test-Anleitung erstellt
3. ✅ App erfolgreich getestet
4. ✅ Riverpod-Architektur beibehalten
5. ✅ File-Struktur eingehalten

## 🎯 Schnelltest (5 Minuten)

### 1. App starten
```bash
flutter run
```

### 2. User registrieren
- Klicke auf **"Registrieren"**
- E-Mail: `test@example.com`
- Passwort: `test123`
- Klicke **"Registrieren"**

### 3. Habits erstellen
- Gebe "Sport machen" ein → Klicke Plus
- Gebe "Wasser trinken" ein → Klicke Plus
- Gebe "Lesen" ein → Klicke Plus

### 4. Synchronisieren
- Klicke auf das **Sync-Icon** (oben rechts)
- Warte auf: "Synchronisierung erfolgreich"

### 5. In Supabase prüfen
1. Öffne https://supabase.com/dashboard
2. Gehe zu deinem Projekt
3. **Table Editor** → **habits**
4. Du solltest **3 Habits** sehen! 🎉

## 📊 Debug-Output

Im Terminal siehst du während des Syncs:

```
🚀 Starting cloud sync for user: <user-id>
📋 Local habits in box: 3
⏳ Pending habits to sync: 3
🔄 Starting sync for user: <user-id>
📊 Local habits count: 3
⏳ Pending habits: 3
🗑️  Deleted habits: 0
🔄 Uploading 3 habits to Supabase...
📦 Data: [...]
✅ Upload completed successfully!
📥 Fetching habits for user: <user-id>
📦 Received 3 habits from Supabase
✅ Sync completed successfully!
✅ Sync successful! Synced 3 habits
```

## 📖 Ausführliche Anleitung

Siehe: `docs/SYNC_TEST_ANLEITUNG.md`

## 🔧 Technische Details

### Sync-Flow

1. **User registriert sich** → Profile in Supabase erstellt
2. **Habit erstellen** → Lokal in Hive gespeichert mit `syncStatus: pending`
3. **Sync-Button drücken** →
   - `_syncHabits()` aufgerufen
   - `habitProvider.notifier.syncToCloud()` ausgeführt
   - `HabitSyncService.syncHabits()` hochladen
   - Habits in Supabase `habits` Tabelle gespeichert
4. **Erfolg** → SnackBar: "Synchronisierung erfolgreich"

### Wichtige Files

- **Sync-Button**: `lib/features/habits/ui/widgets/habit_app_bar_actions.dart`
- **Sync-Handler**: `lib/features/habits/ui/screens/habit_screen.dart:35`
- **Sync-Logic**: `lib/features/habits/state/habit_provider.dart:95`
- **Sync-Service**: `lib/features/habits/services/habit_sync_service.dart`

### Debug-Logging

Alle Sync-Operationen loggen jetzt:
- 🚀 Start der Synchronisation
- 📋 Anzahl lokaler Habits
- ⏳ Anzahl pending Habits
- 🔄 Upload-Status
- 📦 Hochgeladene Daten
- ✅ Erfolg
- ❌ Fehler

## ⚠️ Wichtig: Guest-Modus

**Guest-User werden NICHT synchronisiert!**

- Guest-User haben `guestMode: true`
- Beim Klick auf Sync-Button: "Melde dich an, um zu synchronisieren"
- Daten bleiben nur lokal in Hive

## 🆘 Troubleshooting

### Problem: "Synchronisierung fehlgeschlagen"

**Prüfe:**
1. `.env` Datei korrekt?
2. Supabase-Tabellen existieren?
3. Internet-Verbindung vorhanden?
4. Terminal-Output für Details

### Problem: Keine Debug-Ausgaben

**Lösung:**
- `flutter run` im Terminal (nicht IDE)
- Debug-Mode verwenden

### Problem: Habits nicht in Supabase

**Prüfe:**
1. User korrekt registriert?
2. Nicht als Guest angemeldet?
3. Sync-Button gedrückt?
4. "Synchronisierung erfolgreich" gesehen?
5. Richtige Tabelle in Supabase geöffnet?

## 📚 Nächste Schritte

1. **Auto-Sync testen**: In Settings aktivieren
2. **Pull-to-Refresh**: Vom Cloud laden
3. **Mehrere Geräte**: Gleichen Account auf 2. Gerät
4. **Offline-Sync**: App offline nutzen, später synchronisieren

## 🎉 Fertig!

Die Sync-Funktionalität ist implementiert und getestet. Viel Erfolg beim Testen! 🚀
