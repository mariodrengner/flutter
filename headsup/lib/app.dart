import 'package:flutter/material.dart';

import 'presentation/pages/home_page.dart';

class HeadsUpApp extends StatelessWidget {
  const HeadsUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2F6FED),
      brightness: Brightness.dark,
    );

    return MaterialApp(
      title: 'Heads Up! Offline',
      theme: ThemeData(
        colorScheme: scheme,
        useMaterial3: true,
        scaffoldBackgroundColor: scheme.surface,
        textTheme: ThemeData.dark().textTheme.apply(
          bodyColor: scheme.onSurface,
          displayColor: scheme.onSurface,
        ),
      ),
      home: const HeadsUpHomePage(),
    );
  }
}
