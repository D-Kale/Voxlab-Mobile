import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

enum PathNodeState { completed, current, pending }

class PathLessonNode extends StatelessWidget {
  const PathLessonNode({
    super.key,
    required this.state,
    required this.label,
    this.onTap,
  });

  final PathNodeState state;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final diameter = state == PathNodeState.current ? 72.0 : 64.0;
    final (
      Color background,
      Color borderColor,
      IconData iconData,
      Color iconColor,
      double iconSize,
    ) = switch (state) {
      PathNodeState.completed => (
          AppColors.secondary,
          const Color(0xFF1EA952),
          Icons.star,
          AppColors.onSurface,
          30,
        ),
      PathNodeState.current => (
          AppColors.primary,
          const Color(0xFF5B21B6),
          Icons.play_arrow,
          AppColors.onPrimary,
          40,
        ),
      PathNodeState.pending => (
          AppColors.locked,
          const Color(0xFFD6D3CA),
          Icons.star_outline,
          AppColors.onLocked,
          30,
        ),
    };

    return Semantics(
      button: true,
      enabled: onTap != null,
      label: label,
      child: Material(
        color: background,
        elevation: state == PathNodeState.completed ? 4 : 0,
        shadowColor: Colors.black26,
        shape: CircleBorder(
          side: BorderSide(color: borderColor, width: 3),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: diameter,
            height: diameter,
            child: Center(
              child: Semantics(
                excludeSemantics: true,
                child: Icon(iconData, size: iconSize, color: iconColor),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
