import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:async';
import 'shared/utils.dart';
import 'shared/widgets.dart';

class CompareScreen extends StatefulWidget {
  const CompareScreen({super.key});
  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  bool _running = false;

  // Metriken
  DateTime? _tWallStart;
  Duration _wall = Duration.zero; // reale Zeit (DateTime)
  Duration _tickerElapsed = Duration.zero; // von Ticker geliefert
  Duration _asyncElapsed = Duration.zero; // aufsummiert in fixen 16ms-Schritten

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      if (!_running) return;
      _tickerElapsed = elapsed; // Engine-Frame-Zeit
      _wall = DateTime.now().difference(_tWallStart!);
      setState(() {}); // Frame-genaues UI-Update
    });
  }

  @override
  void dispose() {
    _running = false;
    _ticker.dispose();
    super.dispose();
  }

  void _start() {
    if (_running) return;
    _running = true;
    _tWallStart = DateTime.now();
    _wall = Duration.zero;
    _tickerElapsed = Duration.zero;
    _asyncElapsed = Duration.zero;

    _ticker.start();
    _runAsyncFixedStep();
    setState(() {});
  }

  void _stop() {
    _running = false;
    _ticker.stop();
    setState(() {});
  }

  void _reset() {
    _stop();
    _wall = Duration.zero;
    _tickerElapsed = Duration.zero;
    _asyncElapsed = Duration.zero;
    setState(() {});
  }

  // Addiert pro Iteration exakt 16ms, egal wie lange der Await tatsächlich dauerte.
  Future<void> _runAsyncFixedStep() async {
    const step = Duration(milliseconds: 16);
    while (_running) {
      await Future.delayed(step);
      // wenn Event-Loop verspätet, werden dennoch nur 16ms addiert -> negativer Drift sichtbar
      _asyncElapsed += step;
      // UI-Update gedrosselt: kein setState, Ticker treibt UI
    }
  }

  // Simuliert Last:
  void _simulateLoad({int ms = 400}) {
    final until = DateTime.now().add(Duration(milliseconds: ms));
    while (DateTime.now().isBefore(until)) {
      // blockiert den Main-Isolate (beeinflusst Event-Loop)
    }
  }

  @override
  Widget build(BuildContext context) {
    final dTickerVsWall = _tickerElapsed - _wall; // ~0 bei stabilen Frames
    final dAsyncVsWall = _asyncElapsed - _wall; // wird negativ unter Last
    return PageLayout(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Timer-Präzision im Vergleich',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          _Row('Echtzeit', formatDuration(_wall, showMilliseconds: true)),
          _Row(
            'UI-Ticker',
            formatDuration(_tickerElapsed, showMilliseconds: true),
          ),
          _Row(
            'Async-Loop',
            formatDuration(_asyncElapsed, showMilliseconds: true),
          ),
          const Divider(height: 24),
          _Row('Abweichung: Ticker', '${dTickerVsWall.inMilliseconds} ms'),
          _Row('Abweichung: Async-Loop', '${dAsyncVsWall.inMilliseconds} ms'),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            children: [
              FilledButton.icon(
                onPressed: _running ? null : _start,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start'),
              ),
              OutlinedButton.icon(
                onPressed: _running ? _stop : null,
                icon: const Icon(Icons.pause),
                label: const Text('Stop'),
              ),
              TextButton.icon(
                onPressed: !_running ? _reset : null,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
              ),
              OutlinedButton.icon(
                onPressed: () => _simulateLoad(ms: 600),
                icon: const Icon(Icons.speed),
                label: const Text('UI-Last simulieren'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label, value;
  const _Row(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: const TextStyle(
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
