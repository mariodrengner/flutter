import 'package:habit_flow/features/auth/models/user/user.dart';
import 'package:habit_flow/features/habits/models/habits/habit.dart';
import 'package:habit_flow/hive_registrar.g.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

Future<void> initializeHive() async {
  await Hive.initFlutter();
  Hive.registerAdapters();
  await Hive.openBox<Habit>('habits');
  await Hive.openBox<User>('user');
}
