import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class WritingWidget extends StatefulWidget {
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
  final void Function(int score)? onCompleted;

  @override
  State<WritingWidget> createState() => _WritingWidgetState();
}

class _WritingWidgetState extends State<WritingWidget> {
  final _controller = TextEditingController();
  int _wordCount = 0;
  bool _isSubmitted = false;

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

  void _submit() {
    if (!_canSubmit) return;
    setState(() => _isSubmitted = true);
    widget.onCompleted?.call(widget.points);
  }

  @override
  void dispose() {
    _controller.removeListener(_updateWordCount);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_isSubmitted) {
      return _buildSummary(theme);
    }

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
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            widget.prompt,
            style: theme.textTheme.titleLarge?.copyWith(height: 1.3),
          ),
          const SizedBox(height: 16),
          if (widget.requirements.isNotEmpty) ...[
            Text(
              'Requisitos',
              style: theme.textTheme.titleSmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.requirements.map(
                (r) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    r,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ).toList(),
            ),
            const SizedBox(height: 24),
          ],
          TextField(
            controller: _controller,
            maxLines: null,
            minLines: 8,
            decoration: InputDecoration(
              hintText: 'Escribí tu texto aquí...',
              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              filled: true,
              fillColor: AppColors.surfaceContainer,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '$_wordCount / ${widget.maxWords} palabras',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: _wordCount > widget.maxWords
                      ? AppColors.error
                      : _wordCount >= widget.minWords
                          ? AppColors.success
                          : AppColors.onSurfaceVariant,
                ),
              ),
              if (_wordCount > widget.maxWords)
                Text(
                  ' (mín: ${widget.minWords})',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.error,
                  ),
                )
              else if (_wordCount < widget.minWords)
                Text(
                  ' (mín: ${widget.minWords})',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSubmit ? _submit : null,
              child: const Text('Completar'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(ThemeData theme) {
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
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.edit_note,
                  size: 40,
                  color: AppColors.success,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '¡Texto enviado!',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              '${_wordCount} palabras · +${widget.points} XP',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.onSurfaceVariant,
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
