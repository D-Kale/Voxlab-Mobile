import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../providers/weekly_progress_provider.dart';

const _dayLabels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
const _dayNames = [
  'lunes',
  'martes',
  'miércoles',
  'jueves',
  'viernes',
  'sábado',
  'domingo',
];

/// XP per day of the current week. Bars grow in on first show and today is
/// highlighted in red.
class WeeklyChart extends ConsumerWidget {
  const WeeklyChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(weeklyProgressProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Actividad semanal',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkBrown,
                ),
              ),
            ),
            Text(
              '${data.total} XP',
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: AppColors.accentRed,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          'XP ganada esta semana',
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.darkBrownLight,
          ),
        ),
        const SizedBox(height: 18),
        Stack(
          alignment: Alignment.center,
          children: [
            _ChartBars(daily: data.daily),
            if (data.total == 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Text(
                  'Sin XP esta semana todavía.\n¡Hacé un ejercicio hoy!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkBrownLight,
                    height: 1.4,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ChartBars extends StatelessWidget {
  const _ChartBars({required this.daily});

  final List<int> daily;

  static const double _maxBar = 96;

  @override
  Widget build(BuildContext context) {
    final maxValue = daily.fold(0, (a, b) => a > b ? a : b);
    final today = DateTime.now().weekday - 1;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutBack,
      builder: (context, t, _) => SizedBox(
        height: _maxBar + 66,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(7, (i) {
            final value = i < daily.length ? daily[i] : 0;
            final isToday = i == today;
            final full = maxValue > 0 ? value / maxValue * _maxBar : 0.0;
            final barHeight = (full * t).clamp(8.0, _maxBar + 8);
            final face = value == 0
                ? AppColors.idleFace
                : isToday
                ? AppColors.accentRed
                : AppColors.primary;
            final lip = value == 0
                ? AppColors.idleLip
                : isToday
                ? AppColors.accentRedDark
                : AppColors.primaryDark;

            return Expanded(
              child: Semantics(
                label: '${_dayNames[i]}: $value XP',
                excludeSemantics: true,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (value > 0)
                        Text(
                          '$value',
                          maxLines: 1,
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isToday
                                ? AppColors.accentRed
                                : AppColors.darkBrownLight,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Container(
                        height: barHeight,
                        decoration: BoxDecoration(
                          color: face,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(color: lip, offset: const Offset(0, 3)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 9),
                      Container(
                        width: 26,
                        height: 22,
                        alignment: Alignment.center,
                        decoration: isToday
                            ? BoxDecoration(
                                color: AppColors.accentRedContainer,
                                borderRadius: BorderRadius.circular(8),
                              )
                            : null,
                        child: Text(
                          _dayLabels[i],
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: isToday
                                ? FontWeight.w900
                                : FontWeight.w700,
                            color: isToday
                                ? AppColors.accentRed
                                : AppColors.darkBrownLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
