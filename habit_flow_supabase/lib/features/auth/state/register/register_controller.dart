import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_flow/features/auth/state/auth/auth_failure.dart';
import 'package:habit_flow/features/auth/state/auth/auth_provider.dart';

class RegisterController extends AsyncNotifier<void> {
  @override
  void build() {}

  Future<void> submit({
    required String email,
    required String password,
    String? name,
  }) async {
    state = const AsyncLoading();
    try {
      final result = await ref
          .read(authProvider.notifier)
          .signUp(email: email, password: password, name: name);

      if (!result.success) {
        throw AuthFailure(
          result.errorMessage ?? 'Registrierung fehlgeschlagen',
        );
      }

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final registerControllerProvider =
    AsyncNotifierProvider.autoDispose<RegisterController, void>(
      RegisterController.new,
    );
