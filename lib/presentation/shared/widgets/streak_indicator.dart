import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import 'voxi_state.dart';

class StreakIndicator extends StatelessWidget {
  const StreakIndicator({
    super.key,
    required this.days,
    this.size = 'small',
    this.showVoxi = false,
    this.voxiState = VoxiState.awake,
  });

  final int days;
  final String size;
  final bool showVoxi;
  final VoxiState voxiState;

  bool get hasStreak => days > 0;

  Color get _color => hasStreak ? AppColors.accentRed : AppColors.darkBrownLight;

  double get _iconSize => size == 'medium' ? 22 : 18;
  double get _fontSize => size == 'medium' ? 16 : 14;
  double get _voxiSize => size == 'medium' ? 28 : 22;

  @override
  Widget build(BuildContext context) {
    final voxiAsset = voxiState == VoxiState.awake
        ? 'assets/images/voxi_awake.png'
        : 'assets/images/voxi_sleeping.png';

    return Semantics(
      label: 'Racha: $days días',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: hasStreak ? AppColors.accentRedContainer : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: hasStreak ? AppColors.accentRed : AppColors.outline,
            width: 3,
          ),
          boxShadow: hasStreak
              ? [
                  BoxShadow(
                    color: AppColors.accentRed,
                    offset: const Offset(0, 4),
                    blurRadius: 0,
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: AppColors.accentRed.withValues(alpha: 0.2),
                    offset: const Offset(0, 2),
                    blurRadius: 6,
                    spreadRadius: 0,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                    spreadRadius: 0,
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showVoxi) ...[
              Image.asset(
                voxiAsset,
                width: _voxiSize,
                height: _voxiSize,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 6),
            ],
            Semantics(
              excludeSemantics: true,
              child: hasStreak
                  ? _AnimatedFireIcon(size: _iconSize, color: _color)
                  : Icon(Icons.local_fire_department_outlined, size: _iconSize, color: _color),
            ),
            const SizedBox(width: 6),
            Text(
              '$days día${days != 1 ? 's' : ''}',
              style: GoogleFonts.dmSans(
                fontSize: _fontSize,
                fontWeight: FontWeight.w800,
                color: hasStreak ? AppColors.darkBrown : AppColors.darkBrownLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedFireIcon extends StatefulWidget {
  const _AnimatedFireIcon({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  State<_AnimatedFireIcon> createState() => _AnimatedFireIconState();
}

class _AnimatedFireIconState extends State<_AnimatedFireIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scale = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _rotation = Tween<double>(begin: -0.06, end: 0.06).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) => Transform.rotate(
        angle: _rotation.value,
        child: Transform.scale(
          scale: _scale.value,
          child: child,
        ),
      ),
      child: Icon(Icons.local_fire_department_rounded, size: widget.size, color: widget.color),
    );
  }
}