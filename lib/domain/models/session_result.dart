import 'package:flutter/material.dart';

/// Session result consumed by the results screen.
///
/// The backend scoring endpoint `POST /exercises/analyze-text` returns the
/// AI analysis for writing exercises: `{success, message, data}` where
/// `data` follows `analyzer.AnalyzeResponse` (score 0-100, a
/// `score_breakdown` map keyed by Spanish component names, and a general
/// `feedback` string list). [SessionResult.fromJson] parses that envelope.
///
/// Quiz, reading and oratory have no AI endpoint yet, so they fall back to
/// [SessionResultBuilder.fromScore]. The results screen must not care which
/// path produced the value.
///
/// TODO(backend): no AI analysis endpoint exists for oratory (audio),
/// quiz or reading exercises — only analyze-text for writing. When those
/// land, map them through SessionResult.fromJson as well.
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
  });

  final int overall;
  final String level;
  final List<SessionSkill> skills;
  final List<SessionTip> tips;
  final String? readabilityLabel;
  final int? fillerWords;

  factory SessionResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final overall = (data['score'] as num?)?.toInt() ?? 0;

    final breakdown =
        data['score_breakdown'] as Map<String, dynamic>? ?? {};
    final skills = breakdown.entries
        .map(
          (e) => SessionSkill.fromBreakdown(
            e.key,
            (e.value['score'] as num?)?.toInt() ?? 0,
          ),
        )
        .toList()
      ..sort((a, b) => b.percent.compareTo(a.percent));

    final tips = <SessionTip>[
      for (final text in data['feedback'] as List<dynamic>? ?? [])
        if (text is String && text.isNotEmpty)
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
    'Dicción': 'Articulá cada palabra con pausas breves '
        'entre frases para ganar claridad.',
    'Postura': 'Probá apoyar el peso en ambos pies: '
        'transmite estabilidad ante la audiencia.',
    'Confianza': 'Arrancá con una frase que domines perfecto; '
        'un buen inicio empuja todo el resto.',
    'Contacto Visual': 'Elegí tres puntos de la sala y rotá la mirada '
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

    final weakest = skills.reduce(
      (a, b) => a.percent <= b.percent ? a : b,
    );

    return SessionResult(
      overall: overall,
      level: levelFor(overall),
      skills: skills,
      tips: [
        SessionTip(
          text: 'Buen trabajo: mantuviste la constancia '
              'y terminaste la sesión completa.',
          isPositive: true,
        ),
        SessionTip(text: _tipsBySkill[weakest.key]!, isPositive: false),
      ],
    );
  }
}
