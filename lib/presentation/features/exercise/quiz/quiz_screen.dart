import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../domain/models/exercise_content.dart';

class QuizWidget extends StatefulWidget {
  const QuizWidget({
    super.key,
    required this.questions,
    required this.pointsPerQuestion,
    this.onCompleted,
  });

  final List<QuizQuestion> questions;
  final int pointsPerQuestion;
  final void Function(int score)? onCompleted;

  @override
  State<QuizWidget> createState() => _QuizWidgetState();
}

class _QuizWidgetState extends State<QuizWidget> {
  static const _accentIcon = Icons.waving_hand;

  int _currentIndex = 0;
  int? _selectedIndex;
  bool _checked = false;
  int _correctCount = 0;

  List<QuizQuestion> get _questions => widget.questions;

  QuizQuestion get _currentQuestion => _questions[_currentIndex];

  bool get _isLastQuestion => _currentIndex == _questions.length - 1;

  bool get _isCorrect =>
      _selectedIndex == _currentQuestion.correctIndex;

  void _select(int optionIndex) {
    if (_checked) return;
    setState(() => _selectedIndex = optionIndex);
  }

  void _check() {
    if (_selectedIndex == null || _checked) return;
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
    widget.onCompleted?.call(_correctCount * widget.pointsPerQuestion);
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return const Center(child: Text('No hay preguntas disponibles'));
    }

    return Column(
      children: [
        Expanded(child: _buildContent()),
        _buildBottomArea(),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Semantics(
            label: 'Pregunta ${_currentIndex + 1} de ${_questions.length}',
            child: LinearProgressIndicator(
              value: (_currentIndex + 1) / _questions.length,
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
              backgroundColor: AppColors.surfaceContainerHigh,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.12, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: SingleChildScrollView(
              key: ValueKey(_currentIndex),
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: _buildQuestionBody(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionBody() {
    final question = _currentQuestion;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          question.question,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            height: 1.35,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Semantics(
            excludeSemantics: true,
            child: Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryContainer,
              ),
              child: const Icon(
                _accentIcon,
                size: 34,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        ..._buildOptions(),
      ],
    );
  }

  List<Widget> _buildOptions() {
    final options = _currentQuestion.options;
    return [
      for (var i = 0; i < options.length; i++) ...[
        _OptionTile(
          letter: String.fromCharCode(65 + i),
          label: options[i],
          isSelected: _selectedIndex == i,
          onTap: () => _select(i),
        ),
        if (i < options.length - 1) const SizedBox(height: 12),
      ],
    ];
  }

  Widget _buildBottomArea() {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.35),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
        child: _checked
            ? _buildFeedback()
            : _buildCheckRow(),
      ),
    );
  }

  Widget _buildCheckRow() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.surfaceContainerHigh,
          child: Icon(Icons.face, color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
            onPressed: _selectedIndex == null ? null : _check,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            child: const Text(
              'COMPROBAR',
              style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeedback() {
    final correct = _isCorrect;
    final question = _currentQuestion;
    final explanation = question.explanation ?? '';

    return Semantics(
      label: correct ? 'Correcto' : 'Incorrecto',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: correct ? AppColors.secondary : AppColors.error,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  excludeSemantics: true,
                  child: Icon(
                    correct ? Icons.check_circle : Icons.cancel,
                    color: AppColors.onPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        correct ? '¡Excelente!' : 'Casi...',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.onPrimary,
                        ),
                      ),
                      if (!correct)
                        Text(
                          'Respuesta correcta: '
                          '${question.options[question.correctIndex]}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.onPrimary,
                          ),
                        ),
                      if (explanation.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          explanation,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.onPrimary.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _continue,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.onSurface,
              minimumSize: const Size.fromHeight(52),
            ),
            child: const Text(
              'CONTINUAR',
              style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.letter,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String letter;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outline,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            _LetterBadge(letter: letter, selected: isSelected),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LetterBadge extends StatelessWidget {
  const _LetterBadge({required this.letter, required this.selected});

  final String letter;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppColors.primary : AppColors.surfaceContainerHigh,
      ),
      child: Text(
        letter,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: selected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}
