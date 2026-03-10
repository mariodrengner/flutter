import 'package:flutter/material.dart';
import 'package:habit_flow/features/habits/models/habits/habit.dart';

Future<void> showEditHabitDialog({
  required BuildContext context,
  required Habit habit,
  required void Function(String id, String newName) onEdit,
}) {
  final editController = TextEditingController(text: habit.name);
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Habit bearbeiten'),
        content: TextField(
          autofocus: true,
          controller: editController,
          decoration: const InputDecoration(hintText: 'Habit Name'),
        ),
        actions: [
          TextButton(
            child: const Text('Abbrechen'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Speichern'),
            onPressed: () {
              onEdit(habit.id, editController.text);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

