import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/progress_provider.dart';

/// Duolingo-style top bar: mascot plus streak, XP and completed counters.
/// Numbers pop when they change.
class TopStatsBar extends ConsumerWidget {
  const TopStatsBar({super.key, this.spotlightKey});

  /// Put on the white bar itself (not the orange padding around it) so the
  /// guided tour can spotlight exactly the bar.
  final Key? spotlightKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(authProvider.select((s) => s.user?.streakDays));
    final xp = ref.watch(totalXpStateProvider);
    final done = ref.watch(completedExerciseCountProvider);

    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: Container(
        key: spotlightKey,
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.cardBorder, width: 2),
          boxShadow: const [
            BoxShadow(color: AppColors.cardLip, offset: Offset(0, 4)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              'assets/images/voxi_awake.png',
              width: 34,
              height: 34,
              fit: BoxFit.contain,
              semanticLabel: 'Voxlab',
            ),
            _Stat(
              icon: Icons.local_fire_department_rounded,
              color: (streak ?? 0) > 0
                  ? AppColors.accentRed
                  : AppColors.darkBrownLight,
              value: streak ?? 0,
              label: 'días de racha',
            ),
            _Stat(
              icon: Icons.bolt_rounded,
              color: AppColors.primary,
              value: xp,
              label: 'XP',
            ),
            _Stat(
              icon: Icons.check_circle_rounded,
              color: AppColors.success,
              value: done,
              label: 'ejercicios completados',
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$value $label',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(width: 4),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Text(
              '$value',
              key: ValueKey(value),
              style: GoogleFonts.dmSans(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
