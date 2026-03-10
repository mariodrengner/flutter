# Habit Flow

Eine Habit-Tracking-App mit Offline-First-Architektur und Cloud-Synchronisation via Supabase. Nutzer können Gewohnheiten anlegen, täglich abhaken und Streaks verfolgen – auch ohne Internetverbindung.

## Features

- Tägliches Abhaken von Gewohnheiten mit Fortschrittsanzeige
- Streak-Zählung pro Gewohnheit
- Offline-First: lokale Datenhaltung mit Hive, optionale Cloud-Sync
- Gast-Modus (ohne Account nutzbar)
- E-Mail/Passwort-Authentifizierung via Supabase
- Motivierende Zitate via externer API (DummyJSON)
- Theme-Auswahl (Hell / Dunkel / System) und Benachrichtigungseinstellungen

## Screens

| Screen | Beschreibung |
|---|---|
| Splash | Startbildschirm |
| Login / Register | Authentifizierung |
| Habits (Home) | Gewohnheitsliste, Fortschritt, Sync |
| Settings | Theme, Benachrichtigungen |

## Architektur

Feature-basierte Clean Architecture mit Riverpod als State Management:

```
lib/
├── core/
│   ├── models/           # Gemeinsame Datenmodelle (Freezed)
│   ├── router/           # GoRouter Navigation
│   └── services/         # Supabase, Hive, Env-Config
└── features/
    ├── auth/             # Login, Register, User-State
    ├── habits/           # Hauptfeature: Tracking-Logik
    ├── quote/            # Motivations-Zitate
    ├── settings/         # App-Einstellungen
    └── splash/           # Ladescreen
```

## State Management

**Riverpod 3** mit `NotifierProvider` (persistenter State) und `AsyncNotifierProvider` (async Operationen).

## Hauptabhängigkeiten

| Paket | Zweck |
|---|---|
| `flutter_riverpod` | State Management |
| `supabase_flutter` | Backend & Auth |
| `hive_ce` | Lokale Persistenz |
| `go_router` | Navigation |
| `freezed` | Immutable Models |
| `dio` | HTTP Client |

## Setup

1. Supabase-Projekt anlegen und Credentials in `.env` hinterlegen:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

2. Abhängigkeiten installieren und Code generieren:

```bash
flutter pub get
dart run build_runner build
flutter run
```
