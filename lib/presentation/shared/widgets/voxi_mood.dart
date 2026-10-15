/// Voxi's poses. `happy` and `sleeping` are the original bust and sleeping
/// art; the rest come from the sticker sheet (background removed, upscaled
/// to 512x512).
enum VoxiMood {
  happy('voxi_awake'),
  sleeping('voxi_sleeping'),
  sleepy('voxi_sleepy'),
  bored('voxi_bored'),
  idle('voxi_idle'),
  angry('voxi_angry'),
  thinking('voxi_thinking'),
  love('voxi_love'),
  shy('voxi_shy'),
  laugh('voxi_laugh'),
  singing('voxi_singing');

  const VoxiMood(this._file);

  final String _file;

  String get asset => 'assets/images/$_file.png';

  /// Reaction to a session score on the results screen.
  static VoxiMood forScore(int score) {
    if (score >= 90) return love;
    if (score >= 75) return singing;
    if (score >= 50) return laugh;
    return thinking;
  }
}
