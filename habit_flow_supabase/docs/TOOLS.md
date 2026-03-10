# Habit Flow - Projekt-Tools & Pakete

Dieses Dokument bietet einen Überblick über alle Tools, Pakete und Technologien, die in diesem Projekt verwendet werden.

---

## 🛠️ Entwicklungsumgebung

| Tool | Beschreibung | Link |
|------|--------------|------|
| **FVM** | Flutter Version Management - Verwaltet Flutter SDK Versionen pro Projekt | [fvm.app](https://fvm.app/) |
| **Flutter DCL** | Dart code Linter - Statisches Analyse-Tool für Code-Qualität | [dcl.apps.bancolombia.com](https://dcl.apps.bancolombia.com/docs/getting-started) |

---

## 📦 State Management

| Paket | Beschreibung | Link |
|-------|--------------|------|
| **Riverpod 3.0** | Reaktives Caching & Datenbindungs-Framework | [riverpod.dev](https://riverpod.dev/) |
| `flutter_riverpod` | Flutter-Integration für Riverpod | [pub.dev](https://pub.dev/packages/flutter_riverpod) |

---

## 💾 Lokale Datenbank (Komplex)

| Paket | Beschreibung | Link |
|-------|--------------|------|
| **Hive CE** | Leichtgewichtige, schnelle Key-Value NoSQL-Datenbank (Community Edition) | [pub.dev](https://pub.dev/packages/hive_ce) |
| `hive_ce` | Kern-Paket der Hive CE Datenbank | [pub.dev](https://pub.dev/packages/hive_ce) |
| `hive_ce_flutter` | Flutter-Bindings für Hive CE | [pub.dev](https://pub.dev/packages/hive_ce_flutter) |
| `hive_ce_generator` | Code-Generator für Hive Type-Adapter | [pub.dev](https://pub.dev/packages/hive_ce_generator) |

---

## 🗂️ Lokale Persistenz (Einfach)

| Paket | Beschreibung | Link |
|-------|--------------|------|
| **SharedPreferences** | Einfacher Key-Value-Speicher für App-Einstellungen | [pub.dev](https://pub.dev/packages/shared_preferences) |

---

## 🌐 HTTP Client

| Paket | Beschreibung | Link |
|-------|--------------|------|
| **Dio** | Leistungsstarker HTTP-Client mit Interceptors, Transformers und mehr | [pub.dev](https://pub.dev/packages/dio) |

---

## 🧊 Code-Generierung

| Paket | Beschreibung | Link |
|-------|--------------|------|
| **Freezed** | Code-Generierung für unveränderliche Klassen, Unions und Pattern Matching | [pub.dev](https://pub.dev/packages/freezed) |
| `freezed_annotation` | Annotationen für Freezed | [pub.dev](https://pub.dev/packages/freezed_annotation) |
| **json_serializable** | JSON-Serialisierungs Code-Generator | [pub.dev](https://pub.dev/packages/json_serializable) |
| `json_annotation` | Annotationen für json_serializable | [pub.dev](https://pub.dev/packages/json_annotation) |
| `build_runner` | Build-System für Code-Generierung | [pub.dev](https://pub.dev/packages/build_runner) |

---

## 🧭 Navigation

| Paket | Beschreibung | Link |
|-------|--------------|------|
| **GoRouter** | Deklaratives Routing-Paket mit Deep-Linking-Unterstützung | [pub.dev](https://pub.dev/packages/go_router) |

---

## 🔗 Externe API

| Dienst | Beschreibung | Link |
|--------|--------------|------|
| **DummyJSON** | Kostenlose Fake REST API zum Testen und Prototyping (Quotes API) | [dummyjson.com](https://dummyjson.com/) |

---

## 🚀 Schnellbefehle

```bash
# Code-Generierung ausführen (Freezed, Hive, json_serializable)
dart run build_runner build --delete-conflicting-outputs

# Watch-Modus für Code-Generierung
dart run build_runner watch --delete-conflicting-outputs

# Abhängigkeiten laden
flutter pub get
```

---

## 📁 Projektstruktur (wird in den folgenden Tagen noch verändert)

```
lib/
├── main.dart
├── app.dart
└── features/
    ├── splash/
    │   └── splash_screen.dart
    └── task_list/
        ├── screens/
        │   ├── home_screen.dart
        │   └── list_screen.dart
        └── widgets/
            ├── empty_content.dart
            └── item_list.dart
```

---
