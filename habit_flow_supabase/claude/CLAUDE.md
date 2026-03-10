# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

HabitFlow is a Flutter mobile app for building and tracking daily habits with motivational quotes and cloud sync. The app features an offline-first architecture with automatic synchronization to Supabase.

## Development Commands

### Code Generation
```bash
# Run code generation for Freezed, Hive adapters, and JSON serialization
dart run build_runner build --delete-conflicting-outputs

# Watch mode for continuous code generation during development
dart run build_runner watch --delete-conflicting-outputs
```

### Dependency Management
```bash
# Install dependencies
flutter pub get
```

### Code Quality
```bash
# Run static analysis
flutter analyze

# Run DCL linter (Dart Code Linter)
dart run dart_code_linter:metrics analyze lib
```

### Running the App
```bash
# Run on connected device/emulator
flutter run

# Build for production
flutter build apk  # Android
flutter build ios  # iOS
```

## Architecture

### Feature-Based Structure
The codebase follows a feature-first architecture with clear separation of concerns:

```
lib/
├── core/                    # Shared services and models
│   ├── models/              # Sync models (SyncStatus, etc.)
│   ├── router/              # GoRouter configuration
│   └── services/            # Core services (Hive, Supabase, Env)
└── features/
    ├── auth/                # Authentication feature
    ├── habits/              # Habit management feature
    ├── quote/               # Motivational quotes feature
    ├── settings/            # App settings feature
    └── splash/              # Splash screen
```

Each feature follows this internal structure:
- `models/` - Data models with Hive & JSON serialization
- `services/` - Business logic and API calls
- `state/` - Riverpod providers and notifiers
- `ui/` - Screens and widgets

### State Management
- **Riverpod 3.0** is used for all state management
- **Notifier pattern** for complex state (see `HabitNotifier` in `lib/features/habits/state/habit_provider.dart:11`)
- **Provider pattern** for services (see `authServiceProvider`, `habitSyncServiceProvider`)

### Data Persistence
**Offline-First with Dual Storage:**
- **Hive CE** for complex data (habits, user profiles) - requires `@HiveType` and code generation
- **SharedPreferences** for simple key-value settings
- **SyncStatus enum** tracks sync state: `synced`, `pending`, `error`

All Hive models must be registered in `lib/hive_registrar.g.dart` via code generation.

### Sync Architecture
The app implements optimistic offline-first sync:

1. **Local-First Operations**: All CRUD operations happen on Hive immediately
2. **Sync Triggers**:
   - Auto-sync on every change (if `SyncType.auto` in settings)
   - Manual sync via Sync-Button (`Icon(Icons.sync)` in AppBar)
   - Initial sync on app start for authenticated users
3. **Conflict Resolution**: Remote wins if `updatedAt` is newer
4. **Migration**: Habits auto-migrate to logged-in user's ID (see `_migrateHabitsToUser` in `lib/features/habits/state/habit_provider.dart:134`)

**Sync-Button**: Located in `HabitAppBarActions` widget, calls `_syncHabits()` method which:
- Shows SnackBar for guest users ("Melde dich an, um zu synchronisieren")
- Sets syncing state (shows CircularProgressIndicator)
- Calls `habitProvider.notifier.syncToCloud()`
- Shows success/error message

**Sync Flow**:
- If no pending habits: `fetchFromCloud()` retrieves all habits from Supabase
- If pending habits exist: `syncHabits()` uploads pending changes, then merges remote data
- Always syncs on login/signup

Key sync service: `HabitSyncService` (`lib/features/habits/services/habit_sync_service.dart`)

**Guest Mode**: Guest users have NO cloud sync. Data stored only in local Hive database. Guest user created with `guestMode: true` flag.

### Authentication
- **Supabase Auth** for user management
- **Guest mode** supported (habits stored locally only)
- Profile creation on signup via `profiles` table
- Auth state managed by `AuthNotifier` with `authStateChanges` stream

### Backend Integration
**Supabase:**
- Tables: `profiles`, `habits`
- Environment variables in `.env`: `SUPABASE_URL`, `SUPABASE_ANON_KEY`
- Initialized in `main.dart:9` via `initializeSupabase()`

**External API:**
- DummyJSON API for random motivational quotes
- Service: `QuoteService` (`lib/features/quote/services/quote_service.dart`)

### Navigation
- **GoRouter** for declarative routing
- Routes defined in `lib/core/router/app_router.dart`
- Main routes: `/` (splash), `/home`, `/login`, `/register`

### Models & Code Generation
All data models use:
- **Freezed** for immutability and pattern matching
- **json_serializable** for JSON conversion
- **Hive CE** type adapters for local storage

Models require both `@HiveType` and `@JsonSerializable` annotations. The `Habit` model demonstrates custom `toJson()` for UTC conversion (`lib/features/habits/models/habits/habit.dart:66`).

## Important Patterns

### When modifying models:
1. Update the model class
2. Run `dart run build_runner build --delete-conflicting-outputs`
3. Hive adapters and JSON serialization auto-generate

### When adding new Hive models:
1. Add `@HiveType(typeId: X)` with unique typeId
2. Add `@HiveField(N)` to each field
3. Run code generation
4. Open the box in `lib/core/services/hive_service.dart`

### Sync pattern for new features:
- Mark local changes with `syncStatus = SyncStatus.pending`
- Update `updatedAt = DateTime.now()`
- Call `await habit.save()` for HiveObject changes
- Trigger sync via `_syncIfAuto()` or manual sync

## Environment Setup
- Uses **FVM** (Flutter Version Management) - check `.fvmrc` for Flutter version
- Requires `.env` file with Supabase credentials (see `.env` file structure)
- Initialize with `initializeSupabase()` and `initializeHive()` before `runApp()`
