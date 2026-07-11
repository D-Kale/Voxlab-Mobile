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
    if (_isSubmitted) {
      return _buildSummary();
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
          Text(
            widget.prompt,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          if (widget.requirements.isNotEmpty) ...[
            const Text(
              'Requisitos',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
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
                    style: const TextStyle(
                      fontSize: 13,
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
              hintStyle: const TextStyle(color: AppColors.onSurfaceVariant),
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
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.onSurface,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '$_wordCount / ${widget.maxWords} palabras',
                style: TextStyle(
                  fontSize: 13,
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
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.error,
                  ),
                )
              else if (_wordCount < widget.minWords)
                Text(
                  ' (mín: ${widget.minWords})',
                  style: const TextStyle(
                    fontSize: 13,
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

  Widget _buildSummary() {
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
            const Text(
              '¡Texto enviado!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${_wordCount} palabras · +${widget.points} XP',
              style: const TextStyle(
                fontSize: 18,
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
