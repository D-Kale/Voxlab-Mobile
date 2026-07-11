import 'package:flutter/material.dart';
import '../../../shared/widgets/xp_bar.dart';
import '../../../shared/widgets/section_header.dart';

class XpSection extends StatelessWidget {
  const XpSection({super.key, required this.xp});

  final int xp;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'Experiencia'),
            const SizedBox(height: 12),
            XpBar(xp: xp),
          ],
        ),
      ),
    );
  }
}
