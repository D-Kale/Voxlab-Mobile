import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class OratoryWidget extends StatefulWidget {
  const OratoryWidget({
    super.key,
    required this.prompt,
    required this.topic,
    required this.durationSeconds,
    required this.minDurationSeconds,
    required this.requirements,
    required this.points,
    this.onCompleted,
  });

  final String prompt;
  final String topic;
  final int durationSeconds;
  final int minDurationSeconds;
  final List<String> requirements;
  final int points;
  final void Function(int score)? onCompleted;

  @override
  State<OratoryWidget> createState() => _OratoryWidgetState();
}

class _OratoryWidgetState extends State<OratoryWidget> {
  bool _isStarted = false;
  bool _isFinished = false;
  int _remainingSeconds = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    setState(() {
      _isStarted = true;
      _remainingSeconds = widget.durationSeconds;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        timer.cancel();
        if (mounted) setState(() => _remainingSeconds = 0);
      } else {
        if (mounted) setState(() => _remainingSeconds--);
      }
    });
  }

  void _finish() {
    _timer?.cancel();
    setState(() => _isFinished = true);
    widget.onCompleted?.call(widget.points);
  }

  double get _progress =>
      _remainingSeconds / widget.durationSeconds;

  @override
  Widget build(BuildContext context) {
    if (_isFinished) {
      return _buildSummary();
    }

    if (!_isStarted) {
      return _buildPreparation();
    }

    return _buildActive();
  }

  Widget _buildPreparation() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            label: 'Recompensa: ${widget.points} puntos de experiencia',
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, size: 18, color: AppColors.secondary),
                const SizedBox(width: 6),
                Text(
                  '+${widget.points} XP',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Semantics(
                  excludeSemantics: true,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.record_voice_over,
                      size: 28,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.topic,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.prompt,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          if (widget.requirements.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'Objetivos',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            ...widget.requirements.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '• ',
                      style: TextStyle(color: AppColors.primary, fontSize: 16),
                    ),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.timer_outlined, size: 16, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                '${widget.durationSeconds}s · mínimo ${widget.minDurationSeconds}s',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Semantics(
            label: 'Comenzar ejercicio de oratoria',
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _start,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Comenzar'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActive() {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Semantics(
            label: 'Tiempo restante: $minutes minutos con $seconds segundos',
            child: Column(
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: CircularProgressIndicator(
                          value: _progress,
                          strokeWidth: 8,
                          backgroundColor: AppColors.surfaceContainerHigh,
                          valueColor: AlwaysStoppedAnimation(
                            _progress < 0.25 ? AppColors.error : AppColors.primary,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$minutes:${seconds.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: _progress < 0.25
                                  ? AppColors.error
                                  : AppColors.onSurface,
                            ),
                          ),
                          const Text(
                            'Hablando...',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Semantics(
            label: 'Finalizar ejercicio de oratoria',
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _finish,
                icon: const Icon(Icons.stop),
                label: const Text('Finalizar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.onSurface,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    final elapsed = widget.durationSeconds - _remainingSeconds;
    final metMinimum = elapsed >= widget.minDurationSeconds;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Semantics(
              excludeSemantics: true,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: (metMinimum ? AppColors.success : AppColors.secondary)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  metMinimum ? Icons.mic : Icons.mic_none,
                  size: 40,
                  color: metMinimum ? AppColors.success : AppColors.secondary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '¡Ejercicio completado!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${elapsed}s de duración · +${widget.points} XP',
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            if (!metMinimum)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Mínimo: ${widget.minDurationSeconds}s',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.error,
                  ),
                ),
              ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => widget.onCompleted?.call(widget.points),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: AppColors.onSurface,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Continuar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
