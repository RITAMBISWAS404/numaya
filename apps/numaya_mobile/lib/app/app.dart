import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/connectivity/connectivity.dart';
import '../core/design_system/design_system.dart';
import '../features/auth/application/session_expiry.dart';
import '../features/demo/application/demo_motion.dart';
import '../features/demo/application/type_settings_controller.dart';
import '../features/lab/lab_registry.dart';
import '../features/settings/application/account_prefs.dart';
import '../l10n/l10n.dart';
import 'router.dart';
import 'routes.dart';

class NumayaApp extends ConsumerWidget {
  const NumayaApp({super.key});

  /// Development and test hook: wraps the app below `MaterialApp` (for example with
  /// `AccessibilityTools` from the dev-only `accessibility_tools` package, set by
  /// `test/widget/a11y_tools_audit_test.dart`). Always null in the app itself, so no development
  /// package is imported from `lib/` and release builds are unaffected.
  @visibleForTesting
  static TransitionBuilder? debugWrapper;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final haptics = ref.watch(accountPrefsProvider.select((p) => p.haptics));
    final reduceMotion = ref.watch(demoReduceMotionProvider);
    final online = ref.watch(connectivityProvider);
    // Review-build Dev Mode (UI-085 fonts, UI-095 brand, UI-096 shape, UI-098 secondary surface,
    // 14/15 body): applied before the theme is built. A change rebuilds every element on the next
    // frame so explicit styles follow, not just the theme.
    DevModeStyles.apply(ref.watch(typeSettingsProvider));
    ref.listen(typeSettingsProvider, (was, now) {
      if (was == now) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final root = WidgetsBinding.instance.rootElement;
        if (root != null) rebuildAllElements(root);
      });
    });
    // A session the server ended: ask to sign in again over the current screen, so it is still
    // there afterwards.
    ref.listen(sessionExpiryProvider, (was, expired) {
      if (expired && was != true) {
        unawaited(ref.read(routerProvider).push<void>(Routes.reauth));
      }
    });
    // Visual Lab V2 motion preset (MOT07): debug Design Lab choice, M1 everywhere else.
    AppMotion.preset = switch (ref.watch(labVariantProvider('motion'))) {
      'M0' => MotionPreset.m0,
      'M2' => MotionPreset.m2,
      _ => MotionPreset.m1,
    };
    // Replacement V8 app-wide comparisons: the proposed values everywhere but the Design Lab.
    // UI-098 replaced the r8-secondary-button lab group: the secondary surface is a Dev Mode
    // setting now (DevModeStyles.filledSecondary), so there is one control, not two.
    PhotoScrim.adaptive =
        ref.watch(labVariantProvider('r8-photo-scrim')) == 'A';
    // UI-094: the status template's surface (white card unless the Design Lab says otherwise).
    EmptyState.cardSurface =
        ref.watch(labVariantProvider('ui094-status-surface')) != 'A';
    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      // The approved design is light only; dark mode is a documented follow-up.
      themeMode: ThemeMode.light,
      routerConfig: ref.watch(routerProvider),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        Widget app = HapticsScope(enabled: haptics, child: child!);
        if (reduceMotion) {
          app = MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: app,
          );
        }
        if (!online) {
          final l10n = context.l10n;
          app = Column(
            children: [
              ConnectionBanner(message: l10n.offlineBanner),
              Expanded(
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: app,
                ),
              ),
            ],
          );
        }
        // Re-asserted on every frame from the root, so no route or sheet leaves the bars black.
        final wrap = debugWrapper;
        if (wrap != null) app = wrap(context, app);
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: AppSystemUi.style,
          child: app,
        );
      },
    );
  }
}
