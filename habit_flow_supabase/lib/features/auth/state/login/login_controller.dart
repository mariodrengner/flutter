import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_flow/features/auth/state/auth/auth_failure.dart';
import 'package:habit_flow/features/auth/state/auth/auth_provider.dart';

class LoginController extends AsyncNotifier<void> {
  @override
  void build() {}

  Future<void> submit({required String email, required String password}) async {
    state = const AsyncLoading();
    try {
      final result = await ref
          .read(authProvider.notifier)
          .signIn(email: email, password: password);

      if (!result.success) {
        throw AuthFailure(result.errorMessage ?? 'Anmeldung fehlgeschlagen');
      }

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final loginControllerProvider =
    AsyncNotifierProvider.autoDispose<LoginController, void>(
      LoginController.new,
    );
