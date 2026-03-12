String formatDuration(Duration d, {bool showMilliseconds = false}) {
  final mm = (d.inSeconds ~/ 60).toString().padLeft(2, '0');
  final ss = (d.inSeconds % 60).toString().padLeft(2, '0');
  if (showMilliseconds) {
    final ms = (d.inMilliseconds % 1000).toString().padLeft(3, '0');
    return '$mm:$ss.$ms';
  }
  return '$mm:$ss';
}
