import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/media/media_permissions.dart';
import '../../../../data/media/speech_recorder.dart';
import '../../../../data/remote/services/analyzer_service.dart';
import '../../../shared/widgets/chunky.dart';
import 'game_kit.dart';

/// Asks for the microphone; explains and offers Settings when denied.
Future<bool> ensureMicrophone(BuildContext context, WidgetRef ref) async {
  MediaAccess access;
  try {
    access = await ref.read(mediaPermissionsProvider).requestMicrophone();
  } catch (_) {
    access = MediaAccess.denied;
  }
  if (access == MediaAccess.granted) return true;
  if (!context.mounted) return false;
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('Necesitamos el micrófono', style: gameText(20)),
      content: Text(
        'Este juego escucha tu voz. Activá el permiso del micrófono para '
        'jugarlo.',
        style: gameText(15, weight: FontWeight.w600),
      ),
      actions: [
        if (access == MediaAccess.permanentlyDenied)
          TextButton(
            onPressed: () {
              ref.read(mediaPermissionsProvider).openSettings();
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Abrir ajustes'),
          ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Entendido'),
        ),
      ],
    ),
  );
  return false;
}

/// What the speech AI said about a take.
class SpeechAnalysis {
  const SpeechAnalysis({
    required this.transcript,
    this.score,
    this.coachTip,
    this.fillers = 0,
  });

  final String transcript;

  /// 0..100, when the analyzer scored it.
  final int? score;
  final String? coachTip;
  final int fillers;

  factory SpeechAnalysis.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;
    final fillers = data['filler_words'];
    return SpeechAnalysis(
      transcript: (data['transcript'] as String? ?? '').trim(),
      score: (data['score'] as num?)?.round(),
      coachTip: (data['ai_feedback'] as String?)?.trim(),
      fillers: switch (fillers) {
        final num n => n.toInt(),
        final List<dynamic> l => l.length,
        final Map<dynamic, dynamic> m => m.values.whereType<num>().fold(
          0,
          (int s, n) => s + n.toInt(),
        ),
        _ => 0,
      },
    );
  }
}

/// Sends a take to the backend speech analyzer (Whisper + metrics + coach)
/// and deletes the local file afterwards.
Future<SpeechAnalysis> analyzeTake(
  WidgetRef ref,
  SpeechRecording take, {
  String? topic,
  int? minSeconds,
  int? targetSeconds,
}) async {
  final path = take.path;
  if (path == null) throw StateError('No hay audio grabado');
  try {
    final json = await ref
        .read(analyzerServiceProvider)
        .analyzeSpeech(
          path: path,
          fileName: take.fileName,
          topic: topic,
          minSeconds: minSeconds,
          targetSeconds: targetSeconds,
        );
    return SpeechAnalysis.fromJson(json);
  } finally {
    if (!kIsWeb) {
      File(path).delete().then((_) {}, onError: (_) {});
    }
  }
}

/// Lowercase, no accents, no punctuation, single spaces.
String normalizeSpeech(String text) {
  const from = 'áéíóúüñ';
  const to = 'aeiouun';
  final buffer = StringBuffer();
  for (final rune in text.toLowerCase().runes) {
    final ch = String.fromCharCode(rune);
    final i = from.indexOf(ch);
    final mapped = i >= 0 ? to[i] : ch;
    buffer.write(RegExp(r'[a-z0-9 ]').hasMatch(mapped) ? mapped : ' ');
  }
  return buffer.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
}

/// 0..1 similarity of two texts (character edit distance).
double speechSimilarity(String expected, String heard) {
  final a = normalizeSpeech(expected);
  final b = normalizeSpeech(heard);
  if (a.isEmpty || b.isEmpty) return 0;
  var previous = List<int>.generate(b.length + 1, (i) => i);
  for (var i = 1; i <= a.length; i++) {
    final current = List<int>.filled(b.length + 1, 0)..[0] = i;
    for (var j = 1; j <= b.length; j++) {
      final cost = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
      current[j] = min(
        min(current[j - 1] + 1, previous[j] + 1),
        previous[j - 1] + cost,
      );
    }
    previous = current;
  }
  return 1 - previous[b.length] / max(a.length, b.length);
}

/// Words of [expected] that do not appear in [heard].
List<String> missingWords(String expected, String heard) {
  final heardWords = normalizeSpeech(heard).split(' ').toSet();
  return [
    for (final word in expected.split(' '))
      if (normalizeSpeech(word).isNotEmpty &&
          !heardWords.contains(normalizeSpeech(word)))
        word.replaceAll(RegExp(r'[^\p{L}]', unicode: true), ''),
  ];
}

/// Big round record button with a live level halo.
class MicButton extends StatelessWidget {
  const MicButton({
    super.key,
    required this.recording,
    required this.onPressed,
    this.level = 0,
    this.label,
  });

  final bool recording;
  final VoidCallback? onPressed;
  final double level;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final colors = recording ? ChunkyColors.green : ChunkyColors.red;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 140,
          height: 140,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                width: 96 + (recording ? level * 44 : 0),
                height: 96 + (recording ? level * 44 : 0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.face.withValues(alpha: 0.25),
                ),
              ),
              Pressable(
                onTap: onPressed,
                builder: (pressed) => Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: onPressed == null
                        ? ChunkyColors.disabled.face
                        : colors.face,
                    boxShadow: [
                      BoxShadow(
                        color: onPressed == null
                            ? ChunkyColors.disabled.lip
                            : colors.lip,
                        offset: Offset(0, pressed ? 2 : 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    recording ? Icons.stop_rounded : Icons.mic_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (label != null) Text(label!, style: gameText(16)),
      ],
    );
  }
}
