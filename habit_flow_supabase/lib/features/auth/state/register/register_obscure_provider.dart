import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterObscureNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void toggle() {
    state = !state;
  }
}

final registerObscureProvider =
    NotifierProvider.autoDispose<RegisterObscureNotifier, bool>(
      RegisterObscureNotifier.new,
    );
