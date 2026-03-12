# CLAUDE.md

This file provides guidance to Claude Code when working in the `habit_flow_supabase` project.

## Project Overview

HabitFlow is a Flutter mobile app for building and tracking daily habits with motivational quotes and cloud sync. It follows an offline-first architecture with automatic synchronization to Supabase.

## Development Commands

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Code generation (Freezed, Hive adapters, JSON serialization)
dart run build_runner build --delete-conflicting-outputs

# Watch mode during development
dart run build_runner watch --delete-conflicting-outputs

# Static analysis
flutter analyze

# DCL linter
dart run dart_code_linter:metrics analyze lib

# Production builds
flutter build apk   # Android
flutter build ios   # iOS
```

## Environment

- Uses **FVM** (Flutter Version Manager) — check `.fvmrc` for the Flutter version.
- Requires a `.env` file in the project root with:
  ```
  SUPABASE_URL=...
  SUPABASE_ANON_KEY=...
  ```
- `initializeSupabase()` and `initializeHive()` are called in `main.dart` before `runApp()`.

## Architecture

### Directory Structure

```
lib/
├── core/
│   ├── models/          # Shared models (SyncStatus)
│   ├── router/          # GoRouter configuration
│   └── services/        # HiveService, SupabaseService, EnvService
├── features/
│   ├── auth/            # Authentication (Supabase Auth + guest mode)
│   ├── habits/          # Habit management (CRUD, sync)
│   ├── quote/           # Motivational quotes (DummyJSON API)
│   ├── settings/        # App settings (sync type, preferences)
│   └── splash/          # Splash screen + initial navigation
├── app.dart
├── hive_registrar.g.dart
└── main.dart
```

Each feature contains:
- `models/` — Data models with Hive and JSON serialization
- `services/` — Business logic and API calls
- `state/` — Riverpod providers and notifiers
- `ui/` — Screens and widgets

### State Management

- **Riverpod 3.0** for all state management
- **Notifier pattern** for complex state (`HabitNotifier` in `lib/features/habits/state/habit_provider.dart`)
- **Provider pattern** for services (`authServiceProvider`, `habitSyncServiceProvider`)

### Data Persistence

Dual-storage offline-first approach:

- **Hive CE** for complex objects (habits, user profiles) — requires `@HiveType` + code generation
- **SharedPreferences** for simple key-value settings (e.g., sync type)
- All Hive models are registered in `lib/hive_registrar.g.dart`

### Authentication

- **Supabase Auth** handles sign-up, sign-in, and session management
- **Guest mode**: Users can use the app without an account; data is local-only. Guest users are created with `guestMode: true`.
- A Supabase database trigger (`on_auth_user_created`) automatically creates a row in `profiles` on sign-up using `raw_user_meta_data->>'name'`.
- Auth state is managed by `AuthNotifier` via `authStateChanges` stream.

### Navigation

- **GoRouter** for declarative routing (`lib/core/router/app_router.dart`)
- Routes: `/` (splash), `/home`, `/login`, `/register`

## Supabase Schema

### `profiles` table

```sql
CREATE TABLE public.profiles (
  id         UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name       TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### `habits` table

```sql
CREATE TABLE public.habits (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id          UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  name             TEXT NOT NULL,
  description      TEXT,
  is_active        BOOLEAN DEFAULT true,
  completed_dates  TIMESTAMP WITH TIME ZONE[] DEFAULT '{}',
  current_streak   INTEGER DEFAULT 0,
  created_at       TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at       TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### RLS Policies

Row Level Security is enabled on both tables. Each table has four policies (SELECT, INSERT, UPDATE, DELETE) that restrict access to rows where `auth.uid()` matches the row owner (`id` for profiles, `user_id` for habits).

### Triggers

- `on_auth_user_created` — creates a profile row after a new auth user is inserted
- `handle_profiles_updated_at` / `handle_habits_updated_at` — auto-updates `updated_at` on row modification

The full setup SQL is in `supabase/migrations/20240101000000_initial_setup.sql`.

## Sync Architecture

### Overview

The app implements optimistic offline-first sync:

1. All CRUD operations write to Hive immediately.
2. New/modified habits are marked `SyncStatus.pending`.
3. Sync uploads pending habits to Supabase, then merges the remote state.

### SyncStatus enum

- `synced` — up to date with cloud
- `pending` — local change not yet uploaded
- `error` — last sync attempt failed

### Sync triggers

- **Auto-sync**: after every change when `SyncType.auto` is set in settings (`_syncIfAuto()` in `habit_provider.dart`)
- **Manual sync**: Sync button (`Icons.sync`) in the AppBar (`HabitAppBarActions`)
- **On login/signup**: initial sync runs automatically for authenticated users

### Sync flow (`HabitNotifier.syncToCloud`)

- If no pending habits exist: calls `fetchFromCloud()` to pull latest remote state.
- If pending habits exist: calls `HabitSyncService.syncHabits()` to upload, then merges remote habits and removes any local habits no longer present on the server.
- Guest users are skipped entirely — the sync button shows a prompt to sign in.

### Conflict resolution

Remote wins when `remoteHabit.updatedAt` is after `localHabit.updatedAt` (`habit_provider.dart`).

### Guest-to-auth migration

When a guest user signs in or registers, `_migrateHabitsToUser(userId)` updates all local habits whose `userId` does not match the authenticated user's ID, marks them `pending`, and saves them. This ensures the subsequent sync uses the correct Supabase Auth user ID.

Key files:
- `lib/features/habits/services/habit_sync_service.dart` — cloud sync logic
- `lib/features/habits/state/habit_provider.dart` — `syncToCloud`, `fetchFromCloud`, `_migrateHabitsToUser`
- `lib/features/habits/ui/screens/habit_screen.dart` — `_syncHabits` handler
- `lib/features/habits/ui/widgets/habit_app_bar_actions.dart` — Sync button widget

## Models and Code Generation

All data models use:
- **Freezed** for immutability and `copyWith`
- **json_serializable** for JSON conversion
- **Hive CE** type adapters for local storage

Models carry both `@HiveType` and `@JsonSerializable` annotations. The `Habit` model uses a custom `toJson()` to normalize timestamps to UTC before uploading (`lib/features/habits/models/habits/habit.dart`).

### Adding or modifying models

1. Update the model class.
2. Run `dart run build_runner build --delete-conflicting-outputs`.
3. Hive adapters and JSON serializers regenerate automatically.

### Adding a new Hive model

1. Annotate with `@HiveType(typeId: X)` using a unique `typeId`.
2. Annotate each field with `@HiveField(N)`.
3. Run code generation.
4. Open the box in `lib/core/services/hive_service.dart`.

### Adding sync to a new feature

1. Mark local changes with `syncStatus = SyncStatus.pending` and `updatedAt = DateTime.now()`.
2. Call `await object.save()` for HiveObject instances.
3. Trigger sync via `_syncIfAuto()` or let the user trigger it manually.

## External APIs

- **DummyJSON** — random motivational quotes (`lib/features/quote/services/quote_service.dart`)
