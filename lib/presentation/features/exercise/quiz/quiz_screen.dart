import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../domain/models/exercise_content.dart';
import '../../../../domain/models/exercise_outcome.dart';
import '../../../shared/widgets/chunky.dart';
import '../../../shared/widgets/lesson_widgets.dart';

class QuizWidget extends StatefulWidget {
  const QuizWidget({
    super.key,
    required this.questions,
    required this.pointsPerQuestion,
    this.onCompleted,
  });

  final List<QuizQuestion> questions;
  final int pointsPerQuestion;
  final void Function(ExerciseOutcome outcome)? onCompleted;

  @override
  State<QuizWidget> createState() => _QuizWidgetState();
}

class _QuizWidgetState extends State<QuizWidget> {
  int _currentIndex = 0;
  int? _selectedIndex;
  bool _checked = false;
  int _correctCount = 0;

  List<QuizQuestion> get _questions => widget.questions;

  QuizQuestion get _currentQuestion => _questions[_currentIndex];

  bool get _isLastQuestion => _currentIndex == _questions.length - 1;

  bool get _isCorrect => _selectedIndex == _currentQuestion.correctIndex;

  void _select(int optionIndex) {
    if (_checked) return;
    setState(() => _selectedIndex = optionIndex);
  }

  void _check() {
    if (_selectedIndex == null || _checked) return;
    if (_isCorrect) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.heavyImpact();
    }
    setState(() {
      if (_isCorrect) _correctCount++;
      _checked = true;
    });
  }

  void _continue() {
    if (!_isLastQuestion) {
      setState(() {
        _currentIndex++;
        _selectedIndex = null;
        _checked = false;
      });
      return;
    }
    widget.onCompleted?.call(
      ExerciseOutcome(score: _correctCount * widget.pointsPerQuestion),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return const Center(child: Text('No hay preguntas disponibles'));
    }

    final answered = _currentIndex + (_checked ? 1 : 0);
    return Column(
      children: [
        Semantics(
          label: 'Pregunta ${_currentIndex + 1} de ${_questions.length}',
          child: LessonProgressBar(value: answered / _questions.length),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.15, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: SingleChildScrollView(
              key: ValueKey(_currentIndex),
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: _buildQuestionBody(),
            ),
          ),
        ),
        _buildBottomArea(),
      ],
    );
  }

  Widget _buildQuestionBody() {
    final question = _currentQuestion;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Elegí la respuesta correcta',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
            color: AppColors.darkBrownLight,
          ),
        ),
        const SizedBox(height: 10),
        VoxiSays(text: question.question),
        const SizedBox(height: 22),
        for (var i = 0; i < question.options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _OptionTile(
              letter: String.fromCharCode(65 + i),
              label: question.options[i],
              state: _optionState(i),
              onTap: () => _select(i),
            ),
          ),
      ],
    );
  }

  _OptionState _optionState(int i) {
    if (!_checked) {
      return _selectedIndex == i ? _OptionState.selected : _OptionState.idle;
    }
    if (i == _currentQuestion.correctIndex) return _OptionState.correct;
    if (i == _selectedIndex) return _OptionState.wrong;
    return _OptionState.idle;
  }

  Widget _buildBottomArea() {
    final question = _currentQuestion;
    final explanation = question.explanation ?? '';
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        transitionBuilder: (child, animation) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.4),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: _checked
            ? Semantics(
                key: const ValueKey('feedback'),
                liveRegion: true,
                label: _isCorrect ? 'Correcto' : 'Incorrecto',
                child: AnswerFeedbackPanel(
                  correct: _isCorrect,
                  title: _isCorrect ? '¡Excelente!' : 'Casi...',
                  detail: [
                    if (!_isCorrect)
                      'Respuesta correcta: '
                          '${question.options[question.correctIndex]}',
                    if (explanation.isNotEmpty) explanation,
                  ].join('\n'),
                  onContinue: _continue,
                ),
              )
            : ChunkyButton(
                key: const ValueKey('check'),
                label: 'COMPROBAR',
                colors: ChunkyColors.green,
                onPressed: _selectedIndex == null ? null : _check,
              ),
      ),
    );
  }
}

enum _OptionState { idle, selected, correct, wrong }

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.letter,
    required this.label,
    required this.state,
    required this.onTap,
  });

  final String letter;
  final String label;
  final _OptionState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = switch (state) {
      _OptionState.idle => ChunkyColors.white,
      _OptionState.selected => const ChunkyColors(
        face: AppColors.primaryContainer,
        lip: AppColors.primary,
        content: AppColors.onPrimaryContainer,
        border: AppColors.primary,
      ),
      _OptionState.correct => const ChunkyColors(
        face: AppColors.successContainer,
        lip: AppColors.success,
        content: AppColors.onSuccessContainer,
        border: AppColors.success,
      ),
      _OptionState.wrong => const ChunkyColors(
        face: AppColors.accentRedContainer,
        lip: AppColors.accentRed,
        content: AppColors.accentRedDark,
        border: AppColors.accentRed,
      ),
    };

    return ChunkyCard(
      colors: colors,
      radius: 16,
      depth: 4,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: onTap,
      semanticsLabel: '$letter. $label',
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: state == _OptionState.idle
                  ? AppColors.surfaceContainerHigh
                  : colors.lip,
            ),
            child: state == _OptionState.correct || state == _OptionState.wrong
                ? Icon(
                    state == _OptionState.correct
                        ? Icons.check_rounded
                        : Icons.close_rounded,
                    size: 20,
                    color: Colors.white,
                  )
                : Text(
                    letter,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: state == _OptionState.idle
                          ? AppColors.darkBrownLight
                          : Colors.white,
                    ),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colors.content,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
