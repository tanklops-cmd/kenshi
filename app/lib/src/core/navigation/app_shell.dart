import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kendo_companion/src/core/widgets/atmospheric_background.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _selectDestination(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      // Atmospheric background is visible during page transitions
      // when the entering screen is fading in.
      body: Stack(
        children: [
          const Positioned.fill(child: AtmosphericBackground()),
          navigationShell,
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(
            height: 1,
            thickness: 0.5,
            color: colorScheme.outlineVariant,
          ),
          NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _selectDestination,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.today_outlined),
                selectedIcon: Icon(Icons.today),
                label: 'Today',
              ),
              NavigationDestination(
                icon: Icon(Icons.history_edu_outlined),
                selectedIcon: Icon(Icons.history_edu),
                label: 'Reflect',
              ),
              NavigationDestination(
                icon: Icon(Icons.sports_martial_arts_outlined),
                selectedIcon: Icon(Icons.sports_martial_arts),
                label: 'Practice',
              ),
              NavigationDestination(
                icon: Icon(Icons.auto_stories_outlined),
                selectedIcon: Icon(Icons.auto_stories),
                label: 'Learn',
              ),
              NavigationDestination(
                icon: Icon(Icons.explore_outlined),
                selectedIcon: Icon(Icons.explore),
                label: 'Prepare',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

