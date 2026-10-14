import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';

/// Colors for a 3D "chunky" surface: the face, the darker lip under it, an
/// optional border and the content color drawn on the face.
@immutable
class ChunkyColors {
  const ChunkyColors({
    required this.face,
    required this.lip,
    required this.content,
    this.border,
  });

  final Color face;
  final Color lip;
  final Color content;
  final Color? border;

  static const red = ChunkyColors(
    face: AppColors.accentRed,
    lip: AppColors.accentRedDark,
    content: Colors.white,
  );
  static const green = ChunkyColors(
    face: AppColors.success,
    lip: AppColors.successDark,
    content: Colors.white,
  );
  static const brown = ChunkyColors(
    face: AppColors.darkBrown,
    lip: AppColors.darkBrownDeep,
    content: Colors.white,
  );
  static const orange = ChunkyColors(
    face: AppColors.primary,
    lip: AppColors.primaryDark,
    content: Colors.white,
  );
  static const gold = ChunkyColors(
    face: AppColors.gold,
    lip: AppColors.goldDark,
    content: AppColors.darkBrown,
  );
  static const white = ChunkyColors(
    face: AppColors.surface,
    lip: AppColors.cardLip,
    content: AppColors.darkBrown,
    border: AppColors.cardBorder,
  );
  static const idle = ChunkyColors(
    face: AppColors.idleFace,
    lip: AppColors.idleLip,
    content: AppColors.darkBrownLight,
  );
  static const disabled = ChunkyColors(
    face: Color(0xFFF1E4D2),
    lip: Color(0xFFD9C3A5),
    content: Color(0xFFAD9478),
  );
}

/// Shared press behavior: the face sinks into its lip while pressed, the
/// Duolingo button feel. Used by [ChunkyButton] and [ChunkyCard].
class _Pressable extends StatefulWidget {
  const _Pressable({
    required this.builder,
    required this.onTap,
    required this.depth,
  });

  final Widget Function(bool pressed) builder;
  final VoidCallback? onTap;
  final double depth;

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _pressed = false;

  void _set(bool value) {
    if (widget.onTap == null || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => _set(true) : null,
      onTapUp: enabled ? (_) => _set(false) : null,
      onTapCancel: enabled ? () => _set(false) : null,
      onTap: enabled
          ? () {
              HapticFeedback.lightImpact();
              widget.onTap!();
            }
          : null,
      child: widget.builder(_pressed),
    );
  }
}

/// Full-width 3D push button.
class ChunkyButton extends StatelessWidget {
  const ChunkyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.colors = ChunkyColors.red,
    this.icon,
    this.trailing,
    this.height = 54,
    this.depth = 5,
    this.radius = 16,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final ChunkyColors colors;
  final IconData? icon;
  final Widget? trailing;
  final double height;
  final double depth;
  final double radius;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final c = onPressed == null ? ChunkyColors.disabled : colors;
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: label,
      excludeSemantics: true,
      child: _Pressable(
        onTap: onPressed,
        depth: depth,
        builder: (pressed) => SizedBox(
          height: height + depth,
          width: expand ? double.infinity : null,
          child: Stack(
            children: [
              Positioned.fill(
                top: depth,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: c.lip,
                    borderRadius: BorderRadius.circular(radius),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 70),
                curve: Curves.easeOut,
                left: 0,
                right: 0,
                top: pressed ? depth : 0,
                height: height,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: c.face,
                    borderRadius: BorderRadius.circular(radius),
                    border: c.border == null
                        ? null
                        : Border.all(color: c.border!, width: 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 22, color: c.content),
                        const SizedBox(width: 10),
                      ],
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                            color: c.content,
                          ),
                        ),
                      ),
                      if (trailing != null) ...[
                        const SizedBox(width: 10),
                        trailing!,
                      ],
                    ],
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

/// 3D card: a face with a darker lip under it. When [onTap] is set the face
/// sinks on press like a [ChunkyButton].
class ChunkyCard extends StatelessWidget {
  const ChunkyCard({
    super.key,
    required this.child,
    this.onTap,
    this.colors = ChunkyColors.white,
    this.padding = const EdgeInsets.all(18),
    this.radius = 20,
    this.depth = 5,
    this.semanticsLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final ChunkyColors colors;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double depth;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    Widget face(bool pressed) => Padding(
          padding: EdgeInsets.only(bottom: depth),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 70),
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(0, pressed ? depth : 0, 0),
            padding: padding,
            decoration: BoxDecoration(
              color: colors.face,
              borderRadius: BorderRadius.circular(radius),
              border: colors.border == null
                  ? null
                  : Border.all(color: colors.border!, width: 2),
              boxShadow: [
                BoxShadow(
                  color: colors.lip,
                  offset: Offset(0, pressed ? 0 : depth),
                ),
              ],
            ),
            child: child,
          ),
        );

    if (onTap == null) return face(false);
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: _Pressable(onTap: onTap, depth: depth, builder: face),
    );
  }
}

/// Small rounded tag (exercise type, XP reward, status).
class ChunkyTag extends StatelessWidget {
  const ChunkyTag({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.filled = false,
  });

  final String label;
  final Color color;
  final IconData? icon;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final fg = filled ? Colors.white : color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: fg),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.dmSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: fg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
