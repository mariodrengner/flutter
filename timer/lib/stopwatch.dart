import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'shared/utils.dart';
import 'shared/widgets.dart';

class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({super.key});
  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _elapsed = Duration.zero;
  Duration _carry = Duration.zero; // akkumuliert zwischen Starts
  DateTime? _t0;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) {
      if (!_running || _t0 == null) return;
      final now = DateTime.now();
      setState(() => _elapsed = _carry + now.difference(_t0!));
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _start() {
    if (_running) return;
    _running = true;
    _t0 = DateTime.now();
    _ticker.start();
  }

  void _stop() {
    if (!_running) return;
    _running = false;
    _ticker.stop();
    if (_t0 != null) _carry += DateTime.now().difference(_t0!);
    _t0 = null;
    setState(() {}); // finaler Stand
  }

  void _reset() {
    _ticker.stop();
    _running = false;
    _elapsed = Duration.zero;
    _carry = Duration.zero;
    _t0 = null;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TimeDisplay(formatDuration(_elapsed, showMilliseconds: true)),
          const SizedBox(height: 16),
          ActionButtons(
            running: _running,
            onStart: _start,
            onStop: _stop,
            onReset: _reset,
            canReset: _elapsed > Duration.zero || _carry > Duration.zero,
          ),
        ],
      ),
    );
  }
}
