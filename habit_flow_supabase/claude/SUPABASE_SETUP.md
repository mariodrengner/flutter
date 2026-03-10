# 🚀 Supabase Setup für HabitFlow

## Problem gelöst: "PostgrestException (New row violates row-level security policy)"

Dieser Fehler tritt auf, weil die Row Level Security (RLS) Policies in Supabase noch nicht konfiguriert sind.

## ✅ Lösung: SQL-Script ausführen

### Schritt 1: Supabase Dashboard öffnen

1. Gehe zu https://supabase.com/dashboard
2. Wähle dein Projekt aus
3. Klicke auf **SQL Editor** in der linken Seitenleiste

### Schritt 2: SQL-Script ausführen

1. Klicke auf **New Query**
2. Öffne die Datei `supabase/setup.sql` in diesem Repository
3. Kopiere den **gesamten Inhalt** der Datei
4. Füge ihn in den SQL Editor ein
5. Klicke auf **Run** (oder drücke Cmd+Enter / Ctrl+Enter)

### Schritt 3: Erfolg überprüfen

Nach dem Ausführen solltest du folgende Meldungen sehen:

```
✅ Profiles table created
✅ Habits table created
✅ RLS enabled on both tables
✅ Policies created for profiles and habits
✅ Triggers created for auto-profile and updated_at
```

Und eine Liste aller erstellten Policies:

| tablename | policyname | cmd | roles |
|-----------|-----------|-----|-------|
| profiles | Users can view own profile | SELECT | {} |
| profiles | Users can insert own profile | INSERT | {} |
| profiles | Users can update own profile | UPDATE | {} |
| profiles | Users can delete own profile | DELETE | {} |
| habits | Users can view own habits | SELECT | {} |
| habits | Users can insert own habits | INSERT | {} |
| habits | Users can update own habits | UPDATE | {} |
| habits | Users can delete own habits | DELETE | {} |

## 📋 Was macht das Setup-Script?

### 1. **Tabellen erstellen**
- `profiles`: Speichert User-Profile (id, name, created_at, updated_at)
- `habits`: Speichert Habits (id, user_id, name, description, is_active, completed_dates, current_streak, created_at, updated_at)

### 2. **Row Level Security (RLS) aktivieren**
- Schützt die Daten, sodass User nur ihre eigenen Daten sehen können
- Verhindert, dass User auf Daten anderer User zugreifen

### 3. **RLS Policies erstellen**

**Für `profiles`:**
- User können nur ihr eigenes Profil sehen
- User können nur ihr eigenes Profil erstellen
- User können nur ihr eigenes Profil bearbeiten
- User können nur ihr eigenes Profil löschen

**Für `habits`:**
- User können nur ihre eigenen Habits sehen
- User können nur ihre eigenen Habits erstellen
- User können nur ihre eigenen Habits bearbeiten
- User können nur ihre eigenen Habits löschen

### 4. **Automatisches Profil erstellen**

Ein **Trigger** erstellt automatisch ein Profil, wenn sich ein User registriert:
- Kein manuelles Einfügen in die `profiles` Tabelle nötig
- Der Name wird aus den User-Metadaten übernommen
- `created_at` und `updated_at` werden automatisch gesetzt

### 5. **Automatisches `updated_at` aktualisieren**

Ein **Trigger** aktualisiert automatisch `updated_at` bei jeder Änderung:
- Für `profiles` Tabelle
- Für `habits` Tabelle

## 🎯 Nach dem Setup: App testen

### 1. App neu starten
```bash
flutter run
```

### 2. User registrieren
- Klicke auf Logout (falls nötig)
- Gehe zum Register-Screen
- E-Mail: `test@example.com`
- Passwort: `test123`
- Name: `Test User`
- Klicke **"Registrieren"**

### 3. Terminal beobachten

Du solltest jetzt sehen:

```
📝 Signing up user: test@example.com with name: Test User
✅ User signed up successfully: <user-id>
🔄 Profile will be created automatically by trigger
```

**KEIN Fehler mehr!** 🎉

### 4. Habits erstellen und synchronisieren

```
# Habits erstellen
- "Sport machen"
- "Wasser trinken"
- "Lesen"

# Sync-Button drücken

# Terminal zeigt:
🚀 Starting cloud sync for user: <user-id>
🔄 Uploading 3 habits to Supabase...
✅ Upload completed successfully!
```

### 5. In Supabase überprüfen

1. Gehe zu **Table Editor** → **profiles**
   - Du solltest den neuen User sehen mit `name: "Test User"`

2. Gehe zu **Table Editor** → **habits**
   - Du solltest alle 3 Habits sehen

## ⚠️ Wichtige Hinweise

### RLS ist aktiv!

- User können **nur ihre eigenen Daten** sehen und bearbeiten
- Ein User kann **nicht** die Habits eines anderen Users sehen
- Das ist die **korrekte und sichere** Konfiguration

### Policies überprüfen

Du kannst die Policies jederzeit im Supabase Dashboard überprüfen:

1. Gehe zu **Authentication** → **Policies**
2. Wähle eine Tabelle (`profiles` oder `habits`)
3. Du siehst alle aktiven Policies

### Policies bearbeiten

Falls du eine Policy ändern musst:
1. **Option A**: Führe das `setup.sql` Script erneut aus (löscht alte, erstellt neue)
2. **Option B**: Im Dashboard: **Table Editor** → Tabelle auswählen → **Policies** → Policy bearbeiten

## 🔧 Troubleshooting

### Problem: "relation 'public.profiles' already exists"

**Lösung**: Die Tabellen existieren bereits. Das ist OK!
- Das Script verwendet `CREATE TABLE IF NOT EXISTS`
- Es wird nur erstellt, wenn sie nicht existieren
- Policies werden trotzdem aktualisiert

### Problem: "permission denied for schema public"

**Lösung**:
1. Du bist nicht als Owner des Projekts eingeloggt
2. Gehe zu **Settings** → **Database** → **Connection string**
3. Verwende die **Postgres connection string** im SQL Editor

### Problem: "auth.uid() is null"

**Lösung**:
1. Du bist nicht eingeloggt
2. RLS-Policies funktionieren nur für authentifizierte User
3. Melde dich in der App an

### Problem: Trigger funktioniert nicht

**Überprüfe**:
```sql
-- Alle Trigger anzeigen
SELECT
  trigger_name,
  event_manipulation,
  event_object_table,
  action_statement
FROM information_schema.triggers
WHERE trigger_schema = 'public'
ORDER BY event_object_table, trigger_name;
```

Du solltest sehen:
- `on_auth_user_created` auf `auth.users`
- `handle_profiles_updated_at` auf `public.profiles`
- `handle_habits_updated_at` auf `public.habits`

## 📚 Weitere Ressourcen

- [Supabase RLS Documentation](https://supabase.com/docs/guides/auth/row-level-security)
- [PostgreSQL RLS](https://www.postgresql.org/docs/current/ddl-rowsecurity.html)
- [Supabase Policies Guide](https://supabase.com/docs/guides/auth/managing-user-data)

## ✅ Checkliste

- [ ] SQL-Script in Supabase SQL Editor ausgeführt
- [ ] Erfolgsmeldungen gesehen
- [ ] Policies überprüft
- [ ] App neu gestartet
- [ ] User erfolgreich registriert (ohne RLS-Fehler)
- [ ] Profil in `profiles` Tabelle vorhanden
- [ ] Habits erstellt und synchronisiert
- [ ] Habits in `habits` Tabelle vorhanden

Wenn alle Punkte ✅ sind, ist dein Supabase-Setup komplett! 🎉
