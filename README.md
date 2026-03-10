# Flutter Apps

Monorepo mit fünf Flutter-Projekten aus dem App-Entwicklungs-Kurs. Jedes Projekt ist eigenständig lauffähig und demonstriert unterschiedliche Konzepte – von einfachem State Management über Clean Architecture bis hin zu Supabase-Backend-Integration.

## Projekte

| Projekt | Beschreibung | State Management | Backend |
|---|---|---|---|
| [timer](./timer) | Countdown, Stoppuhr & Timing-Vergleich | `StatefulWidget` / `Ticker` | – |
| [gallery](./gallery) | Sport-Foto-Galerie mit GoRouter-Navigation | Stateless | – |
| [design_challenge](./design_challenge) | Snack-Bestellapp mit Glassmorphism-Design | `StatefulWidget` | – |
| [headsup](./headsup) | Offline-Party-Game mit Accelerometer-Steuerung | `ChangeNotifier` | – |
| [habit_flow_supabase](./habit_flow_supabase) | Habit-Tracker mit Offline-First & Cloud-Sync | Riverpod 3 | Supabase |

## Voraussetzungen

- Flutter SDK >= 3.x
- Dart SDK >= 3.9
- Für `habit_flow_supabase`: Supabase-Konto und `.env`-Datei (siehe Projekt-README)

## Projekt starten

Jedes Projekt ist ein eigenständiges Flutter-Projekt:

```bash
cd <projektname>
flutter pub get
flutter run
```

Für `habit_flow_supabase` zusätzlich:

```bash
dart run build_runner build
```

## Konzepte im Überblick

```
timer               → Ticker, frame-sync, wall-clock Timing
gallery             → GoRouter, StatelessWidget, Shell Routes
design_challenge    → Glassmorphism, SVG, Reusable Widgets
headsup             → Accelerometer, ChangeNotifier, Clean Architecture
habit_flow_supabase → Riverpod, Hive, Supabase, Freezed, Offline-First
```
