import 'dart:math' as math;

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
    final width = MediaQuery.sizeOf(context).width
        .clamp(0.0, AppSpacing.contentMax);
    // The text column inside the gutters.
    final text = width - 2 * AppSpacing.gutter;
    final linkStyle =
        AppTypography.weight(
          AppTypography.micro,
          AppTypography.semibold,
        ).copyWith(
          color: AppColors.accentOnTint,
          height: 18 / 12.5,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.accentOnTint.withValues(alpha: 0.45),
        );

    // V16: the welcome sits on the stone page (`.theme-withings.screen--wash`).
    return ColoredBox(
      color: AppColors.canvas,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSpacing.contentMax,
              ),
              // Large text can need more than the screen: then the page scrolls and the sticker
              // hero gives up its space first.
              child: LayoutBuilder(
                builder: (context, viewport) => SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: viewport.maxHeight),
                    child: IntrinsicHeight(
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
                            // Wraps under very large text rather than overflowing.
                            child: Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                const Wordmark(),
                                // Demo builds: the badge opens the Demo Hub (screen catalogue).
                                if (demo)
                                  Pressable(
                                    onTap: () => context.push(Routes.demo),
                                    semanticLabel: l10n.demoHubOpen,
                                    excludeChildSemantics: true,
                                    child: const SizedBox(
                                      height: kMinInteractiveDimension,
                                      child: Center(
                                        widthFactor: 1,
                                        child: DemoBadge(),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // V16 keeps V11's hero: interests as tilted emoji stickers.
                          const Expanded(
                            child: _ZeroIntrinsicHeight(child: _StickerHero()),
                          ),
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
                                // `.welcome__lede { max-width: 31ch }`, as padding so the page can measure it.
                                Padding(
                                  padding: EdgeInsets.only(
                                    right: math.max(0, text - 272),
                                  ),
                                  child: Text(
                                    l10n.welcomeLede,
                                    style: AppTypography.input.copyWith(
                                      color: AppColors.textMuted,
                                    ),
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
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: math.max(0, (text - 300) / 2),
                                  ),
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

/// Small label marking a development build that uses demo sign-in: V16's neutral status label
/// (`.badge`: outlined 1pt ink, 6pt corner, medium).
class DemoBadge extends StatelessWidget {
  const DemoBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: AppRadii.all(AppRadii.tag),
        border: Border.all(color: AppColors.ink, width: AppBorders.hairline),
      ),
      child: Text(
        context.l10n.demoBuildLabel,
        style: AppTypography.weight(
          AppTypography.caption,
          AppTypography.medium,
        ).copyWith(color: AppColors.ink),
      ),
    );
  }
}

/// The welcome hero (`.welcome__stickers`): four interest emoji on 76pt page-coloured tiles with a
/// hairline, 20pt corners, tilted, placed by percentage of the hero as on the web.
class _StickerHero extends StatelessWidget {
  const _StickerHero();

  static const _stickers = [
    (emoji: '🍷', left: 0.16, top: 0.30, turn: -8.0),
    (emoji: '🎷', left: 0.50, top: 0.18, turn: 6.0),
    (emoji: '📷', left: 0.62, top: 0.50, turn: -4.0),
    (emoji: '🧗', left: 0.28, top: 0.62, turn: 5.0),
  ];

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: LayoutBuilder(
        builder: (context, box) {
          // The stickers need room; on short screens the hero simply stays empty.
          if (box.maxHeight < 200) return const SizedBox.expand();
          return Stack(
            children: [
              for (final s in _stickers)
                Positioned(
                  left: box.maxWidth * s.left,
                  top: box.maxHeight * s.top,
                  child: Transform.rotate(
                    angle: s.turn * 3.1415926535 / 180,
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: AppColors.canvas,
                        borderRadius: AppRadii.all(20),
                        border: Border.all(
                          color: AppColors.border,
                          width: AppBorders.hairline,
                          strokeAlign: BorderSide.strokeAlignInside,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Emoji(s.emoji, size: 34),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
