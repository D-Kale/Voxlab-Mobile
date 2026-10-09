import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../domain/models/exercise.dart';
import 'map_geometry.dart';

enum PathNodeState { completed, current, pending }

class CircularPathNode extends StatelessWidget {
  const CircularPathNode({
    super.key,
    required this.state,
    required this.diameter,
    required this.background,
    required this.borderColor,
    required this.borderWidth,
    required this.iconData,
    required this.iconColor,
    required this.iconSize,
    this.completionBadge = false,
    this.voxiAsset,
    this.onTap,
    this.semanticsLabel,
  });

  final PathNodeState state;
  final double diameter;
  final Color background;
  final Color borderColor;
  final double borderWidth;
  final IconData iconData;
  final Color iconColor;
  final double iconSize;
  final bool completionBadge;

  /// When non-null, shows the Voxi mascot badge at the bottom-right.
  final String? voxiAsset;
  final VoidCallback? onTap;
  final String? semanticsLabel;

  List<BoxShadow> get shadows {
    switch (state) {
      case PathNodeState.current:
        return [
          BoxShadow(
            color: AppColors.accentRed,
            offset: const Offset(0, 6),
            blurRadius: 0,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: AppColors.accentRed.withValues(alpha: 0.3),
            offset: const Offset(0, 0),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ];
      case PathNodeState.completed:
        return [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.4),
            offset: const Offset(0, 4),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ];
      case PathNodeState.pending:
        return [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: semanticsLabel ?? '',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: background,
            border: Border.all(color: borderColor, width: borderWidth),
            boxShadow: shadows,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(iconData, size: iconSize, color: iconColor),
              if (voxiAsset != null)
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Image.asset(
                    voxiAsset!,
                    width: diameter * 0.34,
                    height: diameter * 0.34,
                    fit: BoxFit.contain,
                  ),
                ),
              if (completionBadge)
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 11,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Horizontal unit header: number badge + full title.
///
/// Replaces the old circular node that crammed the title into a 72px circle.
class UnitBanner extends StatelessWidget {
  const UnitBanner({
    super.key,
    required this.state,
    required this.unitNumber,
    required this.title,
    this.onTap,
  });

  final PathNodeState state;
  final int unitNumber;
  final String title;
  final VoidCallback? onTap;

  static const double _badgeSize = 40.0;

  @override
  Widget build(BuildContext context) {
    final isCompleted = state == PathNodeState.completed;
    final isCurrent = state == PathNodeState.current;

    final badgeBorderColor = isCompleted
        ? AppColors.success
        : isCurrent
            ? AppColors.accentRed
            : AppColors.darkBrown.withValues(alpha: 0.18);
    final badgeTextColor = isCompleted
        ? AppColors.success
        : isCurrent
            ? AppColors.accentRed
            : AppColors.onLocked;

    return Semantics(
      button: true,
      label: 'Unidad $unitNumber: $title',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isCompleted ? AppColors.success : AppColors.accentRed,
              width: 3.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isCompleted ? AppColors.success : AppColors.accentRed,
                offset: const Offset(0, 4),
                blurRadius: 0,
                spreadRadius: 0,
              ),
              const BoxShadow(
                color: Color(0x33D93B27),
                offset: Offset(0, 2),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: _badgeSize,
                height: _badgeSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                  border: Border.all(color: badgeBorderColor, width: 3),
                ),
                child: isCompleted
                    ? const Icon(
                        Icons.check_rounded,
                        size: 22,
                        color: AppColors.success,
                      )
                    : Text(
                        '$unitNumber',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: badgeTextColor,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'UNIDAD $unitNumber',
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: AppColors.darkBrownLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.darkBrown,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              if (isCurrent) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.play_arrow_rounded,
                  size: 28,
                  color: AppColors.accentRed,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Circular node for a single exercise.
///
/// Diameter is uniform across states — the current state is conveyed by
/// border/glow, never by size. Only the current node shows its label
/// (Duolingo-style), painted on a background chip so the connector line can
/// never cut through the text.
class ExercisePathNode extends StatelessWidget {
  const ExercisePathNode({
    super.key,
    required this.exercise,
    required this.state,
    this.onTap,
  });

  final Exercise exercise;
  final PathNodeState state;
  final VoidCallback? onTap;

  static const double _diameter = MapGeometry.nodeDiameter;

  @override
  Widget build(BuildContext context) {
    final typeIcon = _getTypeIcon(exercise.type);
    final typeColor = _getTypeColor(exercise.type);
    final isPending = state == PathNodeState.pending;
    final isCurrent = state == PathNodeState.current;

    final borderColor = switch (state) {
      PathNodeState.completed => AppColors.success,
      PathNodeState.current => AppColors.accentRed,
      PathNodeState.pending => AppColors.darkBrown.withValues(alpha: 0.30),
    };
    final borderWidth = switch (state) {
      PathNodeState.current => 4.0,
      PathNodeState.completed => 3.5,
      PathNodeState.pending => 3.0,
    };

    final node = CircularPathNode(
      state: state,
      diameter: _diameter,
      background: AppColors.surface,
      borderColor: borderColor,
      borderWidth: borderWidth,
      iconData: typeIcon,
      iconColor: isPending ? AppColors.onLocked : typeColor,
      iconSize: isPending ? 24.0 : 28.0,
      completionBadge: state == PathNodeState.completed,
      voxiAsset: isCurrent ? 'assets/images/voxi_awake.png' : null,
    );

    return Semantics(
      button: true,
      label: '${exercise.name} (${exercise.type})',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            node,
            if (isCurrent) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  exercise.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkBrown,
                    height: 1.15,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'reading':
        return Icons.menu_book_rounded;
      case 'quiz':
        return Icons.quiz_rounded;
      case 'writing':
        return Icons.edit_rounded;
      case 'oratory':
      case 'oratory_minigame':
        return Icons.record_voice_over_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'reading':
        return AppColors.primary;
      case 'quiz':
        return AppColors.accentRed;
      case 'writing':
        return AppColors.success;
      case 'oratory':
      case 'oratory_minigame':
        return AppColors.tertiary;
      default:
        return AppColors.onSurface;
    }
  }
}
