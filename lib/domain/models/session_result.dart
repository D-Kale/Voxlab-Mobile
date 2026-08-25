/// Session result consumed by the results screen.
///
/// The backend scoring endpoint returns the AI analysis for a session
/// (overall score, per-skill percentages, tips). [SessionResult.fromJson]
/// maps that payload; [SessionResultBuilder.fromScore] is the offline
/// fallback used while the device cannot reach the backend — the results
/// screen must not depend on which one produced the value.
class SessionSkill {
  const SessionSkill({required this.name, required this.percent});

  final String name;
  final int percent;
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
  });

  final int overall;
  final String level;
  final List<SessionSkill> skills;
  final List<SessionTip> tips;

  factory SessionResult.fromJson(Map<String, dynamic> json) {
    final skills = (json['skills'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(
          (s) => SessionSkill(
            name: s['name'] as String? ?? '',
            percent: (s['percent'] as num?)?.toInt() ?? 0,
          ),
        )
        .toList();

    final tips = (json['tips'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(
          (t) => SessionTip(
            text: t['text'] as String? ?? '',
            isPositive: t['is_positive'] as bool? ?? true,
          ),
        )
        .toList();

    return SessionResult(
      overall: (json['overall'] as num?)?.toInt() ?? 0,
      level: json['level'] as String? ?? '',
      skills: skills,
      tips: tips,
    );
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

  static SessionResult fromScore(int score) {
    final overall = score.clamp(0, 100);
    final skills = <SessionSkill>[];
    for (var i = 0; i < _skillNames.length; i++) {
      skills.add(
        SessionSkill(
          name: _skillNames[i],
          percent: (overall + _skillOffsets[i]).clamp(5, 99),
        ),
      );
    }

    final weakest = skills.reduce(
      (a, b) => a.percent <= b.percent ? a : b,
    );

    return SessionResult(
      overall: overall,
      level: _levelFor(overall),
      skills: skills,
      tips: [
        SessionTip(
          text: 'Buen trabajo: mantuviste la constancia '
              'y terminaste la sesión completa.',
          isPositive: true,
        ),
        SessionTip(text: _tipsBySkill[weakest.name]!, isPositive: false),
      ],
    );
  }

  static String _levelFor(int score) {
    if (score >= 90) return 'Comunicador excelente';
    if (score >= 75) return 'Comunicador confiable';
    if (score >= 50) return 'Comunicador en progreso';
    return 'Comunicador en formación';
  }
}
