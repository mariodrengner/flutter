# 🔧 Fix: User-ID Synchronisation Problem

## Das Problem

```
Sync failed: PostgrestException(message: new row violates row-level security policy for table "habits")
```

### Ursache

Die `user_id` in den Habits stimmt **nicht** mit der Supabase Auth User-ID überein!

**RLS-Policy prüft:**
```sql
auth.uid() = user_id  -- Muss TRUE sein!
```

**Was passiert ist:**
1. Du hast dich als **Guest-User** angemeldet (mit zufälliger UUID)
2. Habits wurden mit dieser **Guest-UUID** erstellt
3. Dann hast du dich **registriert** (neue Supabase Auth UUID)
4. Beim Sync: **Guest-UUID ≠ Supabase Auth UUID** ❌
5. RLS-Policy blockiert den Upload ⛔

## ✅ Lösung: Neu starten mit sauberem Zustand

### Option 1: App-Daten löschen (Empfohlen)

**Im iOS Simulator:**
```bash
# 1. App stoppen (Cmd+.)

# 2. Im Simulator:
#    Settings → Apps → HabitFlow → App löschen

# 3. App neu starten:
flutter run

# 4. ✅ Frischer Start ohne alte Daten
```

**Im Android Emulator:**
```bash
# 1. App stoppen

# 2. Im Emulator:
#    Settings → Apps → HabitFlow → Storage → Clear Data

# 3. App neu starten:
flutter run
```

### Option 2: Hive-Daten manuell löschen

**Via Code:**

Füge dies temporär in `main.dart` ein (vor `initializeHive()`):

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🧹 TEMPORÄR: Hive-Daten löschen
  await Hive.initFlutter();
  await Hive.deleteBoxFromDisk('habits');
  await Hive.deleteBoxFromDisk('user');
  print('🧹 Hive boxes deleted!');
  // ENTFERNE DIESE ZEILEN NACH DEM ERSTEN START!

  await initializeSupabase();
  await initializeHive();

  runApp(const App());
}
```

**Nach dem ersten Start:**
- Entferne die Zeilen wieder
- Hot Restart (R im Terminal)

### Option 3: Flutter Clean

```bash
# Stoppt die App und löscht Build-Artefakte
flutter clean

# Packages neu installieren
flutter pub get

# Code-Generation
dart run build_runner build --delete-conflicting-outputs

# App neu starten
flutter run
```

## 🎯 Nach dem Clean: Richtig starten

### 1. App startet → SplashScreen → Login-Screen

```
👤 Current user: null, Guest: false
➡️  Navigating to login
```

### 2. Auf "Registrieren" klicken

### 3. User registrieren

```
Name: Test User
E-Mail: test@example.com
Passwort: test123
```

**Terminal zeigt:**
```
📝 Signing up user: test@example.com with name: Test User
✅ User signed up successfully: abc-123-456-789
🔄 Profile will be created automatically by trigger
🔑 Creating user with Supabase Auth ID: abc-123-456-789
✅ User saved to Hive with ID: abc-123-456-789
```

### 4. Habits erstellen

```
- "Sport machen"
- "Wasser trinken"
- "Lesen"
```

**Terminal zeigt:**
```
🚀 Starting cloud sync for user: abc-123-456-789
📋 Local habits in box: 3
⏳ Pending habits to sync: 3
```

### 5. Sync-Button drücken

**Terminal zeigt:**
```
🔄 Uploading 3 habits to Supabase...
🔑 Auth User ID: abc-123-456-789
   Habit: Sport machen, user_id: abc-123-456-789 ✅
   Habit: Wasser trinken, user_id: abc-123-456-789 ✅
   Habit: Lesen, user_id: abc-123-456-789 ✅
✅ Upload completed successfully!
```

## 🔍 Debug-Checks

### Überprüfe die User-ID

**Im Terminal nach Registrierung:**
```
🔑 Creating user with Supabase Auth ID: <UUID>
```

**Im Terminal beim Sync:**
```
🔑 Auth User ID: <UUID>
   Habit: ..., user_id: <UUID>
```

**Diese UUIDs MÜSSEN identisch sein!**

### Überprüfe in Supabase

**Profiles Tabelle:**
```sql
SELECT id, name, email FROM auth.users;
```
Notiere die `id` (z.B. `abc-123-456-789`)

**Habits Tabelle:**
```sql
SELECT id, name, user_id FROM public.habits;
```
Die `user_id` MUSS mit der User-ID übereinstimmen!

## ⚠️ Häufige Fehler

### Fehler 1: Guest-User noch aktiv

**Symptom:**
```
👤 Current user: guest@habitflow.local, Guest: true
```

**Lösung:**
- Logout-Button drücken
- Oder App-Daten löschen

### Fehler 2: Alte Habits mit falscher user_id

**Symptom:**
```
Habit: Sport machen, user_id: old-uuid-123
🔑 Auth User ID: new-uuid-456
```

**Lösung:**
- App-Daten löschen (Option 1)
- Neu registrieren
- Neue Habits erstellen

### Fehler 3: Supabase Session abgelaufen

**Symptom:**
```
🔑 Auth User ID: null
```

**Lösung:**
```bash
# Logout und erneut anmelden
# Oder:
flutter clean && flutter run
```

## 🎓 Warum passiert das?

### Guest-Modus vs. Auth-Modus

**Guest-Modus:**
- User-ID = Zufällige UUID (generiert mit `uuid` package)
- Keine Supabase Auth Session
- `guestMode: true`
- Kein Cloud-Sync möglich

**Auth-Modus:**
- User-ID = Supabase Auth User-ID
- Aktive Supabase Auth Session
- `guestMode: false`
- Cloud-Sync möglich

### Das Problem

1. App startet → Kein User vorhanden
2. HabitScreen.initState() → `createGuestUser()` ❌
3. Guest-User hat UUID: `guest-123`
4. Habits werden erstellt mit `user_id: guest-123`
5. User registriert sich → Neue UUID: `auth-456`
6. **Habits haben noch `user_id: guest-123`** ❌
7. Sync schlägt fehl: `guest-123 ≠ auth-456`

### Die Lösung im Code

**Migration der Habits:**
```dart
// lib/features/habits/state/habit_provider.dart:143
Future<void> _migrateHabitsToUser(String userId) async {
  for (final habit in _box.values) {
    if (habit.userId != userId) {
      habit.userId = userId; // 🔧 Korrigiert die user_id
      habit.syncStatus = SyncStatus.pending;
      await habit.save();
    }
  }
}
```

**Diese Funktion sollte die user_id korrigieren!**

Aber wenn ein Guest-User vorhanden ist und du dich neu registrierst, könnte es sein, dass die Migration nicht korrekt läuft.

## ✅ Empfohlener Workflow

### Für Entwicklung/Tests:

1. **Immer** mit sauberem Zustand starten
2. **Nicht** als Guest anmelden
3. **Direkt** registrieren
4. Habits erstellen
5. Synchronisieren

### Bei Problemen:

```bash
# 1. App stoppen
# 2. App-Daten löschen (Simulator/Emulator)
# 3. flutter clean
# 4. flutter run
# 5. Registrieren (nicht als Guest!)
# 6. Habits erstellen
# 7. Sync → ✅ Erfolg!
```

## 🎉 Zusammenfassung

**Problem:** User-ID Mismatch zwischen Hive und Supabase Auth
**Ursache:** Guest-User wurde vor Registrierung erstellt
**Lösung:** App-Daten löschen und sauber neu starten
**Prävention:** Nicht als Guest anmelden für Tests

Nach dem Clean-Start sollte alles funktionieren! 🚀
