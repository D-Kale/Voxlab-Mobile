import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/models/exercise_outcome.dart';

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
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll <= 0 || (currentScroll >= maxScroll - 10 && !_hasScrolledToBottom)) {
      setState(() => _hasScrolledToBottom = true);
    }
  }

  bool get _canScroll => _scrollController.hasClients && _scrollController.position.maxScrollExtent > 0;

  bool get _canComplete => _hasScrolledToBottom || _elapsedSeconds >= widget.readingTimeSeconds;

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
    final theme = Theme.of(context);
    final remaining = widget.readingTimeSeconds - _elapsedSeconds;
    final minutes = remaining ~/ 60;
    final seconds = remaining % 60;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Semantics(
                excludeSemantics: true,
                child: Icon(Icons.timer, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 8),
              Semantics(
                label: 'Tiempo restante: $minutes minutos con $seconds segundos',
                child: Text(
                  '$minutes:${seconds.toString().padLeft(2, '0')}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
              const Spacer(),
              Semantics(
                label: 'Recompensa: ${widget.points} puntos de experiencia',
                child: Text(
                  '+${widget.points} XP',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _isReadingComplete ? 1.0 : _elapsedSeconds / widget.readingTimeSeconds,
            backgroundColor: AppColors.surfaceContainerHigh,
            valueColor: AlwaysStoppedAnimation(
              _isReadingComplete ? AppColors.success : AppColors.primary,
            ),
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
          const SizedBox(height: 24),
          Text(
            widget.title,
            style: theme.textTheme.titleLarge?.copyWith(height: 1.3),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Text(
                widget.content,
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
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
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isReadingComplete
                    ? _continueToSummary
                    : _canComplete
                        ? _markAsRead
                        : null,
                style: _isReadingComplete
                    ? ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: AppColors.onSurface,
                      )
                    : null,
                child: Text(
                  _isReadingComplete
                      ? 'Continuar'
                      : _canComplete
                          ? 'Marcar como leído'
                          : _canScroll
                              ? 'Desplazate hasta el final'
                              : 'Leyendo...',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
