import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:headsup/data/prompt_repository.dart';
import 'package:headsup/domain/models/clue.dart';
import 'package:headsup/presentation/state/game_state.dart';
import 'package:headsup/services/tilt_gesture_service.dart';

class GameController extends ChangeNotifier {
  GameController(
    this._repository,
    this._tiltService, {
    this.roundDuration = const Duration(seconds: 60),
    this.deckSize = 18,
  });

  final PromptRepository _repository;
  final TiltGestureService _tiltService;
  final Duration roundDuration;
  final int deckSize;

  GameState _state = GameState.initial();
  List<Clue> _deck = const [];
  int _currentIndex = 0;
  Timer? _timer;
  StreamSubscription<TiltGesture>? _gestureSubscription;

  GameState get state => _state;

  bool get isBusy => state.isRunning;

  void startRound() {
    if (isBusy) return;

    _deck = _repository.buildDeck(length: deckSize);
    if (_deck.isEmpty) {
      return;
    }

    _currentIndex = 0;
    _state = GameState(
      status: GameStatus.running,
      active: _deck.first,
      score: 0,
      passes: 0,
      secondsRemaining: roundDuration.inSeconds,
      totalCards: _deck.length,
      correct: const [],
      skipped: const [],
    );
    notifyListeners();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());

    _gestureSubscription?.cancel();
    _tiltService.start();
    _gestureSubscription = _tiltService.gestures.listen(_handleGesture);
  }

  void finishRound() => _completeRound();

  void reset() {
    _stopStreams();
    _deck = const [];
    _currentIndex = 0;
    _state = GameState.initial();
    notifyListeners();
  }

  void markCorrect() => _advance(isCorrect: true);

  void skipCard() => _advance(isCorrect: false);

  void _handleGesture(TiltGesture gesture) {
    if (!state.isRunning) return;

    switch (gesture) {
      case TiltGesture.correct:
        markCorrect();
        break;
      case TiltGesture.pass:
        skipCard();
        break;
      case TiltGesture.neutral:
        break;
    }
  }

  void _advance({required bool isCorrect}) {
    if (!state.isRunning || state.active == null) return;

    final current = state.active!;
    final nextCorrect = isCorrect
        ? (List<Clue>.from(state.correct)..add(current))
        : state.correct;
    final nextSkipped = isCorrect
        ? state.skipped
        : (List<Clue>.from(state.skipped)..add(current));

    var updatedState = state.copyWith(
      score: isCorrect ? state.score + 1 : state.score,
      passes: isCorrect ? state.passes : state.passes + 1,
      correct: nextCorrect,
      skipped: nextSkipped,
    );

    final hasNext = _currentIndex + 1 < _deck.length;
    if (hasNext) {
      _currentIndex++;
      updatedState = updatedState.copyWith(active: _deck[_currentIndex]);
      _state = updatedState;
      notifyListeners();
    } else {
      _state = updatedState.copyWith(active: null, overrideActive: true);
      _completeRound();
    }
  }

  void _tick() {
    if (!state.isRunning) return;

    final next = state.secondsRemaining - 1;
    if (next <= 0) {
      _state = state.copyWith(secondsRemaining: 0);
      _completeRound();
    } else {
      _state = state.copyWith(secondsRemaining: next);
      notifyListeners();
    }
  }

  void _completeRound() {
    if (state.isFinished) {
      _stopStreams();
      return;
    }
    _stopStreams();
    _state = state.copyWith(
      status: GameStatus.finished,
      overrideActive: true,
      active: null,
    );
    notifyListeners();
  }

  void _stopStreams() {
    _timer?.cancel();
    _timer = null;
    _gestureSubscription?.cancel();
    _gestureSubscription = null;
    _tiltService.stop();
  }

  @override
  void dispose() {
    _stopStreams();
    _tiltService.dispose();
    super.dispose();
  }
}
