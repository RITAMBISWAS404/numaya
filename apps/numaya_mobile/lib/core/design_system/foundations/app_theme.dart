import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_layout.dart';
import 'app_typography.dart';

/// Material theme built from the Numaya tokens. Numaya widgets style themselves from the
/// foundations directly; this theme covers the platform pieces (text selection, dialogs, page
/// transitions, system bars) so they match.
abstract final class AppTheme {
  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.brand,
      onPrimary: AppColors.onBrand,
      primaryContainer: AppColors.brandTintStrong,
      onPrimaryContainer: AppColors.textBrandDeep,
      secondary: AppColors.textSecondary,
      onSecondary: AppColors.surface,
      error: AppColors.danger,
      onError: AppColors.onBrand,
      errorContainer: AppColors.dangerTint,
      onErrorContainer: AppColors.danger,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textMuted,
      surfaceContainerHighest: AppColors.surfaceSoft,
      outline: AppColors.borderControl,
      outlineVariant: AppColors.borderSubtle,
      scrim: AppColors.scrim,
      inverseSurface: AppColors.surfaceInverse,
      onInverseSurface: AppColors.textOnInverse,
    );

    final textTheme = TextTheme(
      displayLarge: AppTypography.hero,
      displayMedium: AppTypography.display,
      headlineMedium: AppTypography.headline,
      titleLarge: AppTypography.titleSm,
      titleMedium: AppTypography.title,
      bodyLarge: AppTypography.body,
      bodyMedium: AppTypography.bodySm,
      labelLarge: AppTypography.button,
      labelMedium: AppTypography.label,
      bodySmall: AppTypography.caption,
      labelSmall: AppTypography.micro,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.surface,
      fontFamily: AppTypography.textFamily,
      textTheme: textTheme,
      // Numaya controls give their own press feedback (scale), as the web design does.
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.brand,
        selectionColor: AppColors.brandSubtle,
        selectionHandleColor: AppColors.brand,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.all(AppRadii.card),
        ),
        titleTextStyle: AppTypography.titleSm,
        contentTextStyle: AppTypography.body.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        modalBarrierColor: AppColors.scrim,
        showDragHandle: false,
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
