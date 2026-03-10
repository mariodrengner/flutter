import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_flow/features/auth/models/auth_result/auth_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:habit_flow/core/services/supabase_service.dart';

class AuthService {
  AuthService(this._supabase);

  final SupabaseService _supabase;

  Future<AuthResult> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      print('📝 Signing up user: $email with name: $name');

      // Sign up with metadata - Trigger erstellt automatisch das Profil
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: name != null ? {'name': name} : null,
      );

      if (response.user != null) {
        print('✅ User signed up successfully: ${response.user!.id}');
        print('🔄 Profile will be created automatically by trigger');

        return AuthResult(
          success: true,
          userId: response.user!.id,
          email: response.user!.email,
        );
      }

      print('❌ Sign up failed: No user returned');
      return AuthResult(
        success: false,
        errorMessage: 'Registrierung fehlgeschlagen',
      );
    } on AuthException catch (e) {
      print('❌ AuthException during sign up: ${e.message}');
      return AuthResult(success: false, errorMessage: e.message);
    } catch (e) {
      print('❌ Exception during sign up: $e');
      return AuthResult(success: false, errorMessage: e.toString());
    }
  }

  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return AuthResult(
          success: true,
          userId: response.user!.id,
          email: response.user!.email,
        );
      }

      return AuthResult(
        success: false,
        errorMessage: 'Anmeldung fehlgeschlagen',
      );
    } on AuthException catch (e) {
      return AuthResult(success: false, errorMessage: e.message);
    } catch (e) {
      return AuthResult(success: false, errorMessage: e.toString());
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  User? get currentUser => _supabase.currentUser;

  bool get isAuthenticated => _supabase.isAuthenticated;

  Stream<AuthState> get authStateChanges => _supabase.authStateChanges;
}

final authServiceProvider = Provider<AuthService>((ref) {
  final supabase = ref.watch(supabaseServiceProvider);
  return AuthService(supabase);
});
