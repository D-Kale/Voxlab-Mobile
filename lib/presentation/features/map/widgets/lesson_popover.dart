import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/widgets/chunky.dart';
import '../../../shared/widgets/motion.dart';

/// Shows a Duolingo-style card anchored under (or above) a map node.
///
/// [anchor] is the node's global rect. The card points at the node with a
/// small arrow and grows out of it. Tapping outside dismisses it.
Future<void> showLessonPopover(
  BuildContext context, {
  required Rect anchor,
  required ChunkyColors colors,
  required String title,
  required String subtitle,
  String? buttonLabel,
  VoidCallback? onStart,
}) {
  return Navigator.of(context).push(
    PageRouteBuilder<void>(
      opaque: false,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.12),
      barrierLabel: 'Cerrar',
      transitionDuration: const Duration(milliseconds: 240),
      reverseTransitionDuration: const Duration(milliseconds: 140),
      pageBuilder: (context, animation, _) => _PopoverLayer(
        animation: animation,
        anchor: anchor,
        colors: colors,
        title: title,
        subtitle: subtitle,
        buttonLabel: buttonLabel,
        onStart: onStart,
      ),
    ),
  );
}

class _PopoverLayer extends StatelessWidget {
  const _PopoverLayer({
    required this.animation,
    required this.anchor,
    required this.colors,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onStart,
  });

  final Animation<double> animation;
  final Rect anchor;
  final ChunkyColors colors;
  final String title;
  final String subtitle;
  final String? buttonLabel;
  final VoidCallback? onStart;

  static const double _arrow = 12;
  static const double _gap = 6;
  static const double _side = 16;
  static const double _estimatedHeight = 190;

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final below =
        anchor.bottom + _gap + _estimatedHeight <
        screen.height - padding.bottom - 80;
    final cardWidth = (screen.width - _side * 2).clamp(0.0, 420.0);
    final left = ((screen.width - cardWidth) / 2);
    final arrowX = (anchor.center.dx - left).clamp(28.0, cardWidth - 28.0);

    final curved = CurvedAnimation(
      parent: animation,
      curve: reduceMotion(context) ? Curves.linear : Curves.easeOutBack,
      reverseCurve: Curves.easeIn,
    );

    final arrow = CustomPaint(
      size: const Size(_arrow * 2, _arrow),
      painter: _ArrowPainter(
        color: below ? colors.face : colors.lip,
        pointsUp: below,
      ),
    );

    final card = Material(
      type: MaterialType.transparency,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (below)
            Padding(
              padding: EdgeInsets.only(left: arrowX - _arrow),
              child: arrow,
            ),
          ChunkyCard(
            colors: colors,
            radius: 18,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.dmSans(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: colors.content,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.content.withValues(alpha: 0.85),
                    height: 1.35,
                  ),
                ),
                if (buttonLabel != null) ...[
                  const SizedBox(height: 14),
                  ChunkyButton(
                    label: buttonLabel!,
                    colors: ChunkyColors(
                      face: Colors.white,
                      lip: Color.lerp(colors.lip, Colors.black, 0.15)!,
                      content: colors.face,
                    ),
                    onPressed: onStart == null
                        ? null
                        : () {
                            Navigator.of(context).pop();
                            onStart!();
                          },
                  ),
                ],
              ],
            ),
          ),
          if (!below)
            Padding(
              padding: EdgeInsets.only(left: arrowX - _arrow),
              child: arrow,
            ),
        ],
      ),
    );

    return Stack(
      children: [
        Positioned(
          left: left,
          width: cardWidth,
          top: below ? anchor.bottom + _gap : null,
          bottom: below ? null : screen.height - anchor.top + _gap,
          child: FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.85, end: 1).animate(curved),
              alignment: Alignment(
                (arrowX / cardWidth) * 2 - 1,
                below ? -1 : 1,
              ),
              child: card,
            ),
          ),
        ),
      ],
    );
  }
}

class _ArrowPainter extends CustomPainter {
  _ArrowPainter({required this.color, required this.pointsUp});

  final Color color;
  final bool pointsUp;

  @override
  void paint(Canvas canvas, Size size) {
    final path = pointsUp
        ? (Path()
            ..moveTo(0, size.height + 1)
            ..lineTo(size.width / 2, 0)
            ..lineTo(size.width, size.height + 1))
        : (Path()
            ..moveTo(0, -1)
            ..lineTo(size.width / 2, size.height)
            ..lineTo(size.width, -1));
    canvas.drawPath(path..close(), Paint()..color = color);
  }

  @override
  bool shouldRepaint(_ArrowPainter old) =>
      old.color != color || old.pointsUp != pointsUp;
}
