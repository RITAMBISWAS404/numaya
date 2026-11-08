import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design_system/design_system.dart';
import 'lab_registry.dart';

/// A prompt and its answer on a profile. Card family `prompt-card` (Visual Lab V2). Every variant
/// keeps R05's rule: when there is an [action] (the Compliment squircle), it sits in a footer row
/// of its own at the bottom right, so the answer text can never run under it. The answer uses the
/// shared [AppTypography.answer] role (R07), the same as the bio.
///
/// O card with action footer, A open editorial (no card), B quote, C question chip, D compact.
class ProfilePromptCard extends ConsumerWidget {
  const ProfilePromptCard({
    super.key,
    required this.question,
    required this.answer,
    this.action,
    this.variant,
  });

  final String question;
  final String answer;
  final Widget? action;
  final String? variant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final v = variant ?? ref.watch(labVariantProvider('prompt-card'));
    final questionStyle = AppTypography.label.copyWith(
      color: AppColors.textMuted,
    );
    // The footer reserves the action's full 48pt target; without an action, nothing is reserved.
    // On the white card variants the action sits on the fill grey (OnWhiteSurface); the open
    // editorial variant (A) sits on the grey page and keeps the white squircle.
    Widget footer() => action == null
        ? const SizedBox.shrink()
        : Align(alignment: AlignmentDirectional.centerEnd, child: action!);

    final Widget body;
    switch (v) {
      case 'A':
        body = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(question, style: questionStyle),
            const SizedBox(height: AppSpacing.s2),
            Text(
              answer,
              style: AppTypography.weight(
                AppTypography.answer,
                AppTypography.semibold,
              ).copyWith(fontSize: 20, height: 28 / 20),
            ),
            if (action != null)
              footer()
            else
              const SizedBox(height: AppSpacing.s3),
            const ExcludeSemantics(
              child: SizedBox(
                height: AppBorders.hairline,
                child: ColoredBox(color: AppColors.divider),
              ),
            ),
          ],
        );
      case 'B':
        body = Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s5,
            AppSpacing.s4,
            AppSpacing.s4,
            AppSpacing.s1,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadii.all(AppRadii.card),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(question, style: questionStyle),
              const SizedBox(height: AppSpacing.s3),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExcludeSemantics(
                    child: Text(
                      '“',
                      style: AppTypography.hero.copyWith(
                        color: AppColors.accent,
                        height: 0.9,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s1),
                  Expanded(
                    child: Text(
                      answer,
                      style: AppTypography.answer.copyWith(
                        fontSize: 20,
                        height: 28 / 20,
                      ),
                    ),
                  ),
                ],
              ),
              if (action != null)
                footer()
              else
                const SizedBox(height: AppSpacing.s3),
            ],
          ),
        );
      case 'C':
        body = Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s4,
            AppSpacing.s4,
            AppSpacing.s4,
            AppSpacing.s1,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadii.all(AppRadii.card),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppLayout.pillInsetX,
                  vertical: AppLayout.pillInsetY,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentTint,
                  borderRadius: AppRadii.all(AppRadii.pill),
                ),
                child: Text(
                  question,
                  style: AppTypography.weight(
                    AppTypography.bodySm,
                    AppTypography.semibold,
                  ).copyWith(color: AppColors.accentOnTint),
                ),
              ),
              const SizedBox(height: AppSpacing.s3),
              Text(answer, style: AppTypography.answer),
              if (action != null)
                SizedBox(width: double.infinity, child: footer())
              else
                const SizedBox(height: AppSpacing.s3),
            ],
          ),
        );
      case 'D':
        body = Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s3,
            AppSpacing.s3,
            AppSpacing.s3,
            0,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadii.all(AppRadii.card),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(question, style: questionStyle.copyWith(fontSize: 14)),
              const SizedBox(height: AppSpacing.s1),
              Text(answer, style: AppTypography.body),
              if (action != null)
                footer()
              else
                const SizedBox(height: AppSpacing.s3),
            ],
          ),
        );
      default:
        // Owner note: the purple Compliment button sits on the card's own padding at the bottom
        // right. The 48pt target overhangs the 38pt squircle by 5pt, so the card pads 11pt on that
        // side and the text keeps the full 16pt; the footer row reserves the button's height, so
        // the answer never runs under it.
        const overhang =
            (SquircleIconButton.target - SquircleIconButton.size) / 2;
        body = Container(
          padding: action == null
              ? const EdgeInsets.all(AppLayout.cardPadding)
              : const EdgeInsets.fromLTRB(
                  AppLayout.cardPadding,
                  AppLayout.cardPadding,
                  AppLayout.cardPadding - overhang,
                  AppLayout.cardPadding - overhang,
                ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadii.all(AppRadii.card),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.only(
                  end: action == null ? 0 : overhang,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(question, style: questionStyle),
                    const SizedBox(height: AppSpacing.s2),
                    Text(answer, style: AppTypography.answer),
                  ],
                ),
              ),
              if (action != null) ...[
                const SizedBox(height: AppSpacing.s1),
                footer(),
              ],
            ],
          ),
        );
    }
    // Read in order: question, answer, then the Compliment button (its own node).
    return Semantics(container: true, child: body);
  }
}
