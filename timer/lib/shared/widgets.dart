import 'package:flutter/material.dart';

class PageLayout extends StatelessWidget {
  final Widget child;
  const PageLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: child,
        ),
      ),
    );
  }
}

class TimeDisplay extends StatelessWidget {
  final String time;
  const TimeDisplay(this.time, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      time,
      style: const TextStyle(fontSize: 48),
    );
  }
}

class ActionButtons extends StatelessWidget {
  final bool running;
  final VoidCallback? onStart;
  final VoidCallback? onStop;
  final VoidCallback? onReset;
  final bool canReset;

  const ActionButtons({
    super.key,
    required this.running,
    this.onStart,
    this.onStop,
    this.onReset,
    this.canReset = false,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      children: [
        FilledButton.icon(
          onPressed: running ? null : onStart,
          icon: const Icon(Icons.play_arrow),
          label: const Text('Start'),
        ),
        OutlinedButton.icon(
          onPressed: running ? onStop : null,
          icon: const Icon(Icons.pause),
          label: const Text('Stop'),
        ),
        TextButton.icon(
          onPressed: !running && canReset ? onReset : null,
          icon: const Icon(Icons.refresh),
          label: const Text('Reset'),
        ),
      ],
    );
  }
}
