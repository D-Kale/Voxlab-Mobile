import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../shared/widgets/chunky.dart';
import 'game_kit.dart';

/// A draggable card: fling right (true) or left (false). Buttons below do
/// the same for accessibility.
class SwipeDecider extends StatefulWidget {
  const SwipeDecider({
    super.key,
    required this.child,
    required this.onDecide,
    required this.leftLabel,
    required this.rightLabel,
    this.leftIcon = Icons.close_rounded,
    this.rightIcon = Icons.check_rounded,
    this.enabled = true,
  });

  final Widget child;
  final ValueChanged<bool> onDecide;
  final String leftLabel;
  final String rightLabel;
  final IconData leftIcon;
  final IconData rightIcon;
  final bool enabled;

  @override
  State<SwipeDecider> createState() => _SwipeDeciderState();
}

class _SwipeDeciderState extends State<SwipeDecider>
    with SingleTickerProviderStateMixin {
  double _dx = 0;
  late final AnimationController _fling = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );
  double _flingFrom = 0;
  double _flingTo = 0;

  @override
  void initState() {
    super.initState();
    _fling.addListener(() {
      setState(() => _dx = _flingFrom + (_flingTo - _flingFrom) * _fling.value);
    });
  }

  @override
  void didUpdateWidget(SwipeDecider old) {
    super.didUpdateWidget(old);
    if (old.child.key != widget.child.key) {
      _fling.stop();
      _dx = 0;
    }
  }

  @override
  void dispose() {
    _fling.dispose();
    super.dispose();
  }

  void _decide(bool right) {
    if (!widget.enabled) return;
    final width = MediaQuery.sizeOf(context).width;
    _flingFrom = _dx;
    _flingTo = right ? width : -width;
    _fling.forward(from: 0).then((_) {
      if (mounted) widget.onDecide(right);
    });
  }

  void _settle() {
    final width = MediaQuery.sizeOf(context).width;
    if (_dx.abs() > width * 0.25) {
      _decide(_dx > 0);
    } else {
      _flingFrom = _dx;
      _flingTo = 0;
      _fling.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final tilt = (_dx / width).clamp(-1.0, 1.0);
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onHorizontalDragUpdate: widget.enabled
                ? (d) => setState(() => _dx += d.delta.dx)
                : null,
            onHorizontalDragEnd: widget.enabled ? (_) => _settle() : null,
            child: Center(
              child: Transform.translate(
                offset: Offset(_dx, 0),
                child: Transform.rotate(
                  angle: tilt * pi / 14,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      widget.child,
                      if (tilt.abs() > 0.08)
                        Positioned(
                          top: 12,
                          left: tilt > 0 ? 12 : null,
                          right: tilt < 0 ? 12 : null,
                          child: Opacity(
                            opacity: (tilt.abs() * 3).clamp(0.0, 1.0),
                            child: ChunkyTag(
                              label: tilt > 0
                                  ? widget.rightLabel
                                  : widget.leftLabel,
                              icon: tilt > 0
                                  ? widget.rightIcon
                                  : widget.leftIcon,
                              color: tilt > 0
                                  ? AppColors.successDark
                                  : AppColors.accentRed,
                              filled: true,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Row(
            children: [
              Expanded(
                child: ChunkyButton(
                  label: widget.leftLabel,
                  icon: widget.leftIcon,
                  colors: ChunkyColors.red,
                  onPressed: widget.enabled ? () => _decide(false) : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ChunkyButton(
                  label: widget.rightLabel,
                  icon: widget.rightIcon,
                  colors: ChunkyColors.green,
                  onPressed: widget.enabled ? () => _decide(true) : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The white face used by the swipe decks.
class DeckCard extends StatelessWidget {
  const DeckCard({super.key, required this.text, this.emoji, this.caption});

  final String text;
  final String? emoji;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final width = min(MediaQuery.sizeOf(context).width - 56, 360.0);
    return SizedBox(
      width: width,
      child: ChunkyCard(
        radius: 28,
        depth: 8,
        padding: const EdgeInsets.fromLTRB(22, 30, 22, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null && emoji!.isNotEmpty) ...[
              Text(emoji!, style: const TextStyle(fontSize: 72)),
              const SizedBox(height: 16),
            ],
            Text(
              text,
              textAlign: TextAlign.center,
              style: gameText(22, height: 1.25),
            ),
            if (caption != null) ...[
              const SizedBox(height: 14),
              Text(
                caption!,
                textAlign: TextAlign.center,
                style: gameText(
                  14,
                  color: AppColors.darkBrownLight,
                  weight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
