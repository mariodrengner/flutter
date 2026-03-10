import 'package:headsup/domain/models/clue.dart';

enum GameStatus { idle, running, finished }

class GameState {
  const GameState({
    required this.status,
    required this.active,
    required this.score,
    required this.passes,
    required this.secondsRemaining,
    required this.totalCards,
    required this.correct,
    required this.skipped,
  });

  factory GameState.initial() => const GameState(
    status: GameStatus.idle,
    active: null,
    score: 0,
    passes: 0,
    secondsRemaining: 60,
    totalCards: 0,
    correct: <Clue>[],
    skipped: <Clue>[],
  );

  final GameStatus status;
  final Clue? active;
  final int score;
  final int passes;
  final int secondsRemaining;
  final int totalCards;
  final List<Clue> correct;
  final List<Clue> skipped;

  bool get isIdle => status == GameStatus.idle;
  bool get isRunning => status == GameStatus.running;
  bool get isFinished => status == GameStatus.finished;

  GameState copyWith({
    GameStatus? status,
    Clue? active,
    bool overrideActive = false,
    int? score,
    int? passes,
    int? secondsRemaining,
    int? totalCards,
    List<Clue>? correct,
    List<Clue>? skipped,
  }) {
    return GameState(
      status: status ?? this.status,
      active: overrideActive ? active : (active ?? this.active),
      score: score ?? this.score,
      passes: passes ?? this.passes,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      totalCards: totalCards ?? this.totalCards,
      correct: correct ?? this.correct,
      skipped: skipped ?? this.skipped,
    );
  }
}
