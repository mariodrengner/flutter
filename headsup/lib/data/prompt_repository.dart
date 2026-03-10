import 'dart:math';

import '../domain/models/clue.dart';
import 'local_prompts.dart';

class PromptRepository {
  PromptRepository({List<Clue>? seed}) : _seed = seed ?? localClues;

  final List<Clue> _seed;
  final _random = Random();

  List<Clue> all() => List.unmodifiable(_seed);

  List<Clue> buildDeck({int length = 18}) {
    if (_seed.isEmpty) {
      return const [];
    }

    final deck = List<Clue>.from(_seed);
    deck.shuffle(_random);
    final safeLength = length.clamp(1, deck.length).toInt();
    return deck.take(safeLength).toList(growable: false);
  }
}
