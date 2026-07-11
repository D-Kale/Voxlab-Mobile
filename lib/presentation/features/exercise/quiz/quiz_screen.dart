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
  final Map<int, int> _selectedAnswers = {};
  bool _isSubmitted = false;
  int _score = 0;

  List<QuizQuestion> get _questions => widget.questions;

  bool get _allAnswered =>
      _questions.length == _selectedAnswers.length;

  int get _correctCount =>
      _questions.indexed.where(
        (e) => _selectedAnswers[e.$1] == e.$2.correctIndex,
      ).length;

  int get _totalScore => _correctCount * widget.pointsPerQuestion;

  void _submit() {
    if (!_allAnswered) return;
    setState(() {
      _isSubmitted = true;
      _score = _totalScore;
    });
  }

  void _continue() {
    widget.onCompleted?.call(_score);
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return const Center(child: Text('No hay preguntas disponibles'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_isSubmitted) _buildQuestionList() else _buildReview(),
        ],
      ),
    );
  }

  Widget _buildQuestionList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.quiz, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              '${_selectedAnswers.length} de ${_questions.length} respondidas',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: _selectedAnswers.length / _questions.length,
          backgroundColor: AppColors.surfaceContainerHigh,
          valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          minHeight: 6,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 24),
        ..._questions.asMap().entries.map(
          (entry) => _QuestionCard(
            index: entry.key,
            question: entry.value,
            selectedIndex: _selectedAnswers[entry.key],
            onSelect: (optionIndex) {
              setState(() => _selectedAnswers[entry.key] = optionIndex);
            },
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _allAnswered ? _submit : null,
            child: Text(
              _allAnswered
                  ? 'Enviar respuestas'
                  : 'Respondé todas las preguntas (${_questions.length - _selectedAnswers.length} restantes)',
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildReview() {
    final percentage = (_correctCount / _questions.length * 100).round();

    return Column(
      children: [
        Semantics(
          label: 'Quiz completado: $_correctCount de ${_questions.length} correctas',
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: (percentage >= 70 ? AppColors.success : AppColors.primary)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Semantics(
                  excludeSemantics: true,
                  child: Icon(
                    percentage >= 70 ? Icons.emoji_events : Icons.trending_up,
                    size: 56,
                    color: percentage >= 70 ? AppColors.secondary : AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '$_correctCount de ${_questions.length} correctas',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$percentage% · +$_totalScore XP',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        ..._questions.asMap().entries.map(
          (entry) => _ReviewQuestionCard(
            index: entry.key,
            question: entry.value,
            selectedIndex: _selectedAnswers[entry.key],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _continue,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: AppColors.onSurface,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Continuar'),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.index,
    required this.question,
    required this.selectedIndex,
    required this.onSelect,
  });

  final int index;
  final QuizQuestion question;
  final int? selectedIndex;
  final void Function(int) onSelect;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question.question,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...question.options.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _RadioOption(
                  text: entry.value,
                  index: entry.key,
                  isSelected: selectedIndex == entry.key,
                  onTap: () => onSelect(entry.key),
                  letter: String.fromCharCode(65 + entry.key),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RadioOption extends StatelessWidget {
  const _RadioOption({
    required this.text,
    required this.index,
    required this.isSelected,
    required this.onTap,
    required this.letter,
  });

  final String text;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;
  final String letter;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.surfaceContainerHigh,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  color: isSelected ? AppColors.primary : AppColors.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewQuestionCard extends StatelessWidget {
  const _ReviewQuestionCard({
    required this.index,
    required this.question,
    required this.selectedIndex,
  });

  final int index;
  final QuizQuestion question;
  final int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    final isCorrect = selectedIndex == question.correctIndex;
    final color = isCorrect ? AppColors.success : AppColors.error;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Semantics(
                  excludeSemantics: true,
                  child: Icon(
                    isCorrect ? Icons.check_circle : Icons.cancel,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    question.question,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...question.options.asMap().entries.map(
              (entry) => _ReviewOptionRow(
                text: entry.value,
                index: entry.key,
                isSelected: selectedIndex == entry.key,
                isCorrect: entry.key == question.correctIndex,
                letter: String.fromCharCode(65 + entry.key),
              ),
            ),
            if (question.explanation != null &&
                question.explanation!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      excludeSemantics: true,
                      child: Icon(
                        Icons.lightbulb_outline,
                        size: 16,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        question.explanation!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReviewOptionRow extends StatelessWidget {
  const _ReviewOptionRow({
    required this.text,
    required this.index,
    required this.isSelected,
    required this.isCorrect,
    required this.letter,
  });

  final String text;
  final int index;
  final bool isSelected;
  final bool isCorrect;
  final String letter;

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color borderColor;
    Color textColor;

    if (isCorrect && isSelected) {
      bgColor = AppColors.success.withValues(alpha: 0.1);
      borderColor = AppColors.success;
      textColor = AppColors.success;
    } else if (isCorrect) {
      bgColor = AppColors.success.withValues(alpha: 0.05);
      borderColor = AppColors.success.withValues(alpha: 0.5);
      textColor = AppColors.success;
    } else if (isSelected) {
      bgColor = AppColors.error.withValues(alpha: 0.1);
      borderColor = AppColors.error;
      textColor = AppColors.error;
    } else {
      bgColor = AppColors.surfaceContainer;
      borderColor = AppColors.surfaceContainerHigh;
      textColor = AppColors.onSurface;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: (isCorrect || isSelected) ? borderColor : AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  letter,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: (isCorrect || isSelected)
                        ? AppColors.onSurface
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  color: textColor,
                ),
              ),
            ),
            if (isCorrect && isSelected)
              const Icon(Icons.check_circle, size: 18, color: AppColors.success),
            if (isSelected && !isCorrect)
              const Icon(Icons.cancel, size: 18, color: AppColors.error),
          ],
        ),
      ),
    );
  }
}
