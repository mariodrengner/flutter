# ⚡ SCHNELLFIX: User-ID Problem

## Das Problem
```
Sync failed: new row violates row-level security policy for table "habits"
```

## Die Lösung (2 Minuten)

### Schritt 1: App-Daten löschen

**iOS Simulator:**
```
1. App stoppen (Cmd+. oder flutter app beenden)
2. Im Simulator: Settings → Apps → HabitFlow
3. App löschen
```

**Android Emulator:**
```
1. App stoppen
2. Settings → Apps → HabitFlow → Storage → Clear Data
```

### Schritt 2: App neu starten

```bash
flutter run
```

### Schritt 3: DIREKT registrieren (NICHT als Gast!)

```
1. App startet → SplashScreen (3 Sek.) → Login-Screen
2. Klicke auf "Registrieren"
3. Registriere dich:
   - E-Mail: test@example.com
   - Passwort: test123
   - Name: Test User
4. Klicke "Registrieren"
```

### Schritt 4: Terminal beobachten

Du solltest sehen:
```
📝 Signing up user: test@example.com with name: Test User
✅ User signed up successfully: <UUID-A>
🔑 Creating user with Supabase Auth ID: <UUID-A>
✅ User saved to Hive with ID: <UUID-A>
```

### Schritt 5: Habits erstellen

```
- "Sport machen"
- "Wasser trinken"
- "Lesen"
```

### Schritt 6: Sync-Button drücken

Terminal zeigt:
```
🔄 Uploading 3 habits to Supabase...
🔑 Auth User ID: <UUID-A>
   Habit: Sport machen, user_id: <UUID-A> ✅
   Habit: Wasser trinken, user_id: <UUID-A> ✅
   Habit: Lesen, user_id: <UUID-A> ✅
✅ Upload completed successfully!
```

## ✅ Erfolg!

SnackBar zeigt: **"Synchronisierung erfolgreich"** 🎉

## 🔑 Der Schlüssel

**ALLE UUIDs müssen IDENTISCH sein:**
- Supabase Auth User-ID
- Hive User-ID
- Habit user_id

Wenn du als Guest startest, stimmen die IDs nicht überein!

## ⚠️ Vermeide

- ❌ NICHT als Gast starten
- ❌ NICHT alte App-Daten behalten
- ❌ NICHT zwischen Guest und Auth wechseln

## ✅ Mache

- ✅ App-Daten löschen
- ✅ Direkt registrieren
- ✅ Habits erstellen
- ✅ Synchronisieren

## 📚 Mehr Details

Siehe `FIX_USER_ID.md` für ausführliche Erklärung.
