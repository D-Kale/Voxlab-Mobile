import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import 'path_lesson_node.dart';

class UnitHeaderPill extends StatelessWidget {
  const UnitHeaderPill({
    super.key,
    required this.unitNumber,
    required this.title,
    required this.state,
    this.onTap,
  });

  final int unitNumber;
  final String title;
  final PathNodeState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (
      Color background,
      Color overlineColor,
      Color titleColor,
      List<BoxShadow>? shadows,
    ) = switch (state) {
      PathNodeState.completed => (
          AppColors.secondary,
          AppColors.onSecondary,
          AppColors.onSecondary,
          const [
            BoxShadow(color: Color(0xFF1EA952), offset: Offset(0, 4)),
          ],
        ),
      PathNodeState.current => (
          AppColors.surface,
          AppColors.primary,
          AppColors.onSurface,
          null,
        ),
      PathNodeState.pending => (
          AppColors.locked,
          AppColors.onLocked,
          AppColors.onLocked,
          null,
        ),
    };

    return Semantics(
      button: true,
      enabled: onTap != null,
      label: 'Unidad $unitNumber: $title',
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(28),
          border: state == PathNodeState.current
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
          boxShadow: shadows,
        ),
        child: Material(
          color: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'UNIDAD $unitNumber',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                            color: overlineColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: titleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _StatusCircle(state: state),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusCircle extends StatelessWidget {
  const _StatusCircle({required this.state});

  final PathNodeState state;

  @override
  Widget build(BuildContext context) {
    final (Color background, IconData iconData, Color iconColor) =
        switch (state) {
          PathNodeState.completed => (
              AppColors.surface,
              Icons.check,
              const Color(0xFF1EA952),
            ),
          PathNodeState.current => (
              AppColors.primaryContainer,
              Icons.pause,
              AppColors.primary,
            ),
          PathNodeState.pending => (
              AppColors.surface,
              Icons.star_outline,
              AppColors.onLocked,
            ),
        };

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: background,
      ),
      child: Center(
        child: Semantics(
          excludeSemantics: true,
          child: Icon(iconData, size: 16, color: iconColor),
        ),
      ),
    );
  }
}
