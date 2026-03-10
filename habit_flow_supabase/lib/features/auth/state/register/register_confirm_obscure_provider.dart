import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterConfirmObscureNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void toggle() {
    state = !state;
  }
}

final registerConfirmObscureProvider =
    NotifierProvider.autoDispose<RegisterConfirmObscureNotifier, bool>(
      RegisterConfirmObscureNotifier.new,
    );
