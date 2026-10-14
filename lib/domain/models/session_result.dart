import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'speech_metrics.dart';

/// Session result consumed by the results screen.
///
/// The backend scoring endpoint `POST /exercises/analyze-text` returns the
/// AI analysis for writing exercises: `{success, message, data}` where
/// `data` follows `analyzer.AnalyzeResponse` (score 0-100, a
/// `score_breakdown` map keyed by Spanish component names, and a general
/// `feedback` string list). [SessionResult.fromJson] parses that envelope.
///
/// Oratory uses `POST /exercises/analyze-speech` with the same envelope.
/// When the AI is unreachable, writing and oratory fall back to on-device
/// analysis ([SessionResultBuilder.fromWriting] / `fromSpeech`); quiz and
/// reading use [SessionResultBuilder.fromScore]. The results screen must
/// not care which path produced the value.
class SessionSkill {
  const SessionSkill({
    required this.key,
    required this.label,
    required this.icon,
    required this.percent,
  });

  final String key;
  final String label;
  final IconData icon;
  final int percent;

  static const _catalog = {
    'cobertura_requisitos': (
      label: 'Cobertura de requisitos',
      icon: Icons.checklist,
    ),
    'estructura': (label: 'Estructura', icon: Icons.account_tree_outlined),
    'calidad_linguistica': (
      label: 'Calidad lingüística',
      icon: Icons.spellcheck_outlined,
    ),
    'longitud': (label: 'Longitud', icon: Icons.straighten_outlined),
    'duracion': (label: 'Duración', icon: Icons.timer_outlined),
    'pausas': (label: 'Pausas', icon: Icons.pause_circle_outline),
    'fluidez': (label: 'Fluidez', icon: Icons.graphic_eq),
    'muletillas': (label: 'Muletillas', icon: Icons.record_voice_over_outlined),
    'ritmo': (label: 'Ritmo', icon: Icons.speed),
  };

  factory SessionSkill.fromBreakdown(String key, int percent) {
    final known = _catalog[key];
    return SessionSkill(
      key: key,
      label: known?.label ?? _prettify(key),
      icon: known?.icon ?? Icons.analytics_outlined,
      percent: percent,
    );
  }

  static String _prettify(String key) {
    final words = key.replaceAll('_', ' ').split(' ');
    return words
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}

class SessionTip {
  const SessionTip({required this.text, required this.isPositive});

  final String text;
  final bool isPositive;
}

class SessionResult {
  const SessionResult({
    required this.overall,
    required this.level,
    required this.skills,
    required this.tips,
    this.readabilityLabel,
    this.fillerWords,
    this.aiFeedback,
    this.byAi = false,
  });

  final int overall;
  final String level;
  final List<SessionSkill> skills;
  final List<SessionTip> tips;
  final String? readabilityLabel;
  final int? fillerWords;

  /// The LLM coach's tip about the content, when the backend used it.
  final String? aiFeedback;

  /// True when the backend analyzer produced this result.
  final bool byAi;

  factory SessionResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final overall = (data['score'] as num?)?.toInt() ?? 0;

    final breakdown =
        (data['score_breakdown'] as Map?)?.cast<String, dynamic>() ?? {};
    final skills =
        breakdown.entries
            .map(
              (e) => SessionSkill.fromBreakdown(
                e.key,
                (e.value['score'] as num?)?.toInt() ?? 0,
              ),
            )
            .toList()
          ..sort((a, b) => b.percent.compareTo(a.percent));

    final aiFeedback = (data['ai_feedback'] as String?)?.trim();
    final tips = <SessionTip>[
      for (final text in data['feedback'] as List<dynamic>? ?? [])
        // The coach tip is also prepended to `feedback`; it is shown apart.
        if (text is String && text.isNotEmpty && text != aiFeedback)
          SessionTip(text: text, isPositive: true),
    ];

    final weakest = skills.isEmpty ? null : skills.last;
    for (final feedback in _weakestFeedbacks(breakdown, weakest?.key)) {
      tips.add(SessionTip(text: feedback, isPositive: false));
    }

    final readability = data['readability'] as Map<String, dynamic>?;

    return SessionResult(
      overall: overall,
      level: SessionResultBuilder.levelFor(overall),
      skills: skills,
      tips: tips,
      readabilityLabel: readability?['label'] as String?,
      fillerWords: (data['filler_words'] as num?)?.toInt(),
      aiFeedback: aiFeedback == null || aiFeedback.isEmpty ? null : aiFeedback,
      byAi: true,
    );
  }

  static List<String> _weakestFeedbacks(
    Map<String, dynamic> breakdown,
    String? weakestKey,
  ) {
    if (weakestKey == null) return const [];
    final item = breakdown[weakestKey];
    if (item is! Map<String, dynamic>) return const [];
    return (item['feedbacks'] as List<dynamic>? ?? [])
        .whereType<String>()
        .where((f) => f.isNotEmpty)
        .toList();
  }
}

