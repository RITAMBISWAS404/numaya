import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/design_system/design_system.dart';
import '../features/auth/application/session_controller.dart';
import '../l10n/l10n.dart';
import 'routes.dart';

/// Direct-route recovery: an unknown or stale link lands here with one clear way back
/// (states-and-recovery: "Unavailable feature … never show a dead control").
class NotFoundScreen extends ConsumerWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final signedIn = ref.watch(sessionProvider)?.hasProfile ?? false;
    return NumayaScreen(
      footer: NumayaButton(
        label: signedIn ? l10n.forYouBackHome : l10n.notFoundStart,
        onPressed: () => context.go(signedIn ? Routes.home : Routes.welcome),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.s10),
        child: ResultPanel(
          illustration: NumayaIllustration.seenEveryone,
          title: l10n.notFoundTitle,
          body: l10n.notFoundBody,
        ),
      ),
    );
  }
}
