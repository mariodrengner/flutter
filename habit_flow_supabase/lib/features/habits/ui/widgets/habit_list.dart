import 'package:flutter/material.dart';
import 'package:habit_flow/features/habits/models/habits/habit.dart';
import 'package:habit_flow/features/habits/ui/widgets/edit_habit_dialog.dart';

class HabitList extends StatelessWidget {
  const HabitList({
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
    return ListView.separated(
      itemCount: habits.length,
      itemBuilder: (context, index) {
        final habit = habits[index];
        return ListTile(
          leading: IconButton(
            icon: Icon(
              habit.isCompletedToday
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: habit.isCompletedToday ? Colors.green : null,
            ),
            onPressed: () => onToggle(habit.id),
          ),
          title: Text(
            habit.name,
            style: TextStyle(
              decoration: habit.isCompletedToday
                  ? TextDecoration.lineThrough
                  : null,
              color: habit.isCompletedToday ? Colors.grey : null,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => showEditHabitDialog(
                  context: context,
                  habit: habit,
                  onEdit: onEdit,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => onDelete(habit.id),
              ),
            ],
          ),
        );
      },
      separatorBuilder: (context, index) =>
          const Divider(thickness: 1, color: Colors.white10),
    );
  }
}
