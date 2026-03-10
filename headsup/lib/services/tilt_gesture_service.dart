import 'dart:async';

import 'package:sensors_plus/sensors_plus.dart';

enum TiltGesture { neutral, correct, pass }

class TiltGestureService {
  TiltGestureService({
    this.downThreshold = 6.5,
    this.upThreshold = -6.5,
    this.cooldown = const Duration(milliseconds: 900),
  });

  final double downThreshold;
  final double upThreshold;
  final Duration cooldown;

  StreamSubscription<AccelerometerEvent>? _subscription;
  final _controller = StreamController<TiltGesture>.broadcast();
  DateTime _lastDispatch = DateTime.fromMillisecondsSinceEpoch(0);

  Stream<TiltGesture> get gestures => _controller.stream;

  void start() {
    _subscription ??= accelerometerEventStream().listen(
      _handleEvent,
      onError: (_) {},
    );
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null;
  }

  void dispose() {
    stop();
    _controller.close();
  }

  void _handleEvent(AccelerometerEvent event) {
    final now = DateTime.now();
    if (now.difference(_lastDispatch) < cooldown) {
      return;
    }

    if (event.y > downThreshold && event.z.abs() < 8) {
      _emit(TiltGesture.correct);
    } else if (event.y < upThreshold && event.z.abs() < 8) {
      _emit(TiltGesture.pass);
    }
  }

  void _emit(TiltGesture gesture) {
    _lastDispatch = DateTime.now();
    _controller.add(gesture);
  }
}
