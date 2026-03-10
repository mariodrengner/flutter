import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginObscureNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void toggle() {
    state = !state;
  }
}

final loginObscureProvider =
    NotifierProvider.autoDispose<LoginObscureNotifier, bool>(
      LoginObscureNotifier.new,
    );
