import 'package:flutter/material.dart';

class EmptyHabits extends StatelessWidget {
  const EmptyHabits({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add_task, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Keine Habits vorhanden',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
