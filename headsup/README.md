# Heads Up! Offline

Ein offline Party-Game für Flutter, inspiriert von Ellen DeGeneresʼ "Heads Up!". Spieler halten das Gerät an die Stirn – die Mitspieler beschreiben den angezeigten Begriff, ohne ihn zu nennen. Durch Neigen des Geräts wird gewertet oder der Begriff übersprungen.

## Gameplay

1. Gerät mit dem Display nach außen an die Stirn halten
2. Mitspieler beschreiben den angezeigten Begriff
3. Gerät **nach vorne neigen** = richtig geraten
4. Gerät **nach hinten neigen** = überspringen
5. Nach 60 Sekunden endet die Runde – Ergebnis wird angezeigt

> Auf Geräten ohne Beschleunigungssensor stehen Fallback-Buttons zur Verfügung.

## Features

- Vollständig offline – keine Internetverbindung nötig
- Accelerometer-basierte Gestensteuerung (tilt forward/backward)
- 25+ Begriffe aus verschiedenen Kategorien
- 60-Sekunden-Countdown pro Runde
- Ergebniszusammenfassung mit richtig/übersprungen-Listen

## Projektstruktur

```
lib/
├── main.dart
├── app.dart
├── data/
│   ├── local_prompts.dart       # Lokale Begriffe / Deck
│   └── prompt_repository.dart   # Deck-Verwaltung & Shuffle
├── domain/
│   └── models/
│       └── clue.dart            # Datenmodell: id, title, category
├── presentation/
│   ├── controllers/
│   │   └── game_controller.dart # Spiellogik & State-Verwaltung
│   ├── state/
│   │   └── game_state.dart      # Immutabler Spielzustand
│   └── pages/
│       └── home_page.dart       # UI: Idle / Playing / Summary
└── services/
    └── tilt_gesture_service.dart # Accelerometer-Gestendetektierung
```

## Architektur

Das Projekt folgt **Clean Architecture**:

- **Domain:** Reine Datenmodelle (`Clue`)
- **Data:** Repository-Pattern für Deck-Management
- **Presentation:** `GameController` (ChangeNotifier) + immutabler `GameState`
- **Services:** `TiltGestureService` kapselt Sensorlogik

State Management erfolgt ohne externe Pakete – `ChangeNotifier` + `AnimatedBuilder`.

## Abhängigkeiten

| Paket | Zweck |
|---|---|
| `sensors_plus` | Accelerometer-Zugriff für Tilt-Erkennung |
| `cupertino_icons` | iOS-Style Icons |

## Setup

```bash
flutter pub get
flutter run
```

Erfordert ein physisches Gerät (oder Emulator mit Sensor-Simulation) für die Gestensteuerung.
