import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../data/remote/services/analyzer_service.dart';
import '../../../../domain/models/exercise_outcome.dart';
import '../../../../domain/models/session_result.dart';
import '../../../shared/widgets/chunky.dart';
import '../../../shared/widgets/lesson_widgets.dart';
import '../../../shared/widgets/motion.dart';

class WritingWidget extends ConsumerStatefulWidget {
  const WritingWidget({
    super.key,
    required this.prompt,
    required this.minWords,
    required this.maxWords,
    required this.requirements,
    required this.points,
    this.onCompleted,
  });

  final String prompt;
  final int minWords;
  final int maxWords;
  final List<String> requirements;
  final int points;
  final void Function(ExerciseOutcome outcome)? onCompleted;

  @override
  ConsumerState<WritingWidget> createState() => _WritingWidgetState();
}

class _WritingWidgetState extends ConsumerState<WritingWidget> {
  final _controller = TextEditingController();
  int _wordCount = 0;
  bool _isAnalyzing = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateWordCount);
  }

  void _updateWordCount() {
    final text = _controller.text.trim();
    final count = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;
    if (count != _wordCount) {
      setState(() => _wordCount = count);
    }
  }

  bool get _canSubmit =>
      _wordCount >= widget.minWords && _wordCount <= widget.maxWords;

  Future<void> _submit() async {
    if (!_canSubmit || _isAnalyzing) return;
    setState(() {
      _isAnalyzing = true;
      _errorText = null;
    });

    try {
      final response = await ref
          .read(analyzerServiceProvider)
          .analyzeText(
            text: _controller.text.trim(),
            requirements: widget.requirements,
            minWords: widget.minWords,
            maxWords: widget.maxWords,
          );
      final outcome = ExerciseOutcome(
        score: (response['data']?['score'] as num?)?.toInt() ?? widget.points,
        sessionResult: SessionResult.fromJson(response),
      );
      widget.onCompleted?.call(outcome);
    } catch (_) {
      // Analyzer unreachable: degrade gracefully to the heuristic score
      // so the session never blocks. TODO(ux): offer a retry instead of
      // silently falling back when the backend is back online.
      widget.onCompleted?.call(ExerciseOutcome(score: widget.points));
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_updateWordCount);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isAnalyzing) return const _Analyzing();

    final inRange = _canSubmit;
    final over = _wordCount > widget.maxWords;
    final counterColor = over
        ? AppColors.accentRed
        : inRange
        ? AppColors.onSuccessContainer
        : AppColors.darkBrownLight;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                VoxiSays(text: widget.prompt),
                if (widget.requirements.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Text(
                    'Tu texto tiene que incluir',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkBrownLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final r in widget.requirements)
                        ChunkyTag(
                          label: r,
                          icon: Icons.check_circle_outline_rounded,
                          color: AppColors.onSuccessContainer,
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 18),
                TextField(
                  controller: _controller,
                  maxLines: null,
                  minLines: 7,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Escribí tu texto aquí...',
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.all(18),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(
                        color: AppColors.cardBorder,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2.5,
                      ),
                    ),
                  ),
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkBrown,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ChunkyTag(
                      label: '$_wordCount / ${widget.maxWords} palabras',
                      icon: inRange
                          ? Icons.check_rounded
                          : Icons.short_text_rounded,
                      color: counterColor,
                    ),
                    const SizedBox(width: 8),
                    if (!inRange)
                      Text(
                        over
                            ? 'Máximo ${widget.maxWords}'
                            : 'Mínimo ${widget.minWords}',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: counterColor,
                        ),
                      ),
                  ],
                ),
                if (_errorText != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _errorText!,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accentRed,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          child: ChunkyButton(
            label: 'ENVIAR',
            icon: Icons.auto_awesome_rounded,
            colors: ChunkyColors.green,
            onPressed: _canSubmit ? _submit : null,
          ),
        ),
      ],
    );
  }
}

/// Shown while the backend AI scores the text.
class _Analyzing extends StatelessWidget {
  const _Analyzing();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Bob(
              amplitude: 6,
              child: Image.asset(
                'assets/images/voxi_awake.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Analizando tu texto con IA...',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.darkBrown,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Estamos evaluando estructura, claridad y requisitos.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.darkBrownLight,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            const SizedBox(
              width: 160,
              child: LinearProgressIndicator(
                minHeight: 10,
                borderRadius: BorderRadius.all(Radius.circular(99)),
                color: AppColors.success,
                backgroundColor: AppColors.cardBorder,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
