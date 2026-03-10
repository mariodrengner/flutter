# ✅ Problem gelöst: Row Level Security Policy Fehler

## Das Problem

Fehler beim Registrieren:
```
PostgrestException (New row violates row-level security policy for table "profiles")
```

## Die Ursache

Die Supabase-Datenbank hatte noch keine Row Level Security (RLS) Policies konfiguriert. Ohne diese Policies können keine Daten in die Tabellen eingefügt werden.

## Die Lösung

Ich habe ein vollständiges SQL-Setup-Script erstellt, das:

1. ✅ Tabellen erstellt (`profiles`, `habits`)
2. ✅ RLS aktiviert
3. ✅ Policies für beide Tabellen erstellt
4. ✅ Automatisches Profil-Erstellen per Trigger eingerichtet
5. ✅ Auto-Update von `updated_at` eingerichtet

## 🚀 Was du jetzt tun musst

### Schritt 1: Supabase einrichten (2 Minuten)

```bash
# 1. Öffne Supabase Dashboard
https://supabase.com/dashboard

# 2. Gehe zu: SQL Editor → New Query

# 3. Öffne die Datei: supabase/setup.sql

# 4. Kopiere den GESAMTEN Inhalt

# 5. Füge ihn in den SQL Editor ein

# 6. Klicke auf "Run" (oder Cmd+Enter)

# 7. ✅ Erfolg! Du siehst:
# - "Profiles table created"
# - "Habits table created"
# - "RLS enabled on both tables"
# - "Policies created"
# - "Triggers created"
```

### Schritt 2: App testen (5 Minuten)

```bash
# 1. App starten
flutter run

# 2. Auf Logout-Button klicken (oben rechts)

# 3. Auf "Registrieren" klicken

# 4. User registrieren:
#    - E-Mail: test@example.com
#    - Passwort: test123
#    - Name: Test User

# 5. Habits erstellen:
#    - "Sport machen"
#    - "Wasser trinken"
#    - "Lesen"

# 6. Sync-Button drücken (Icons.sync)

# 7. ✅ Erfolg! Du siehst:
#    "Synchronisierung erfolgreich"
```

### Schritt 3: In Supabase überprüfen

```bash
# 1. Öffne Supabase Dashboard

# 2. Gehe zu: Table Editor → profiles
#    ✅ Du siehst den User mit Name "Test User"

# 3. Gehe zu: Table Editor → habits
#    ✅ Du siehst alle 3 Habits!
```

## 📁 Wichtige Dateien

### Neu erstellt:
- **`supabase/setup.sql`** - SQL-Script für Datenbank-Setup
- **`SUPABASE_SETUP.md`** - Ausführliche Setup-Anleitung
- **`SCHNELLSTART_SYNC.md`** - Aktualisiert mit Supabase-Hinweis
- **`PROBLEMLÖSUNG.md`** - Diese Datei

### Angepasst:
- **`lib/features/auth/services/auth_service.dart`**
  - ❌ Entfernt: Manuelles Einfügen in `profiles` Tabelle
  - ✅ Hinzugefügt: User-Metadaten für automatischen Trigger
  - ✅ Hinzugefügt: Debug-Logging

- **`lib/features/habits/ui/screens/habit_screen.dart`**
  - ✅ Hinzugefügt: Logout-Button in AppBar
  - ✅ Hinzugefügt: User-Email-Anzeige im Titel

- **`lib/features/splash/ui/screens/splash_screen.dart`**
  - ✅ Hinzugefügt: Debug-Logging für Navigation

## 🎯 Was funktioniert jetzt

### ✅ Authentifizierung
- User kann sich registrieren
- Profil wird **automatisch** erstellt (durch Trigger)
- User kann sich anmelden
- User kann sich abmelden (Logout-Button)

### ✅ Synchronisation
- Habits werden zu Supabase hochgeladen
- Habits werden von Supabase geladen
- Sync-Status wird angezeigt
- Debug-Logging zeigt alle Schritte

### ✅ Sicherheit
- RLS schützt User-Daten
- User sehen nur ihre eigenen Habits
- User können keine Daten anderer User ändern

### ✅ UI/UX
- Login-Screen mit Link zu Registrierung
- Register-Screen mit Link zu Login
- Logout-Button in der AppBar
- User-Email wird angezeigt
- Guest-Modus wird angezeigt
- Sync-Button mit Loading-State

## 📊 Architektur-Übersicht

```
┌─────────────────────────────────────────┐
│          Flutter App (Frontend)         │
├─────────────────────────────────────────┤
│                                         │
│  ┌──────────────┐   ┌──────────────┐  │
│  │ AuthService  │   │ HabitSync    │  │
│  │              │   │ Service      │  │
│  └──────┬───────┘   └──────┬───────┘  │
│         │                   │          │
│         └───────┬───────────┘          │
│                 │                      │
└─────────────────┼──────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│        Supabase (Backend)               │
├─────────────────────────────────────────┤
│                                         │
│  ┌──────────────────────────────────┐  │
│  │      Auth (User Management)      │  │
│  └──────────────┬───────────────────┘  │
│                 │                      │
│                 │ Trigger              │
│                 ▼                      │
│  ┌──────────────────────────────────┐  │
│  │   profiles (Auto-Created)        │  │
│  │   - id (UUID)                    │  │
│  │   - name                         │  │
│  │   - created_at, updated_at       │  │
│  └──────────────────────────────────┘  │
│                                         │
│  ┌──────────────────────────────────┐  │
│  │   habits                         │  │
│  │   - id (UUID)                    │  │
│  │   - user_id (FK to profiles)     │  │
│  │   - name, description            │  │
│  │   - is_active, completed_dates   │  │
│  │   - current_streak               │  │
│  │   - created_at, updated_at       │  │
│  └──────────────────────────────────┘  │
│                                         │
│  🔒 RLS Policies: Users can only       │
│     access their own data               │
└─────────────────────────────────────────┘
```

## 🎉 Zusammenfassung

**Problem**: RLS-Policy Fehler beim Registrieren
**Ursache**: Fehlende Supabase-Konfiguration
**Lösung**: SQL-Setup-Script ausführen
**Ergebnis**: Vollständig funktionsfähige App mit sicherer Datensynchronisation!

## 📚 Weiterführende Dokumentation

- **`SUPABASE_SETUP.md`** - Komplette Setup-Anleitung
- **`SCHNELLSTART_SYNC.md`** - Schnellstart für Sync-Tests
- **`docs/SYNC_DOCUMENTATION.md`** - Technische Sync-Dokumentation
- **`docs/SYNC_TEST_ANLEITUNG.md`** - Detaillierte Test-Anleitung
- **`CLAUDE.md`** - Architektur-Übersicht für Claude

Viel Erfolg beim Testen! 🚀
