import 'package:flutter/material.dart';
import 'package:headsup/data/prompt_repository.dart';
import 'package:headsup/domain/models/clue.dart';
import 'package:headsup/presentation/controllers/game_controller.dart';
import 'package:headsup/presentation/state/game_state.dart';
import 'package:headsup/services/tilt_gesture_service.dart';

class HeadsUpHomePage extends StatefulWidget {
  const HeadsUpHomePage({super.key});

  @override
  State<HeadsUpHomePage> createState() => _HeadsUpHomePageState();
}

class _HeadsUpHomePageState extends State<HeadsUpHomePage> {
  late final GameController _controller;

  @override
  void initState() {
    super.initState();
    _controller = GameController(PromptRepository(), TiltGestureService());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final state = _controller.state;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Heads Up! Offline'),
            actions: [
              if (state.isRunning)
                IconButton(
                  tooltip: 'Runde beenden',
                  onPressed: _controller.finishRound,
                  icon: const Icon(Icons.stop_circle_outlined),
                ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: _buildBody(context, state),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, GameState state) {
    if (state.isRunning) {
      return _PlayingView(
        state: state,
        onCorrect: _controller.markCorrect,
        onSkip: _controller.skipCard,
      );
    }

    if (state.isFinished) {
      return _SummaryView(
        state: state,
        onReplay: () => _controller.startRound(),
        onReset: _controller.reset,
      );
    }

    return _IdleView(onStart: _controller.startRound);
  }
}

class _IdleView extends StatelessWidget {
  const _IdleView({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ready to play?', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 12),
            Text(
              'Einfaches Heads Up! Erlebnis ohne Backend. '
              'Tilt nach vorne = richtig, nach hinten = überspringen.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            const _InstructionList(),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Runde starten'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InstructionList extends StatelessWidget {
  const _InstructionList();

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Hold', 'Gerät an die Stirn, Bildschirm nach außen.'),
      ('Guess', 'Team beschreibt den Begriff ohne ihn zu nennen.'),
      ('Tilt', 'Nach unten neigen = Punkt, nach oben = überspringen.'),
      ('Offline', 'Alle Begriffe kommen lokal aus der App.'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green.shade400,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: [
                          TextSpan(
                            text: '${entry.$1}: ',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: entry.$2),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _PlayingView extends StatelessWidget {
  const _PlayingView({
    required this.state,
    required this.onCorrect,
    required this.onSkip,
  });

  final GameState state;
  final VoidCallback onCorrect;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _InfoChip(
              icon: Icons.timer_outlined,
              label: '${state.secondsRemaining}s',
            ),
            _InfoChip(
              icon: Icons.layers_outlined,
              label:
                  '${state.correct.length + state.skipped.length}/${state.totalCards}',
            ),
            _InfoChip(
              icon: Icons.emoji_events_outlined,
              label: '${state.score} Punkte',
            ),
          ],
        ),
        const SizedBox(height: 32),
        Expanded(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            color: theme.colorScheme.primaryContainer,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.active?.category ?? '',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer
                              .withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        state.active?.title ?? '',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Keine Sensoren verfügbar? Nutze die Buttons:',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onSkip,
                icon: const Icon(Icons.arrow_upward),
                label: const Text('Überspringen'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: onCorrect,
                icon: const Icon(Icons.check),
                label: const Text('Richtig'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryView extends StatelessWidget {
  const _SummaryView({
    required this.state,
    required this.onReplay,
    required this.onReset,
  });

  final GameState state;
  final VoidCallback onReplay;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Runde beendet!', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _InfoChip(
              icon: Icons.emoji_events,
              label: '${state.score} korrekt',
            ),
            _InfoChip(
              icon: Icons.fast_forward,
              label: '${state.passes} übersprungen',
            ),
            _InfoChip(
              icon: Icons.timer_off,
              label: '${state.secondsRemaining}s übrig',
            ),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _ClueList(title: 'Treffer', items: state.correct),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ClueList(title: 'Übersprungen', items: state.skipped),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: onReplay,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Nochmal spielen'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.home_outlined),
                label: const Text('Zurück zur Lobby'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ClueList extends StatelessWidget {
  const _ClueList({required this.title, required this.items});

  final String title;
  final List<Clue> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          if (items.isEmpty)
            Text('Noch keine Einträge', style: theme.textTheme.bodySmall)
          else
            Expanded(
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) =>
                    Divider(color: theme.dividerColor.withValues(alpha: 0.2)),
                itemBuilder: (_, index) {
                  final clue = items[index];
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(clue.title),
                    subtitle: Text(clue.category),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Text(label, style: theme.textTheme.labelLarge),
        ],
      ),
    );
  }
}
