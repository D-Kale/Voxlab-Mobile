import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/audio/sound_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../shared/widgets/chunky.dart';
import '../../shared/widgets/motion.dart';

/// Widgets the guided tour points at. They live in different screens (the
/// map and the shell's tab bar), so the keys are shared here.
class TourKeys {
  TourKeys._();

  static final statsBar = GlobalKey(debugLabel: 'tour-stats-bar');
  static final practiceTab = GlobalKey(debugLabel: 'tour-practice-tab');
  static final analyzeTab = GlobalKey(debugLabel: 'tour-analyze-tab');
  static final profileTab = GlobalKey(debugLabel: 'tour-profile-tab');
}

class TourStep {
  const TourStep({required this.title, required this.body, this.target});

  /// Widget to spotlight; null shows the card centered over a full scrim.
  final GlobalKey? target;
  final String title;
  final String body;
}

/// Shows a coach-mark tour over the whole app (including the tab bar).
/// Completes when the user finishes or skips it.
Future<void> showAppTour(BuildContext context, List<TourStep> steps) {
  final overlay = Overlay.of(context, rootOverlay: true);
  late final OverlayEntry entry;
  final done = Completer<void>();
  entry = OverlayEntry(
    builder: (_) => _TourOverlay(
      steps: steps,
      onDone: () {
        entry.remove();
        done.complete();
      },
    ),
  );
  overlay.insert(entry);
  return done.future;
}

class _TourOverlay extends StatefulWidget {
  const _TourOverlay({required this.steps, required this.onDone});

  final List<TourStep> steps;
  final VoidCallback onDone;

  @override
  State<_TourOverlay> createState() => _TourOverlayState();
}

class _TourOverlayState extends State<_TourOverlay> {
  int _index = 0;

  bool get _isLast => _index == widget.steps.length - 1;

  void _next() {
    playSfx(context, _isLast ? Sfx.unlock : Sfx.tap);
    if (_isLast) {
      widget.onDone();
    } else {
      setState(() => _index++);
    }
  }

  Rect? _targetRect(GlobalKey? key) {
    final box = key?.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return null;
    return (box.localToGlobal(Offset.zero) & box.size).inflate(8);
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.steps[_index];
    final screen = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final hole = _targetRect(step.target);
    final reduced = reduceMotion(context);
    final duration = Duration(milliseconds: reduced ? 0 : 380);

    // Card goes on the side of the screen away from the spotlight.
    final cardBelow = hole != null && hole.center.dy < screen.height / 2;
    final double? top = hole == null
        ? null
        : cardBelow
        ? hole.bottom + 16
        : null;
    final double? bottom = hole == null
        ? null
        : cardBelow
        ? null
        : screen.height - hole.top + 16;

    final card = _TourCard(
      key: ValueKey(_index),
      step: step,
      index: _index,
      count: widget.steps.length,
      isLast: _isLast,
      onNext: _next,
      onSkip: widget.onDone,
    );

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // Absorbs taps so the app underneath cannot be used mid-tour.
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},
              child: TweenAnimationBuilder<Rect?>(
                tween: RectTween(end: hole ?? _collapsed(screen)),
                duration: duration,
                curve: Curves.easeInOutCubic,
                builder: (context, rect, _) => CustomPaint(
                  painter: _ScrimPainter(hole: hole == null ? null : rect),
                ),
              ),
            ),
          ),
          if (hole == null)
            Positioned.fill(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: card,
                ),
              ),
            )
          else
            AnimatedPositioned(
              duration: duration,
              curve: Curves.easeInOutCubic,
              left: 16,
              right: 16,
              top: top?.clamp(padding.top + 8, screen.height - 260),
              bottom: bottom?.clamp(padding.bottom + 8, screen.height - 200),
              child: card,
            ),
        ],
      ),
    );
  }

  static Rect _collapsed(Size screen) =>
      Rect.fromCenter(center: screen.center(Offset.zero), width: 0, height: 0);
}

class _ScrimPainter extends CustomPainter {
  _ScrimPainter({required this.hole});

  final Rect? hole;

  @override
  void paint(Canvas canvas, Size size) {
    final scrim = Path()..addRect(Offset.zero & size);
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.62);
    if (hole == null) {
      canvas.drawPath(scrim, paint);
      return;
    }
    final rrect = RRect.fromRectAndRadius(hole!, const Radius.circular(22));
    canvas.drawPath(
      Path.combine(PathOperation.difference, scrim, Path()..addRRect(rrect)),
      paint,
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(_ScrimPainter old) => old.hole != hole;
}

class _TourCard extends StatelessWidget {
  const _TourCard({
    super.key,
    required this.step,
    required this.index,
    required this.count,
    required this.isLast,
    required this.onNext,
    required this.onSkip,
  });

  final TourStep step;
  final int index;
  final int count;
  final bool isLast;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return EntranceAnimation(
      scaleFrom: 0.85,
      offsetY: 10,
      duration: const Duration(milliseconds: 320),
      child: ChunkyCard(
        radius: 22,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Bob(
                  amplitude: 3,
                  child: Image.asset(
                    'assets/images/voxi_awake.png',
                    width: 56,
                    height: 56,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style: GoogleFonts.dmSans(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          color: AppColors.darkBrown,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step.body,
                        style: GoogleFonts.dmSans(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkBrownLight,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                for (var i = 0; i < count; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 5),
                    width: i == index ? 18 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: i == index
                          ? AppColors.accentRed
                          : AppColors.cardBorder,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                const Spacer(),
                if (!isLast)
                  TextButton(
                    onPressed: onSkip,
                    child: Text(
                      'SALTAR',
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w900,
                        color: AppColors.darkBrownLight,
                      ),
                    ),
                  ),
                const SizedBox(width: 6),
                SizedBox(
                  width: isLast ? 130 : 132,
                  child: ChunkyButton(
                    label: isLast ? '¡VAMOS!' : 'SIGUIENTE',
                    height: 44,
                    depth: 4,
                    colors: isLast ? ChunkyColors.green : ChunkyColors.red,
                    onPressed: onNext,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