class SessionResultBuilder {
  SessionResultBuilder._();

  static const _skillNames = [
    'Dicción',
    'Postura',
    'Confianza',
    'Contacto Visual',
  ];

  static const _skillOffsets = [2, -15, 5, -25];

  static const _skillIcons = [
    Icons.record_voice_over_outlined,
    Icons.accessibility_new_outlined,
    Icons.psychology_outlined,
    Icons.visibility_outlined,
  ];

  static const _tipsBySkill = {
    'Dicción':
        'Articulá cada palabra con pausas breves '
        'entre frases para ganar claridad.',
    'Postura':
        'Probá apoyar el peso en ambos pies: '
        'transmite estabilidad ante la audiencia.',
    'Confianza':
        'Arrancá con una frase que domines perfecto; '
        'un buen inicio empuja todo el resto.',
    'Contacto Visual':
        'Elegí tres puntos de la sala y rotá la mirada '
        'entre ellos mientras hablás.',
  };

  static String levelFor(int score) {
    if (score >= 90) return 'Comunicador excelente';
    if (score >= 75) return 'Comunicador confiable';
    if (score >= 50) return 'Comunicador en progreso';
    return 'Comunicador en formación';
  }

  static SessionResult fromScore(int score) {
    final overall = score.clamp(0, 100);
    final skills = <SessionSkill>[];
    for (var i = 0; i < _skillNames.length; i++) {
      skills.add(
        SessionSkill(
          key: _skillNames[i],
          label: _skillNames[i],
          icon: _skillIcons[i],
          percent: (overall + _skillOffsets[i]).clamp(5, 99),
        ),
      );
    }

    final weakest = skills.reduce((a, b) => a.percent <= b.percent ? a : b);

    return SessionResult(
      overall: overall,
      level: levelFor(overall),
      skills: skills,
      tips: [
        const SessionTip(
          text:
              'Buen trabajo: mantuviste la constancia '
              'y terminaste la sesión completa.',
          isPositive: true,
        ),
        SessionTip(text: _tipsBySkill[weakest.key]!, isPositive: false),
      ],
    );
  }

  /// Scores a writing exercise on the device when the AI is unreachable:
  /// length against the limits, requirement keywords found in the text,
  /// and paragraph/sentence structure. Rougher than the backend analyzer,
  /// but based on the actual text.
  static SessionResult fromWriting(
    String text, {
    required List<String> requirements,
    required int minWords,
    required int maxWords,
  }) {
    final words = text.trim().isEmpty
        ? 0
        : text.trim().split(RegExp(r'\s+')).length;
    final longitud = words < minWords
        ? (words / math.max(minWords, 1) * 70).round()
        : words > maxWords
        ? 80
        : 100;

    final lower = _fold(text);
    final missing = <String>[];
    var covered = 0;
    for (final r in requirements) {
      // Crude stemming: the first 5 letters of each meaningful word, so
      // "respiración" matches "respirar".
      final stems = _fold(r)
          .split(RegExp(r'[^a-zñ0-9]+'))
          .where((w) => w.length > 3)
          .map((w) => w.substring(0, math.min(5, w.length)))
          .toList();
      final hit = stems.isEmpty || stems.any(lower.contains);
      hit ? covered++ : missing.add(r);
    }

    final paragraphs = text
        .split(RegExp(r'\n\s*\n'))
        .where((p) => p.trim().isNotEmpty)
        .length;
    final sentences = RegExp(r'[.!?]+').allMatches(text).length;
    final estructura = math.min(
      100,
      (paragraphs >= 3 ? 50 : paragraphs * 17) + math.min(sentences, 5) * 10,
    );

    final breakdown = <String, int>{
      'longitud': longitud,
      if (requirements.isNotEmpty)
        'cobertura_requisitos': (covered / requirements.length * 100).round(),
      'estructura': estructura,
    }.map((k, v) => MapEntry(k, v.clamp(0, 100)));

    final skills = [
      for (final e in breakdown.entries)
        SessionSkill.fromBreakdown(e.key, e.value),
    ]..sort((a, b) => b.percent.compareTo(a.percent));
    final overall =
        (breakdown.values.reduce((a, b) => a + b) / breakdown.length).round();

    return SessionResult(
      overall: overall,
      level: levelFor(overall),
      skills: skills,
      tips: [
        SessionTip(
          text: 'Escribiste $words palabras y completaste el ejercicio.',
          isPositive: true,
        ),
        if (missing.isNotEmpty)
          SessionTip(
            text:
                'No encontramos en tu texto: "${missing.first}". Sumalo '
                'la próxima vez.',
            isPositive: false,
          )
        else if (paragraphs < 3)
          const SessionTip(
            text:
                'Organizá tu texto en introducción, desarrollo y cierre, '
                'separados en párrafos.',
            isPositive: false,
          ),
      ],
    );
  }

