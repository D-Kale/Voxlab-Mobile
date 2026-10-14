import 'package:flutter/material.dart';

/// Whether the user asked the platform to reduce motion. Decorative loops and
/// entrance effects check this and render their final, static frame instead.
bool reduceMotion(BuildContext context) =>
    MediaQuery.maybeDisableAnimationsOf(context) ?? false;

/// One-shot entrance: fades in, rises and grows into place.
///
/// [delay] staggers siblings. The delay is part of the controller timeline
/// (an [Interval]) rather than a [Future.delayed], so no timer outlives the
/// widget and widget tests settle normally.
class EntranceAnimation extends StatefulWidget {
  const EntranceAnimation({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 420),
    this.offsetY = 18,
    this.scaleFrom = 0.92,
    this.curve = Curves.easeOutBack,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final double offsetY;
  final double scaleFrom;
  final Curve curve;

  /// Stagger helper for list items: 60 ms per index, capped so long lists
  /// do not keep the last item waiting.
  static Duration stagger(int index, {int stepMs = 60, int maxSteps = 8}) =>
      Duration(milliseconds: stepMs * index.clamp(0, maxSteps));

  @override
  State<EntranceAnimation> createState() => _EntranceAnimationState();
}

class _EntranceAnimationState extends State<EntranceAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;
  late final Animation<double> _opacity;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    final total = widget.delay + widget.duration;
    _controller = AnimationController(vsync: this, duration: total);
    final start = total.inMicroseconds == 0
        ? 0.0
        : widget.delay.inMicroseconds / total.inMicroseconds;
    _progress = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, 1, curve: widget.curve),
    );
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, (start + 0.35).clamp(0, 1), curve: Curves.easeOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (reduceMotion(context)) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
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
      child: widget.child,
      builder: (context, child) {
        final t = _progress.value;
        return Opacity(
          opacity: _opacity.value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, widget.offsetY * (1 - t)),
            child: Transform.scale(
              scale: widget.scaleFrom + (1 - widget.scaleFrom) * t,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// Endless gentle float, used for the mascot and call-out bubbles.
class Bob extends StatefulWidget {
  const Bob({
    super.key,
    required this.child,
    this.amplitude = 4,
    this.period = const Duration(milliseconds: 1400),
  });

  final Widget child;
  final double amplitude;
  final Duration period;

  @override
  State<Bob> createState() => _BobState();
}

class _BobState extends State<Bob> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.period);
  late final Animation<double> _curve =
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reduceMotion(context)) {
      _controller.stop();
      _controller.value = 0.5;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      child: widget.child,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, widget.amplitude * (_curve.value * 2 - 1)),
        child: child,
      ),
    );
  }
}

/// Repeating "look here" ripple drawn behind a child, e.g. the current map
/// node. Draws nothing when motion is reduced.
class PulseHalo extends StatefulWidget {
  const PulseHalo({
    super.key,
    required this.color,
    required this.diameter,
    this.spread = 26,
    this.period = const Duration(milliseconds: 1800),
  });

  final Color color;
  final double diameter;
  final double spread;
  final Duration period;

  @override
  State<PulseHalo> createState() => _PulseHaloState();
}

class _PulseHaloState extends State<PulseHalo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.period);
  bool _reduced = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = reduceMotion(context);
    if (_reduced) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.diameter + widget.spread * 2;
    if (_reduced) return SizedBox.square(dimension: size);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = Curves.easeOut.transform(_controller.value);
        return SizedBox.square(
          dimension: size,
          child: Center(
            child: Container(
              width: widget.diameter + widget.spread * 2 * t,
              height: widget.diameter + widget.spread * 2 * t,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withValues(alpha: 0.35 * (1 - t)),
              ),
            ),
          ),
        );
      },
    );
  }
}
