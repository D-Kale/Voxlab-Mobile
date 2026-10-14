import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/models/exercise_outcome.dart';
import '../../../shared/widgets/chunky.dart';
import '../../../shared/widgets/lesson_widgets.dart';

class ReadingWidget extends StatefulWidget {
  const ReadingWidget({
    super.key,
    required this.title,
    required this.content,
    required this.readingTimeSeconds,
    required this.points,
    this.onCompleted,
  });

  final String title;
  final String content;
  final int readingTimeSeconds;
  final int points;
  final void Function(ExerciseOutcome outcome)? onCompleted;

  @override
  State<ReadingWidget> createState() => _ReadingWidgetState();
}

class _ReadingWidgetState extends State<ReadingWidget> {
  bool _isReadingComplete = false;
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _hasScrolledToBottom = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _startTimer();
    // A text that fits without scrolling is already read to the bottom;
    // otherwise the button stayed on "Leyendo..." for the whole timer.
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll <= 0 ||
        (currentScroll >= maxScroll - 10 && !_hasScrolledToBottom)) {
      setState(() => _hasScrolledToBottom = true);
    }
  }

  bool get _canScroll =>
      _scrollController.hasClients &&
      _scrollController.position.maxScrollExtent > 0;

  bool get _canComplete =>
      _hasScrolledToBottom || _elapsedSeconds >= widget.readingTimeSeconds;

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_elapsedSeconds >= widget.readingTimeSeconds) {
        timer.cancel();
        if (mounted) setState(() {});
      } else {
        setState(() => _elapsedSeconds++);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _markAsRead() {
    _timer?.cancel();
    setState(() => _isReadingComplete = true);
  }

  void _continueToSummary() {
    widget.onCompleted?.call(ExerciseOutcome(score: widget.points));
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.readingTimeSeconds - _elapsedSeconds;
    final minutes = remaining ~/ 60;
    final seconds = remaining % 60;
    final progress = _isReadingComplete || widget.readingTimeSeconds == 0
        ? 1.0
        : _elapsedSeconds / widget.readingTimeSeconds;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: LessonProgressBar(
                value: progress,
                color: _canComplete ? AppColors.success : AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Semantics(
              label: 'Tiempo restante: $minutes minutos con $seconds segundos',
              excludeSemantics: true,
              child: ChunkyTag(
                label: '$minutes:${seconds.toString().padLeft(2, '0')}',
                icon: Icons.timer_rounded,
                color: AppColors.onPrimaryContainer,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Leé con atención',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.darkBrownLight,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.title,
          style: GoogleFonts.dmSans(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.darkBrown,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: ChunkyCard(
            padding: EdgeInsets.zero,
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              child: Text(
                widget.content,
                style: GoogleFonts.dmSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkBrown,
                  height: 1.65,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Semantics(
          label: _isReadingComplete
              ? 'Continuar a resumen del ejercicio'
              : _canComplete
              ? 'Marcar como leído'
              : _canScroll
              ? 'Desplazate hasta el final para completar'
              : 'Leyendo...',
          child: ChunkyButton(
            label: _isReadingComplete
                ? 'CONTINUAR'
                : _canComplete
                ? 'MARCAR COMO LEÍDO'
                : _canScroll
                ? 'DESPLAZATE HASTA EL FINAL'
                : 'LEYENDO...',
            colors: ChunkyColors.green,
            onPressed: _isReadingComplete
                ? _continueToSummary
                : _canComplete
                ? _markAsRead
                : null,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
