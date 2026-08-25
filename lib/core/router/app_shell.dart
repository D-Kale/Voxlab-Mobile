import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static const _destinations = [
    (
      path: '/map',
      icon: Icons.map_outlined,
      selected: Icons.map,
      label: 'Aprender',
    ),
    (
      path: '/practice',
      icon: Icons.fitness_center_outlined,
      selected: Icons.fitness_center,
      label: 'Practicar',
    ),
    (
      path: '/analyze',
      icon: Icons.insights_outlined,
      selected: Icons.insights,
      label: 'Analizar',
    ),
    (
      path: '/profile',
      icon: Icons.person_outline,
      selected: Icons.person,
      label: 'Perfil',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uri = GoRouterState.of(context).uri.toString();
    final currentIndex = _destinations.indexWhere((d) => uri.startsWith(d.path));

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex < 0 ? 0 : currentIndex,
        onDestinationSelected: (index) {
          context.go(_destinations[index].path);
        },
        destinations: [
          for (final d in _destinations)
            NavigationDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.selected),
              label: d.label,
            ),
        ],
      ),
    );
  }
}
