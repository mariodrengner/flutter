import 'package:flutter/material.dart';
import 'package:habit_flow/features/habits/models/habits/habit.dart';
import 'package:habit_flow/features/habits/ui/widgets/empty_habits.dart';
import 'package:habit_flow/features/habits/ui/widgets/habit_list.dart';

class HabitBody extends StatelessWidget {
  const HabitBody({
    super.key,
    required this.habits,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Habit> habits;
  final void Function(String id) onToggle;
  final void Function(String id, String newName) onEdit;
  final void Function(String id) onDelete;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: habits.isEmpty
          ? const EmptyHabits()
          : HabitList(
              habits: habits,
              onToggle: onToggle,
              onEdit: onEdit,
              onDelete: onDelete,
            ),
    );
  }
}


