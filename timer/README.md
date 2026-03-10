# Timer & Stoppuhr

Eine Flutter-App zur Demonstration verschiedener Zeitgebungs-Ansätze. Die App vergleicht interaktiv, wie Flutter's `Ticker`, Wanduhrzeit und asynchrone Loops in puncto Präzision und Drift unterschiedlich arbeiten.

## Screens

- **Timer** – Countdown mit konfigurierbarer Dauer, Pause/Weiter und Reset
- **Stoppuhr** – Millisekunden-genaue Zeitmessung mit akkumulierten Start/Stop-Zyklen
- **Vergleich** – Parallele Messung mit drei Methoden unter simulierter UI-Last:
  - Wanduhrzeit (`DateTime`)
  - Flutter-Engine `Ticker` (frame-synchron)
  - Async-Loop mit festen 16ms-Schritten

## Lernziele

- Unterschied zwischen frame-basiertem und wall-clock-basiertem Timing
- `SingleTickerProviderStateMixin` und `Ticker` in Flutter
- Timing-Drift unter UI-Last verstehen

## Projektstruktur

```
lib/
├── main.dart
├── home.dart            # Navigation mit IndexedStack
├── timer.dart           # Countdown-Timer
├── stopwatch.dart       # Stoppuhr
├── compare.dart         # Timing-Vergleich
└── shared/
    ├── widgets.dart     # PageLayout, TimeDisplay, ActionButtons
    └── utils.dart       # Duration-Formatierung
```

## State Management

Kein externes Paket – reines Flutter mit `StatefulWidget`, `setState()` und `Ticker` via `SingleTickerProviderStateMixin`.

## Setup

```bash
flutter pub get
flutter run
```
