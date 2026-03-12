import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'shared/utils.dart';
import 'shared/widgets.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});
  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with SingleTickerProviderStateMixin {
  final _input = TextEditingController(text: '60');
  late final Ticker _ticker;
  DateTime? _end;
  Duration _remaining = Duration.zero;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) {
      if (!_running || _end == null) return;
      final now = DateTime.now();
      final left = _end!.difference(now);
      if (left <= Duration.zero) {
        setState(() {
          _remaining = Duration.zero;
          _running = false;
        });
        _ticker.stop();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Timer abgelaufen')));
        }
      } else {
        setState(() => _remaining = left);
      }
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _input.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    if (_running) return;

    final isResuming = _remaining > Duration.zero;
    Duration dur;

    if (isResuming) {
      dur = _remaining;
    } else {
      final sec = int.tryParse(_input.text.trim());
      if (sec == null || sec <= 0) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Sekunden > 0 eingeben')));
        return;
      }
      dur = Duration(seconds: sec);
    }

    setState(() {
      _end = DateTime.now().add(dur);
      _running = true;
      _remaining = dur;
    });
    _ticker.start();
  }

  void _stop() {
    // Pause
    if (!_running) return;
    _ticker.stop();
    setState(() {
      _running = false;
    });
  }

  void _reset() {
    _ticker.stop();
    setState(() {
      _running = false;
      _end = null;
      _remaining = Duration.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _input,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Dauer in Sekunden',
              border: OutlineInputBorder(),
            ),
            enabled: !_running,
          ),
          const SizedBox(height: 16),
          TimeDisplay(formatDuration(_remaining)),
          const SizedBox(height: 16),
          ActionButtons(
            running: _running,
            onStart: _start,
            onStop: _stop,
            onReset: _reset,
            canReset: _remaining > Duration.zero,
          ),
        ],
      ),
    );
  }
}
