import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/connectivity/connectivity.dart';
import '../core/design_system/design_system.dart';
import '../features/auth/application/session_expiry.dart';
import '../features/demo/application/demo_motion.dart';
import '../features/settings/application/account_prefs.dart';
import '../l10n/l10n.dart';
import 'router.dart';
import 'routes.dart';

class NumayaApp extends ConsumerWidget {
  const NumayaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final haptics = ref.watch(accountPrefsProvider.select((p) => p.haptics));
    final reduceMotion = ref.watch(demoReduceMotionProvider);
    final online = ref.watch(connectivityProvider);
    // A session the server ended: ask to sign in again over the current screen, so it is still
    // there afterwards.
    ref.listen(sessionExpiryProvider, (was, expired) {
      if (expired && was != true) {
        unawaited(ref.read(routerProvider).push<void>(Routes.reauth));
      }
    });
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
              ConnectionBanner(
                message: l10n.offlineBanner,
                note: l10n.offlineBannerDemo,
              ),
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
        return app;
      },
    );
  }
}
