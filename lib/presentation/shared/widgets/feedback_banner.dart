import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

enum FeedbackStatus { success, error }

class FeedbackBanner extends StatelessWidget {
  const FeedbackBanner({
    super.key,
    required this.status,
    required this.title,
    this.subtitle,
    this.action,
  });

  final FeedbackStatus status;
  final String title;
  final String? subtitle;
  final Widget? action;

  Color get _backgroundColor =>
      status == FeedbackStatus.success ? AppColors.secondary : AppColors.error;

  IconData get _iconData =>
      status == FeedbackStatus.success ? Icons.check_circle : Icons.close;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Semantics(
                excludeSemantics: true,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.onPrimary.withValues(alpha: 0.24),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(_iconData, size: 22, color: AppColors.onPrimary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onPrimary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.onPrimary.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (action != null) ...[
                const SizedBox(width: 12),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
