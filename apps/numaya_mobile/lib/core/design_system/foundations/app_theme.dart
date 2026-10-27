import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_layout.dart';
import 'app_typography.dart';

/// Material theme built from the V16 roles. Numaya widgets style themselves from the foundations;
/// this covers the platform pieces (text selection, page transitions, system bars).
abstract final class AppTheme {
  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.ink,
      onPrimary: AppColors.inkForeground,
      primaryContainer: AppColors.accentTint,
      onPrimaryContainer: AppColors.accentOnTint,
      secondary: AppColors.accent,
      onSecondary: AppColors.accentForeground,
      error: AppColors.negative,
      onError: AppColors.inkForeground,
      errorContainer: AppColors.dangerTint,
      onErrorContainer: AppColors.negative,
      surface: AppColors.surface,
      onSurface: AppColors.ink,
      onSurfaceVariant: AppColors.textMuted,
      surfaceContainerHighest: AppColors.fill,
      outline: AppColors.outline,
      outlineVariant: AppColors.border,
      scrim: AppColors.scrim,
      inverseSurface: AppColors.ink,
      onInverseSurface: AppColors.inkForeground,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.canvas,
      fontFamily: AppTypography.family,
      textTheme: TextTheme(
        displayLarge: AppTypography.hero,
        displayMedium: AppTypography.pageTitle,
        headlineMedium: AppTypography.flowTitle,
        titleLarge: AppTypography.section,
        titleMedium: AppTypography.sheetTitle,
        bodyLarge: AppTypography.body,
        bodyMedium: AppTypography.bodySm,
        labelLarge: AppTypography.button,
        labelMedium: AppTypography.label,
        bodySmall: AppTypography.caption,
        labelSmall: AppTypography.micro,
      ),
      // Numaya controls give their own press feedback (scale), as the web design does.
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.accent,
        selectionColor: AppColors.accentTint,
        selectionHandleColor: AppColors.accent,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        modalBarrierColor: AppColors.scrim,
        showDragHandle: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadii.photo),
          ),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: const AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
