import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_layout.dart';
import 'app_transitions.dart';
import 'app_typography.dart';

/// The system bars over Numaya's light pages: transparent, with dark icons, so the page runs
/// edge to edge behind them (Android 15+ enforces this; older versions get it from
/// `SystemUiMode.edgeToEdge` in main.dart).
///
/// The navigation bar's colour is deliberately left unset: Android before 8.0 (API 24–25) cannot
/// draw dark navigation icons, so a transparent bar there would show white buttons on a light page.
/// The Android themes give each API level the right bar instead (res/values*/styles.xml).
abstract final class AppSystemUi {
  static const SystemUiOverlayStyle style = SystemUiOverlayStyle(
    statusBarColor: Color(0x00000000),
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemStatusBarContrastEnforced: false,
    systemNavigationBarIconBrightness: Brightness.dark,
    systemNavigationBarDividerColor: Color(0x00000000),
    systemNavigationBarContrastEnforced: false,
  );
}

/// Material theme built from the Monochrome Meetup roles. Numaya widgets style themselves from the foundations;
/// this covers the platform pieces (text selection, page transitions, system bars).
abstract final class AppTheme {
  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.accent,
      onPrimary: AppColors.accentForeground,
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
            top: Radius.circular(AppRadii.sheet),
          ),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          // Android: V16's push on the motion tokens (system back handles going back).
          TargetPlatform.android: NumayaPageTransitionsBuilder(),
          // iOS keeps the native edge swipe back.
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: const AppBarTheme(
        // Not SystemUiOverlayStyle.dark: that also paints the navigation bar black.
        systemOverlayStyle: AppSystemUi.style,
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
