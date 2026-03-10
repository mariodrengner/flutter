import 'package:flutter/material.dart';

class HabitAppBarActions extends StatelessWidget {
  const HabitAppBarActions({
    super.key,
    required this.showProgress,
    required this.progressText,
    required this.isSyncing,
    required this.onSync,
  });

  final bool showProgress;
  final String progressText;
  final bool isSyncing;
  final VoidCallback onSync;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showProgress)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Text(progressText, style: const TextStyle(fontSize: 14)),
            ),
          ),
        IconButton(
          onPressed: isSyncing ? null : onSync,
          icon: isSyncing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.sync),
          tooltip: 'Synchronisieren',
        ),
      ],
    );
  }
}
