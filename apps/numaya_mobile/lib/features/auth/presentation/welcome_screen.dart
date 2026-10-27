import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../application/phone_entry_controller.dart';
import '../domain/auth_repository.dart';

/// B-02 Welcome: create an account or sign in. The hero slot stays empty until the supplied
/// artwork exists (no stand-in photos or art).
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  late final TapGestureRecognizer _terms = TapGestureRecognizer()
    ..onTap = () => _showLegal(context.l10n.legalTermsTitle);
  late final TapGestureRecognizer _privacy = TapGestureRecognizer()
    ..onTap = () => _showLegal(context.l10n.legalPrivacyTitle);

  @override
  void dispose() {
    _terms.dispose();
    _privacy.dispose();
    super.dispose();
  }

  void _showLegal(String title) {
    showNumayaSheet<void>(
      context: context,
      title: title,
      closeLabel: context.l10n.close,
      builder: (context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.s4),
        child: Text(
          context.l10n.legalPending,
          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
        ),
      ),
    );
  }

  void _start(AuthIntent intent) {
    ref.read(phoneEntryProvider.notifier).setIntent(intent);
    context.push(
      intent == AuthIntent.signIn
          ? '${Routes.phone}?intent=${Routes.intentSignIn}'
          : Routes.phone,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final demo = ref.watch(demoAuthProvider) != null;
    final width = MediaQuery.sizeOf(context).width
        .clamp(0.0, AppSpacing.contentMax);
    final linkStyle =
        AppTypography.weight(
          AppTypography.micro,
          AppTypography.semibold,
        ).copyWith(
          color: AppColors.textBrand,
          height: 18 / 12.5,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.textBrand.withValues(alpha: 0.45),
        );

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.surfaceBrand,
            AppColors.brandTint,
            AppColors.surface,
          ],
          stops: [0, 0.48, 0.72],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSpacing.contentMax,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.gutter,
                      AppSpacing.s4,
                      AppSpacing.gutter,
                      0,
                    ),
                    child: Row(
                      children: [
                        const Wordmark(),
                        const Spacer(),
                        if (demo) const DemoBadge(),
                      ],
                    ),
                  ),
                  // Reserved hero slot (registry id "welcome-hero"): empty until artwork exists.
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.gutter,
                      AppSpacing.s4,
                      AppSpacing.gutter,
                      AppSpacing.s2,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Semantics(
                          header: true,
                          child: Text(
                            l10n.welcomeTitle,
                            style: AppTypography.welcomeTitle(width),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s4),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 340),
                          child: Text(
                            l10n.welcomeLede,
                            style: AppTypography.weight(
                              AppTypography.input,
                              400,
                            ).copyWith(color: AppColors.textMuted),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s8),
                        NumayaButton(
                          label: l10n.welcomeCreateAccount,
                          onPressed: () => _start(AuthIntent.signUp),
                        ),
                        const SizedBox(height: 6),
                        NumayaButton(
                          label: l10n.welcomeHaveAccount,
                          variant: NumayaButtonVariant.quiet,
                          onPressed: () => _start(AuthIntent.signIn),
                        ),
                        const SizedBox(height: AppSpacing.s3),
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 300),
                            child: Text.rich(
                              TextSpan(
                                style: AppTypography.micro.copyWith(
                                  height: 18 / 12.5,
                                ),
                                children: [
                                  TextSpan(text: l10n.welcomeLegalPrefix),
                                  TextSpan(
                                    text: l10n.welcomeLegalTerms,
                                    style: linkStyle,
                                    recognizer: _terms,
                                  ),
                                  TextSpan(text: l10n.welcomeLegalMiddle),
                                  TextSpan(
                                    text: l10n.welcomeLegalPrivacy,
                                    style: linkStyle,
                                    recognizer: _privacy,
                                  ),
                                  TextSpan(text: l10n.welcomeLegalSuffix),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small label marking a development build that uses demo sign-in.
class DemoBadge extends StatelessWidget {
  const DemoBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.warningTint,
        borderRadius: AppRadii.all(AppRadii.pill),
      ),
      child: Text(
        context.l10n.demoBuildLabel,
        style: AppTypography.weight(
          AppTypography.caption,
          AppTypography.semibold,
        ).copyWith(color: AppColors.warning),
      ),
    );
  }
}
