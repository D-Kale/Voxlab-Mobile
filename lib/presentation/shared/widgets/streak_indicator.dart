import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class StreakIndicator extends StatelessWidget {
  const StreakIndicator({
    super.key,
    required this.days,
    this.size = 'small',
  });

  final int days;
  final String size;

  bool get hasStreak => days > 0;

  Color get _color => hasStreak ? AppColors.secondary : AppColors.onSurfaceVariant;

  double get _iconSize => size == 'medium' ? 20 : 16;
  double get _fontSize => size == 'medium' ? 14 : 12;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Racha: $days días',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            excludeSemantics: true,
            child: hasStreak
                ? _AnimatedFireIcon(size: _iconSize, color: _color)
                : Icon(Icons.local_fire_department, size: _iconSize, color: _color),
          ),
          const SizedBox(width: 4),
          Text(
            '$days día${days != 1 ? 's' : ''}',
            style: TextStyle(
              fontSize: _fontSize,
              fontWeight: FontWeight.w600,
              color: _color,
            ),
          ),
        ],
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

    _scale = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _rotation = Tween<double>(begin: -0.08, end: 0.08).animate(
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
      child: Icon(Icons.local_fire_department, size: widget.size, color: widget.color),
    );
  }
}
