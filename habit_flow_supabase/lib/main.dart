import 'package:flutter/material.dart';
import 'package:habit_flow/core/services/env_service.dart';
import 'package:habit_flow/core/services/hive_service.dart';
import 'package:habit_flow/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeSupabase();
  await initializeHive();

  runApp(const App());
}
