import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/audio/sound_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/routes.dart';
import '../../../data/local/onboarding_store.dart';
import '../../shared/widgets/chunky.dart';
import '../../shared/widgets/lesson_widgets.dart';
import '../../shared/widgets/motion.dart';

class _Option<T> {
  const _Option(this.value, this.label, this.icon, {this.detail});

  final T value;
  final String label;
  final IconData icon;
  final String? detail;
}

const _motivations = [
  _Option('work', 'Crecer en mi trabajo', Icons.work_rounded),
  _Option('study', 'Mis estudios', Icons.school_rounded),
  _Option('confidence', 'Ganar confianza', Icons.favorite_rounded),
  _Option('presentations', 'Dar mejores presentaciones', Icons.co_present),
  _Option('interviews', 'Prepararme para entrevistas', Icons.handshake),
];

const _levels = [
  _Option(
    'nervous',
    'Me pongo muy nervioso',
    Icons.sentiment_very_dissatisfied_rounded,
  ),
  _Option(
    'basic',
    'Me defiendo, pero quiero mejorar',
    Icons.sentiment_neutral_rounded,
  ),
  _Option('comfortable', 'Me siento cómodo', Icons.sentiment_satisfied_rounded),
  _Option('expert', 'Ya tengo experiencia', Icons.emoji_events_rounded),
];

const _goals = [
  _Option(10, 'Casual', Icons.local_cafe_rounded, detail: '10 XP por día'),
  _Option(20, 'Normal', Icons.directions_walk_rounded, detail: '20 XP por día'),
  _Option(30, 'Serio', Icons.directions_run_rounded, detail: '30 XP por día'),
  _Option(
    50,
    'Intenso',
    Icons.local_fire_department_rounded,
    detail: '50 XP por día',
  ),
];

/// Duolingo-style first-run questions (why, how confident, daily goal),
/// a short "building your plan" moment, then the register screen.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _stepCount = 4;

  int _step = 0;
  bool _forward = true;
  String? _motivation;
  String? _level;
  int? _goal;
  bool _planReady = false;

  bool get _canContinue => switch (_step) {
    0 => _motivation != null,
    1 => _level != null,
    2 => _goal != null,
    _ => _planReady,
  };

  void _back() {
    if (_step == 0) {
      context.pop();
      return;
    }
    setState(() {
      _forward = false;
      _step--;
      _planReady = false;
    });
  }

  Future<void> _continue() async {
    if (!_canContinue) return;
    if (_step < _stepCount - 1) {
      setState(() {
        _forward = true;
        _step++;
      });
      return;
    }
    final store = ref.read(onboardingStoreProvider);
    await store.saveProfile(
      OnboardingProfile(
        motivation: _motivation!,
        level: _level!,
        dailyGoalXp: _goal!,
      ),
    );
    await store.markOnboardingSeen();
    ref.invalidate(onboardingProfileProvider);
    if (!mounted) return;
    context.push(AppRoutes.register, extra: {'fromOnboarding': true});
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        backgroundColor: lessonBackground,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 16, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Atrás',
                      onPressed: _back,
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.darkBrownLight,
                        size: 28,
                      ),
                    ),
                    Expanded(
                      child: Semantics(
                        label: 'Paso ${_step + 1} de $_stepCount',
                        child: LessonProgressBar(
                          value: (_step + 1) / _stepCount,
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 320),
                      layoutBuilder: (current, previous) => Stack(
                        alignment: Alignment.topCenter,
                        children: [...previous, ?current],
                      ),
                      transitionBuilder: (child, animation) {
                        final incoming = child.key == ValueKey(_step);
                        final dx = (incoming == _forward) ? 0.25 : -0.25;
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position:
                                Tween<Offset>(
                                  begin: Offset(dx, 0),
                                  end: Offset.zero,
                                ).animate(
                                  CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutCubic,
                                  ),
                                ),
                            child: child,
                          ),
                        );
                      },
                      child: KeyedSubtree(
                        key: ValueKey(_step),
                        child: _buildStep(),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 8),
                  child: ChunkyButton(
                    label: _step == _stepCount - 1
                        ? 'CREAR MI PERFIL'
                        : 'CONTINUAR',
                    colors: ChunkyColors.green,
                    onPressed: _canContinue ? _continue : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    return switch (_step) {
      0 => _QuestionStep<String>(
        question: '¿Para qué querés mejorar tu oratoria?',
        options: _motivations,
        selected: _motivation,
        onSelect: (v) => setState(() => _motivation = v),
      ),
      1 => _QuestionStep<String>(
        question: '¿Cómo te sentís al hablar en público?',
        options: _levels,
        selected: _level,
        onSelect: (v) => setState(() => _level = v),
      ),
      2 => _QuestionStep<int>(
        question: 'Elegí tu meta diaria. Podés cambiarla cuando quieras.',
        options: _goals,
        selected: _goal,
        onSelect: (v) => setState(() => _goal = v),
      ),
      _ => _PlanStep(
        goalXp: _goal ?? OnboardingProfile.defaultDailyGoalXp,
        motivation: _motivations
            .firstWhere(
              (o) => o.value == _motivation,
              orElse: () => _motivations.first,
            )
            .label,
        onReady: () {
          if (mounted) setState(() => _planReady = true);
        },
      ),
    };
  }
}

