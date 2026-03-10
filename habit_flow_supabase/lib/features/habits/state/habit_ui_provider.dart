import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class HabitUiState {
  const HabitUiState({
    this.isSyncing = false,
  });

  final bool isSyncing;

  HabitUiState copyWith({
    bool? isSyncing,
  }) {
    return HabitUiState(isSyncing: isSyncing ?? this.isSyncing);
  }
}

class HabitUiNotifier extends Notifier<HabitUiState> {
  @override
  HabitUiState build() => const HabitUiState();

  void setSyncing(bool value) {
    state = state.copyWith(isSyncing: value);
  }
}

final habitUiProvider = NotifierProvider.autoDispose<HabitUiNotifier, HabitUiState>(
  HabitUiNotifier.new,
);



