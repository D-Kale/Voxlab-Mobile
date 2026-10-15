import 'package:flutter/material.dart';

import '../../../core/audio/music_service.dart';

import '../../shared/widgets/chunky.dart';

/// Skill families shown as sections on the Practice tab, in course order.
enum GameSkill {
  start('Para arrancar'),
  nerves('Nervios y respiración'),
  voice('Tu voz'),
  rhythm('Ritmo, pausas y muletillas'),
  body('Lenguaje corporal'),
  structure('Estructura del mensaje'),
  improv('Historias e improvisación');

  const GameSkill(this.label);

  final String label;
}

/// Every minigame of the Practice tab. Content lives in `game_content.dart`;
/// the playable widget is picked in `game_screen.dart`.
enum GameId {
  taboo(
    slug: 'palabra-prohibida',
    title: 'Palabra prohibida',
    tagline: 'Explicá sin decir lo obvio.',
    howTo:
        'Elegí la descripción que explica la palabra sin usar ninguna '
        'de las prohibidas. Así entrenás a buscar otras formas de decir '
        'las cosas.',
    icon: Icons.block_rounded,
    skill: GameSkill.start,
    colors: ChunkyColors.red,
  ),
  mythFact(
    slug: 'mito-o-realidad',
    title: 'Mito o realidad',
    tagline: 'Desarmá las creencias que te ponen nervioso.',
    howTo:
        'Leé cada frase y decidí rápido: ¿es un mito o es realidad? '
        'Tenés 4 segundos por frase.',
    icon: Icons.psychology_alt_rounded,
    skill: GameSkill.nerves,
    colors: ChunkyColors.green,
  ),
  breathBalloon(
    slug: 'globo-de-voxi',
    title: 'El globo de Voxi',
    tagline: 'Respiración cuadrada: 4, 4, 4, 4.',
    howTo:
        'Mantené apretado para inhalar y seguí apretando para sostener. '
        'Soltá justo cuando termine el sostén y no toques mientras '
        'exhalás y esperás. Cuatro ciclos.',
    icon: Icons.air_rounded,
    skill: GameSkill.nerves,
    colors: ChunkyColors.green,
  ),
  lastRow(
    slug: 'hasta-la-ultima-fila',
    title: 'Hasta la última fila',
    tagline: 'Tu volumen lanza el avión.',
    howTo:
        'Decí la frase con el volumen justo para que el avión de papel '
        'llegue a la fila marcada. Si gritás, choca contra la pared.',
    icon: Icons.campaign_rounded,
    skill: GameSkill.voice,
    colors: ChunkyColors.brown,
    usesMic: true,
  ),
  tongueTwister(
    slug: 'trabalenguas-turbo',
    title: 'Trabalenguas turbo',
    tagline: 'Lento, normal y ¡turbo!',
    howTo:
        'Decí el trabalenguas en voz alta antes de que se acabe el '
        'tiempo. Si se entiende bien, pasás a la marcha siguiente.',
    icon: Icons.speed_rounded,
    skill: GameSkill.voice,
    colors: ChunkyColors.brown,
    usesMic: true,
  ),
  emphasis(
    slug: 'cambia-el-sentido',
    title: 'Cambiá el sentido',
    tagline: 'Una palabra enfatizada cambia todo.',
    howTo:
        'Tocá la palabra que enfatizarías con la voz para que la frase '
        'signifique lo que se pide.',
    icon: Icons.format_bold_rounded,
    skill: GameSkill.rhythm,
    colors: ChunkyColors.orange,
  ),
  pausePerfect(
    slug: 'pausa-perfecta',
    title: 'Pausa perfecta',
    tagline: 'El silencio también habla.',
    howTo:
        'El texto avanza solo. Cuando aparezca la pausa, mantené '
        'apretado el botón y soltalo cuando el círculo llegue a la marca.',
    icon: Icons.pause_circle_filled_rounded,
    skill: GameSkill.rhythm,
    colors: ChunkyColors.orange,
  ),
  fillerHunt(
    slug: 'cazamuletillas',
    title: 'Cazamuletillas',
    tagline: 'Atrapá cada "eh" y "o sea".',
    howTo:
        'Tocá solo las muletillas antes de que se acabe el tiempo de '
        'cada frase. Si tocás una palabra normal, perdés un corazón.',
    icon: Icons.bug_report_rounded,
    skill: GameSkill.rhythm,
    colors: ChunkyColors.orange,
  ),
  bodySwipe(
    slug: 'que-dice-tu-cuerpo',
    title: '¿Qué dice tu cuerpo?',
    tagline: 'Postura, mirada y gestos.',
    howTo:
        'Deslizá a la derecha (APLOMO) si la pose transmite seguridad, y '
        'a la izquierda (NERVIOS) si transmite nervios o cierre.',
    icon: Icons.accessibility_new_rounded,
    skill: GameSkill.body,
    colors: ChunkyColors.red,
  ),
  hookSwipe(
    slug: 'gancho-o-bostezo',
    title: '¿Gancho o bostezo?',
    tagline: 'Que el público no se duerma.',
    howTo:
        'Deslizá a la derecha las aperturas y cierres que enganchan, y a '
        'la izquierda los que aburren. Si la atención llega a cero, el '
        'público se duerme.',
    icon: Icons.phishing_rounded,
    skill: GameSkill.structure,
    colors: ChunkyColors.green,
  ),
  speechBuilder(
    slug: 'arma-el-discurso',
    title: 'Armá el discurso',
    tagline: 'Gancho, ideas y cierre en orden.',
    howTo:
        'Tocá los bloques en el orden correcto para armar el discurso '
        'antes de que se acabe el tiempo. Ojo: a veces hay un intruso.',
    icon: Icons.view_agenda_rounded,
    skill: GameSkill.structure,
    colors: ChunkyColors.green,
  ),
  storyCards(
    slug: 'historia-en-3-cartas',
    title: 'Historia en 3 cartas',
    tagline: 'Personaje, lugar y problema al azar.',
    howTo:
        'Da vuelta tres cartas y contá una historia con situación, '
        'conflicto y resolución. Tenés 10 segundos para pensar.',
    icon: Icons.style_rounded,
    skill: GameSkill.improv,
    colors: ChunkyColors.brown,
    usesMic: true,
  ),
  improvWheel(
    slug: 'ruleta-de-improvisacion',
    title: 'Ruleta de improvisación',
    tagline: 'Tema y estructura al azar. ¡Hablá!',
    howTo:
        'Girá la ruleta: te toca un tema y una estructura. Tenés 5 '
        'segundos para pensar y 45 para hablar.',
    icon: Icons.casino_rounded,
    skill: GameSkill.improv,
    colors: ChunkyColors.red,
    usesMic: true,
  );

  const GameId({
    required this.slug,
    required this.title,
    required this.tagline,
    required this.howTo,
    required this.icon,
    required this.skill,
    required this.colors,
    this.usesMic = false,
  });

  final String slug;
  final String title;
  final String tagline;
  final String howTo;
  final IconData icon;
  final GameSkill skill;
  final ChunkyColors colors;
  final bool usesMic;

  /// Background loop while playing. Voice games stay silent so the
  /// microphone only hears the player.
  MusicTrack? get music => switch (this) {
    fillerHunt || mythFact => MusicTrack.upbeatBounce,
    bodySwipe || hookSwipe => MusicTrack.upbeatSpark,
    breathBalloon || pausePerfect => MusicTrack.focusDrift,
    emphasis || taboo => MusicTrack.focusTide,
    speechBuilder => MusicTrack.focusGlass,
    lastRow || tongueTwister || storyCards || improvWheel => null,
  };

  static GameId? fromSlug(String slug) {
    for (final game in values) {
      if (game.slug == slug) return game;
    }
    return null;
  }
}
