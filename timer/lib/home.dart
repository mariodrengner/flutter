import 'package:flutter/material.dart';
import 'timer.dart';
import 'stopwatch.dart';
import 'compare.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _i = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _i,
        children: const [TimerScreen(), StopwatchScreen(), CompareScreen()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _i,
        onDestinationSelected: (v) => setState(() => _i = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.timer), label: 'Timer'),
          NavigationDestination(icon: Icon(Icons.av_timer), label: 'Stoppuhr'),
          NavigationDestination(
            icon: Icon(Icons.compare_arrows),
            label: 'Vergleich',
          ),
        ],
      ),
    );
  }
}
