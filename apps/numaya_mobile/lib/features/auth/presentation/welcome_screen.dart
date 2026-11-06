import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../application/phone_entry_controller.dart';
import '../domain/auth_repository.dart';

/// B-02 Welcome in V16 form: the stone page, the wordmark, V11's emoji sticker hero (interests,
/// not people), a bold grotesk headline, an ink primary button and a quiet sign-in.
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
    final linkStyle =
        AppTypography.weight(
          AppTypography.micro,
          AppTypography.semibold,
        ).copyWith(
          color: AppColors.accentOnTint,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.accentOnTint.withValues(alpha: 0.45),
        );
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    // UI-001: a large branded image fills the upper region; everything below sits in one white
    // card with rounded top corners. Large text scrolls the page; the image gives up its space
    // first.
    return ColoredBox(
      color: AppColors.canvas,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSpacing.contentMax),
            child: LayoutBuilder(
              builder: (context, viewport) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: viewport.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _ZeroIntrinsicHeight(
                            // Demo builds only: the image opens the Demo Hub, which used to hang
                            // off the (removed) Demo build badge. Same accessible name, so the
                            // screen catalogue stays reachable.
                            child: demo
                                ? Pressable(
                                    onTap: () => context.push(Routes.demo),
                                    semanticLabel: l10n.demoHubOpen,
                                    excludeChildSemantics: true,
                                    pressedScale: 1,
                                    child: const WelcomeBrandImage(),
                                  )
                                : const WelcomeBrandImage(),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.s5,
                            AppSpacing.s6,
                            AppSpacing.s5,
                            AppSpacing.s4 + bottomInset,
                          ),
                          decoration: const BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(AppRadii.sheet),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Semantics(
                                header: true,
                                child: Text(
                                  l10n.welcomeTitle,
                                  style: AppTypography.hero,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.s3),
                              Text(
                                l10n.welcomeLede,
                                style: AppTypography.body.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.s6),
                              NumayaButton(
                                label: l10n.welcomeCreateAccount,
                                onPressed: () => _start(AuthIntent.signUp),
                              ),
                              const SizedBox(height: AppSpacing.s3),
                              NumayaButton(
                                label: l10n.welcomeHaveAccount,
                                variant: NumayaButtonVariant.quiet,
                                onPressed: () => _start(AuthIntent.signIn),
                              ),
                              const SizedBox(height: AppSpacing.s4),
                              Text.rich(
                                TextSpan(
                                  style: AppTypography.micro,
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
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Lets the sticker hero take whatever height is left without asking it how tall it wants to be
/// (it lays itself out from the space it gets).
class _ZeroIntrinsicHeight extends SingleChildRenderObjectWidget {
  const _ZeroIntrinsicHeight({required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderZeroIntrinsicHeight();
}

class _RenderZeroIntrinsicHeight extends RenderProxyBox {
  @override
  double computeMinIntrinsicHeight(double width) => 0;

  @override
  double computeMaxIntrinsicHeight(double width) => 0;

  @override
  double computeMinIntrinsicWidth(double height) => 0;

  @override
  double computeMaxIntrinsicWidth(double height) => 0;
}

/// The upper region of Welcome (UI-001): one large branded image containing the Numaya name.
///
/// TEMPORARY ARTWORK. No approved image with the Numaya name exists in the project yet, so this
/// draws the brand from the existing code-drawn mark and wordmark on the brand tint. Replace the
/// body of [build] with the approved asset (for example `Image.asset(..., fit: BoxFit.cover)`)
/// when it is supplied; the layout around it does not change. Decorative: the headline and the
/// account actions carry the meaning.
class WelcomeBrandImage extends StatelessWidget {
  const WelcomeBrandImage({super.key});

  static const String brandName = 'numaya';

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: ColoredBox(
        color: AppColors.accentTint,
        child: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, box) {
              // Short screens or large text: the image yields its space to the card.
              if (box.maxHeight < 120) return const SizedBox.expand();
              final mark = (box.maxHeight * 0.28).clamp(48.0, 96.0);
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BrandMark(size: mark),
                    const SizedBox(height: AppSpacing.s4),
                    Text(
                      brandName,
                      style: AppTypography.wordmark().copyWith(
                        fontSize: mark * 0.5,
                        height: 1,
                        color: AppColors.accentOnTint,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
