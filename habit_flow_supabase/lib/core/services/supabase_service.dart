import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService();

  SupabaseClient get client => Supabase.instance.client;

  GoTrueClient get auth => client.auth;

  SupabaseQueryBuilder profiles() => client.from('profiles');

  SupabaseQueryBuilder habits() => client.from('habits');

  User? get currentUser => auth.currentUser;

  bool get isAuthenticated => currentUser != null;

  Stream<AuthState> get authStateChanges => auth.onAuthStateChange;
}

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});
