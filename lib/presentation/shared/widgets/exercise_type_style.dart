import 'package:flutter/material.dart';

import 'chunky.dart';

/// Per-type identity shared by the map, practice list and exercise header,
/// so a quiz looks like a quiz everywhere.
class ExerciseTypeStyle {
  const ExerciseTypeStyle._(this.colors, this.icon);

  final ChunkyColors colors;

  /// Filled icon, readable on a colored face.
  final IconData icon;

  static ExerciseTypeStyle of(String type) => switch (type) {
        'reading' => const ExerciseTypeStyle._(
            ChunkyColors.orange,
            Icons.menu_book_rounded,
          ),
        'quiz' => const ExerciseTypeStyle._(
            ChunkyColors.red,
            Icons.quiz_rounded,
          ),
        'writing' => const ExerciseTypeStyle._(
            ChunkyColors.green,
            Icons.edit_rounded,
          ),
        'oratory' || 'oratory_minigame' => const ExerciseTypeStyle._(
            ChunkyColors.brown,
            Icons.record_voice_over_rounded,
          ),
        'audio' => const ExerciseTypeStyle._(
            ChunkyColors.orange,
            Icons.headphones_rounded,
          ),
        'video' => const ExerciseTypeStyle._(
            ChunkyColors.orange,
            Icons.videocam_rounded,
          ),
        _ => const ExerciseTypeStyle._(
            ChunkyColors.orange,
            Icons.star_rounded,
          ),
      };
}