  /// Lowercase without Spanish accents, for keyword matching.
  static String _fold(String s) => s
      .toLowerCase()
      .replaceAll(RegExp('[áà]'), 'a')
      .replaceAll(RegExp('[éè]'), 'e')
      .replaceAll(RegExp('[íì]'), 'i')
      .replaceAll(RegExp('[óò]'), 'o')
      .replaceAll(RegExp('[úùü]'), 'u');

  /// Scores a recorded take from its delivery metrics (on-device timing,
  /// plus filler words and pace when the speech AI provided them).
  /// Offline fallback of POST /exercises/analyze-speech.
  static SessionResult fromSpeech(
    SpeechMetrics m, {
    required int targetSeconds,
    required int minSeconds,
  }) {
    if (!m.hasSpeech) {
      return SessionResult(
        overall: 0,
        level: levelFor(0),
        skills: [
          SessionSkill.fromBreakdown('fluidez', 0),
          SessionSkill.fromBreakdown('pausas', 0),
          SessionSkill.fromBreakdown('duracion', 0),
        ],
        tips: const [
          SessionTip(
            text:
                'No detectamos tu voz. Acercate al micrófono y hablá con '
                'un volumen claro.',
            isPositive: false,
          ),
        ],
      );
    }

    final seconds = m.duration.inMilliseconds / 1000;
    final duration = seconds < minSeconds
        ? (seconds / minSeconds * 70).round()
        : 100;

    final ratio = m.speakingRatio;
    final fluency = ratio >= 0.65 && ratio <= 0.92
        ? 100
        : ratio < 0.65
        ? (ratio / 0.65 * 100).round()
        : 85;

    final ppm = m.pausesPerMinute;
    var pauses = ppm >= 3 && ppm <= 10
        ? 100
        : ppm < 3
        ? (60 + ppm / 3 * 40).round()
        : math.max(40, (100 - (ppm - 10) * 8).round());
    if (m.longestPause > const Duration(seconds: 4)) pauses -= 15;

    final breakdown = <String, int>{
      'duracion': duration,
      'fluidez': fluency,
      'pausas': pauses,
      if (m.fillerWords != null)
        'muletillas': (100 - m.fillerWords! / math.max(seconds / 60, 0.5) * 15)
            .round(),
      if (m.wordsPerMinute != null)
        'ritmo': m.wordsPerMinute! >= 110 && m.wordsPerMinute! <= 160
            ? 100
            : (100 - ((m.wordsPerMinute! - 135).abs() - 25) * 1.5).round(),
    }.map((k, v) => MapEntry(k, v.clamp(0, 100)));

    final skills = [
      for (final e in breakdown.entries)
        SessionSkill.fromBreakdown(e.key, e.value),
    ]..sort((a, b) => b.percent.compareTo(a.percent));
    final overall =
        (breakdown.values.reduce((a, b) => a + b) / breakdown.length).round();

    return SessionResult(
      overall: overall,
      level: levelFor(overall),
      skills: skills,
      tips: [
        SessionTip(text: _speechPraise(skills.first.key, m), isPositive: true),
        if (skills.last.percent < 100)
          SessionTip(
            text: _speechAdvice(skills.last.key, m),
            isPositive: false,
          ),
      ],
      fillerWords: m.fillerWords,
    );
  }

  static String _speechPraise(String key, SpeechMetrics m) => switch (key) {
    'pausas' =>
      'Buen manejo de las pausas: hiciste ${m.pauseCount} y le '
          'diste aire a tus ideas.',
    'fluidez' =>
      'Hablaste con fluidez el '
          '${(m.speakingRatio * 100).round()} % del tiempo.',
    'duracion' => 'Sostuviste tu discurso el tiempo necesario.',
    'muletillas' => 'Casi sin muletillas: tu mensaje se escuchó limpio.',
    _ => 'Buen ritmo: ni muy rápido ni muy lento.',
  };

  static String _speechAdvice(String key, SpeechMetrics m) => switch (key) {
    'pausas' when m.pausesPerMinute < 3 =>
      'Hacé una pausa breve después de cada idea importante; ayuda a que tu '
          'audiencia la procese.',
    'pausas' =>
      'Hiciste muchas pausas o muy largas '
          '(la más larga duró ${m.longestPause.inSeconds} s). Prepará la '
          'siguiente idea antes de soltar la anterior.',
    'fluidez' =>
      'Hablaste solo el ${(m.speakingRatio * 100).round()} % del tiempo. '
          'Intentá sostener la voz con frases completas.',
    'duracion' => 'Tu toma fue corta: intentá llegar al tiempo mínimo.',
    'muletillas' =>
      'Detectamos ${m.fillerWords} muletillas. Reemplazalas por un silencio '
          'breve.',
    _ => 'Ajustá el ritmo: apuntá a unas 120-150 palabras por minuto.',
  };
}
