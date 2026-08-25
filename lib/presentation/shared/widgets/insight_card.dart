import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class InsightItem {
  const InsightItem({
    required this.icon,
    required this.text,
    this.highlight = false,
  });

  final IconData icon;
  final String text;
  final bool highlight;
}

class InsightCard extends StatelessWidget {
  const InsightCard({super.key, required this.title, required this.items});

  final String title;
  final List<InsightItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Semantics(
                excludeSemantics: true,
                child: const Icon(
                  Icons.lightbulb,
                  size: 22,
                  color: AppColors.onPrimary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            _itemRow(items[i]),
          ],
        ],
      ),
    );
  }

  Widget _itemRow(InsightItem item) {
    final iconColor =
        item.highlight ? AppColors.tertiaryContainer : AppColors.onPrimary;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          excludeSemantics: true,
          child: Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: AppColors.onPrimary.withValues(alpha: 0.24),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(item.icon, size: 15, color: iconColor),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            item.text,
            style: item.highlight
                ? const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onPrimary,
                    height: 1.4,
                  )
                : TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.onPrimary.withValues(alpha: 0.9),
                    height: 1.4,
                  ),
          ),
        ),
      ],
    );
  }
}
