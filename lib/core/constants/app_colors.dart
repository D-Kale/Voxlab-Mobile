import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // VoxLab Brand Colors
  static const primary = Color(0xFFF4A221); // Warm Orange - Main Background
  static const primaryContainer = Color(0xFFFFE5B4);
  static const onPrimaryContainer = Color(0xFF7A4F00);

  // Intense Red - Accent / Thick Borders / 3D Depth
  static const accentRed = Color(0xFFD93B27);
  static const accentRedContainer = Color(0xFFFFEBEB);
  static const onAccentRedContainer = Color(0xFF7A1F17);

  // Success Green (kept for completed states)
  static const success = Color(0xFF3ECF6E);
  static const successContainer = Color(0xFFDCFCE7);
  static const onSuccessContainer = Color(0xFF14532D);

  // Dark Brown - Main Text
  static const darkBrown = Color(0xFF5C3A21);
  static const darkBrownLight = Color(0xFF8B6B4A);

  static const onPrimary = Color(0xFFFFFFFF);
  static const onSecondary = Color(0xFFFFFFFF);
  static const onTertiary = Color(0xFFFFFFFF);

  // Neutrals
  static const background = Color(0xFFF4A221); // Warm Orange - Main App Background
  static const surface = Color(0xFFFFFFFF); // White - Cards
  static const surfaceContainer = Color(0xFFFFF8F0);
  static const surfaceContainerHigh = Color(0xFFFFF0E0);
  static const onSurface = Color(0xFF5C3A21); // Dark Brown
  static const onSurfaceVariant = Color(0xFF8B6B4A);
  static const outline = Color(0xFFD93B27); // Intense Red for borders

  // Disabled / Locked
  static const locked = Color(0xFFFFE5B4);
  static const onLocked = Color(0xFF8B6B4A);

  static const error = Color(0xFFD93B27); // Intense Red

  // 3D depth ("lip") shades: the darker band under chunky buttons, cards and
  // map nodes. Each one is the matching brand color pushed darker.
  static const primaryDark = Color(0xFFD9860F);
  static const accentRedDark = Color(0xFFA8301F);
  static const successDark = Color(0xFF2CA65A);
  static const darkBrownDeep = Color(0xFF3D2614);

  // White cards sitting on the orange background.
  static const cardBorder = Color(0xFFF2DFC4);
  static const cardLip = Color(0xFFE0B87E);

  // Not-yet-started map nodes and neutral chips.
  static const idleFace = Color(0xFFFFF4E2);
  static const idleLip = Color(0xFFE6C597);

  // Trophies and rewards.
  static const gold = Color(0xFFFFC83D);
  static const goldDark = Color(0xFFE09E00);

  // =========================================================================
  // BACKWARD-COMPATIBLE ALIASES (for existing UI code - DO NOT REMOVE)
  // These map old Duolingo-style color names to new VoxLab palette
  // =========================================================================

  // Old secondary (green) → success green
  static const secondary = success;
  static const secondaryContainer = successContainer;
  static const onSecondaryContainer = onSuccessContainer;

  // Old tertiary (amber) → accentRed (for warm accent feel)
  static const tertiary = accentRed;
  static const tertiaryContainer = accentRedContainer;
  static const onTertiaryContainer = onAccentRedContainer;
}