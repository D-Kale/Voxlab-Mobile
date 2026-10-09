import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accentRed,
        tertiary: AppColors.success,
        primaryContainer: AppColors.primaryContainer,
        secondaryContainer: AppColors.accentRedContainer,
        tertiaryContainer: AppColors.successContainer,
        onPrimary: AppColors.onPrimary,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        onSecondary: AppColors.onSecondary,
        onSecondaryContainer: AppColors.onAccentRedContainer,
        onTertiary: AppColors.onTertiary,
        onTertiaryContainer: AppColors.onSuccessContainer,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,
    );

    // Common 3D flat shadow for gamified feel
    final flat3dShadow = [
      BoxShadow(
        color: AppColors.accentRed,
        offset: const Offset(0, 4),
        blurRadius: 0,
        spreadRadius: 0,
      ),
    ];

    // Common thick red border
    const thickRedBorder = BorderSide(color: AppColors.accentRed, width: 3.5);

    return base.copyWith(
      textTheme: GoogleFonts.dmSansTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.dmSans(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: AppColors.darkBrown,
        ),
        displayMedium: GoogleFonts.dmSans(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: AppColors.darkBrown,
        ),
        displaySmall: GoogleFonts.dmSans(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.darkBrown,
        ),
        headlineLarge: GoogleFonts.dmSans(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: AppColors.darkBrown,
        ),
        headlineMedium: GoogleFonts.dmSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.darkBrown,
        ),
        headlineSmall: GoogleFonts.dmSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.darkBrown,
        ),
        titleLarge: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.darkBrown,
        ),
        titleMedium: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.darkBrown,
        ),
        titleSmall: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.darkBrown,
        ),
        labelLarge: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: AppColors.onPrimary,
        ),
        labelMedium: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
        ),
        labelSmall: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurfaceVariant,
        ),
        bodyLarge: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.darkBrown,
        ),
        bodyMedium: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.darkBrown,
        ),
        bodySmall: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurfaceVariant,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.dmSans(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.darkBrown,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: AppColors.accentRed,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: thickRedBorder,
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentRed,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.locked,
          disabledForegroundColor: AppColors.onLocked,
          shadowColor: AppColors.accentRed,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: thickRedBorder,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          textStyle: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ).copyWith(
          // Add 3D flat shadow effect
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return AppColors.accentRed.withValues(alpha: 0.8);
            }
            return null;
          }),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accentRed,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.locked,
          disabledForegroundColor: AppColors.onLocked,
          shadowColor: AppColors.accentRed,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: thickRedBorder,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          textStyle: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkBrown,
          side: thickRedBorder,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          textStyle: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentRed,
          textStyle: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: GoogleFonts.dmSans(
          color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: thickRedBorder,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: thickRedBorder,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: AppColors.accentRed, width: 4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: AppColors.error, width: 3.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: AppColors.error, width: 4),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.accentRed,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        height: 72,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.onPrimary);
          }
          return const IconThemeData(color: AppColors.onSurfaceVariant);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.onPrimary,
            );
          }
          return GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurfaceVariant,
          );
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accentRed,
        linearTrackColor: AppColors.surfaceContainerHigh,
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.surface,
        side: thickRedBorder,
        labelStyle: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.darkBrown,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.accentRed,
        thickness: 2,
      ),
      iconTheme: const IconThemeData(color: AppColors.darkBrown, size: 24),
      splashFactory: InkRipple.splashFactory,
      // Extensions for custom VoxLab styles
      extensions: <ThemeExtension<dynamic>>[
        VoxLabThemeExtension(
          flat3dShadow: flat3dShadow,
          thickRedBorder: thickRedBorder,
          cardRadius: 24.0,
          buttonRadius: 24.0,
          inputRadius: 24.0,
        ),
      ],
    );
  }
}

class VoxLabThemeExtension extends ThemeExtension<VoxLabThemeExtension> {
  final List<BoxShadow> flat3dShadow;
  final BorderSide thickRedBorder;
  final double cardRadius;
  final double buttonRadius;
  final double inputRadius;

  const VoxLabThemeExtension({
    required this.flat3dShadow,
    required this.thickRedBorder,
    required this.cardRadius,
    required this.buttonRadius,
    required this.inputRadius,
  });

  @override
  VoxLabThemeExtension copyWith({
    List<BoxShadow>? flat3dShadow,
    BorderSide? thickRedBorder,
    double? cardRadius,
    double? buttonRadius,
    double? inputRadius,
  }) {
    return VoxLabThemeExtension(
      flat3dShadow: flat3dShadow ?? this.flat3dShadow,
      thickRedBorder: thickRedBorder ?? this.thickRedBorder,
      cardRadius: cardRadius ?? this.cardRadius,
      buttonRadius: buttonRadius ?? this.buttonRadius,
      inputRadius: inputRadius ?? this.inputRadius,
    );
  }

  @override
  VoxLabThemeExtension lerp(
    ThemeExtension<VoxLabThemeExtension>? other,
    double t,
  ) {
    if (other is! VoxLabThemeExtension) return this;
    return VoxLabThemeExtension(
      flat3dShadow: other.flat3dShadow,
      thickRedBorder: other.thickRedBorder,
      cardRadius: other.cardRadius,
      buttonRadius: other.buttonRadius,
      inputRadius: other.inputRadius,
    );
  }

  static VoxLabThemeExtension of(BuildContext context) {
    return Theme.of(context).extension<VoxLabThemeExtension>() ??
        const VoxLabThemeExtension(
          flat3dShadow: [],
          thickRedBorder: BorderSide.none,
          cardRadius: 24,
          buttonRadius: 24,
          inputRadius: 24,
        );
  }
}