class _QuestionStep<T> extends StatelessWidget {
  const _QuestionStep({
    required this.question,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  final String question;
  final List<_Option<T>> options;
  final T? selected;
  final ValueChanged<T> onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          VoxiSays(text: question),
          const SizedBox(height: 20),
          for (var i = 0; i < options.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: EntranceAnimation(
                delay: EntranceAnimation.stagger(i, stepMs: 50),
                child: _OptionCard(
                  label: options[i].label,
                  detail: options[i].detail,
                  icon: options[i].icon,
                  selected: options[i].value == selected,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    playSfx(context, Sfx.tap);
                    onSelect(options[i].value);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.detail,
  });

  final String label;
  final String? detail;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  static const _selectedColors = ChunkyColors(
    face: AppColors.primaryContainer,
    lip: AppColors.primary,
    content: AppColors.onPrimaryContainer,
    border: AppColors.primary,
  );

  @override
  Widget build(BuildContext context) {
    final colors = selected ? _selectedColors : ChunkyColors.white;
    return ChunkyCard(
      colors: colors,
      radius: 16,
      depth: 4,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      onTap: onTap,
      semanticsLabel: detail == null ? label : '$label, $detail',
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : AppColors.idleFace,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 22,
              color: selected ? Colors.white : AppColors.darkBrownLight,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: colors.content,
              ),
            ),
          ),
          if (detail != null)
            Text(
              detail!,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.darkBrownLight,
              ),
            ),
        ],
      ),
    );
  }
}

/// "Building your plan": a progress bar fills while the plan items pop in,
/// then Voxi announces the plan is ready.
class _PlanStep extends StatefulWidget {
  const _PlanStep({
    required this.goalXp,
    required this.motivation,
    required this.onReady,
  });

  final int goalXp;
  final String motivation;
  final VoidCallback onReady;

  @override
  State<_PlanStep> createState() => _PlanStepState();
}

class _PlanStepState extends State<_PlanStep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((status) {
      if (status != AnimationStatus.completed) return;
      // May fire while building (reduced motion jumps straight to the end),
      // so report after the frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onReady();
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (reduceMotion(context)) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.bolt_rounded, 'Meta diaria: ${widget.goalXp} XP'),
      (Icons.flag_rounded, 'Enfoque: ${widget.motivation}'),
      (Icons.route_rounded, 'Arrancás por la Unidad 1'),
    ];
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final done = t >= 1;
        return SingleChildScrollView(
          padding: const EdgeInsets.only(top: 18, bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              VoxiSays(
                text: done
                    ? '¡Tu plan está listo! Creá tu perfil para guardarlo.'
                    : 'Armando tu plan...',
              ),
              const SizedBox(height: 24),
              LessonProgressBar(value: t, color: AppColors.primary),
              const SizedBox(height: 20),
              for (var i = 0; i < items.length; i++)
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity: t >= (i + 1) / (items.length + 1) ? 1 : 0,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ChunkyCard(
                      depth: 4,
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              items[i].$1,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              items[i].$2,
                              style: GoogleFonts.dmSans(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkBrown,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.check_rounded,
                            color: AppColors.success,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
