import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_flow/features/auth/models/auth_result/auth_result.dart';
import 'package:hive_ce/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:habit_flow/core/models/sync_status.dart';
import 'package:habit_flow/features/auth/models/user/user.dart';
import 'package:habit_flow/features/auth/services/auth_service.dart';
import 'package:habit_flow/features/habits/state/habit_provider.dart';

class AuthNotifier extends Notifier<User?> {
  late Box<User> _box;

  AuthService get _authService => ref.read(authServiceProvider);

  @override
  User? build() {
    _box = Hive.box<User>('user');
    try {
      return _box.get('current_user');
    } catch (e) {
      // Handle corrupted data by clearing the box
      _box.clear();
      return null;
    }
  }

  Future<void> createGuestUser() async {
    final user = User(
      id: const Uuid().v4(),
      email: 'guest@habitflow.local',
      name: 'Gast',
      guestMode: true,
      syncStatus: SyncStatus.synced,
    );
    await _box.put('current_user', user);
    state = user;
  }

  Future<AuthResult> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    final result = await _authService.signUp(
      email: email,
      password: password,
      name: name,
    );

    if (result.success && result.userId != null) {
      print('🔑 Creating user with Supabase Auth ID: ${result.userId}');
      final user = User(
        id: result.userId!, // Diese ID MUSS die Supabase Auth User-ID sein!
        email: result.email ?? email,
        name: name,
        guestMode: false,
        syncStatus: SyncStatus.synced,
      );
      await _box.put('current_user', user);
      state = user;
      print('✅ User saved to Hive with ID: ${user.id}');
      await ref.read(habitProvider.notifier).syncToCloud();
    }

    return result;
  }

  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    final result = await _authService.signIn(email: email, password: password);

    if (result.success && result.userId != null) {
      print('🔑 Signing in user with Supabase Auth ID: ${result.userId}');
      final user = User(
        id: result.userId!, // Diese ID MUSS die Supabase Auth User-ID sein!
        email: result.email ?? email,
        guestMode: false,
        syncStatus: SyncStatus.synced,
      );
      await _box.put('current_user', user);
      state = user;
      print('✅ User signed in with ID: ${user.id}');
      await ref.read(habitProvider.notifier).syncToCloud();
    }

    return result;
  }

  Future<void> signOut() async {
    await _authService.signOut();
    await _box.delete('current_user');
    state = null;
  }

  Future<void> logout() async {
    await signOut();
  }

  Future<void> updateProfile({String? name, String? email}) async {
    final user = state;
    if (user != null) {
      if (name != null) user.name = name;
      if (email != null) user.email = email;
      user.syncStatus = SyncStatus.pending;
      user.updatedAt = DateTime.now();
      await user.save();
      state = user;
    }
  }

  bool get isAuthenticated => state != null && !state!.guestMode;

  bool get isGuest => state?.guestMode ?? true;
}

final authProvider = NotifierProvider<AuthNotifier, User?>(AuthNotifier.new);
