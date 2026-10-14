import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../presentation/features/tour/app_tour.dart';
import '../constants/app_colors.dart';
import 'routes.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static const _destinations = [
    (
      path: AppRoutes.map,
      icon: Icons.map_outlined,
      selected: Icons.map_rounded,
      label: 'Aprender',
    ),
    (
      path: AppRoutes.practice,
      icon: Icons.fitness_center_outlined,
      selected: Icons.fitness_center_rounded,
      label: 'Practicar',
    ),
    (
      path: AppRoutes.analyze,
      icon: Icons.insights_outlined,
      selected: Icons.insights_rounded,
      label: 'Analizar',
    ),
    (
      path: AppRoutes.profile,
      icon: Icons.person_outline_rounded,
      selected: Icons.person_rounded,
      label: 'Perfil',
    ),
  ];

  /// Spotlight targets for the first-run tour (Aprender has none: the tour
  /// already points at the map itself).
  static final _tourKeys = <GlobalKey?>[
    null,
    TourKeys.practiceTab,
    TourKeys.analyzeTab,
    TourKeys.profileTab,
  ];

  @override
  Widget build(BuildContext context) {
    final uri = GoRouterState.of(context).uri.toString();
    final index = _destinations.indexWhere((d) => uri.startsWith(d.path));
    final currentIndex = index < 0 ? 0 : index;

    return Scaffold(
      body: child,
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.cardBorder, width: 2),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 68,
            child: Row(
              children: [
                for (var i = 0; i < _destinations.length; i++)
                  Expanded(
                    key: _tourKeys[i],
                    child: _NavItem(
                      icon: _destinations[i].icon,
                      selectedIcon: _destinations[i].selected,
                      label: _destinations[i].label,
                      selected: i == currentIndex,
                      onTap: () {
                        if (i == currentIndex) return;
                        HapticFeedback.selectionClick();
                        context.go(_destinations[i].path);
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tab item: the selected tab sits in a tinted, outlined tile and its icon
/// pops; labels stay visible in both states.
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.accentRed : AppColors.darkBrownLight;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: 36,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              width: 56,
              height: 36,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.accentRedContainer
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? AppColors.accentRed : Colors.transparent,
                  width: 2,
                ),
              ),
              child: AnimatedScale(
                scale: selected ? 1.12 : 1,
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutBack,
                child: Icon(
                  selected ? selectedIcon : icon,
                  color: color,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 11.5,
                fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
