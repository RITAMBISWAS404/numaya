import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design_system/design_system.dart';
import '../../l10n/l10n.dart';
import '../dating/domain/sample_people.dart';
import '../dating/presentation/person_profile.dart';
import 'lab_registry.dart';

/// One person in the Premium Likes grid.
typedef LikeItem = ({
  SamplePerson person,
  String caption,
  String semanticLabel,
  Widget? badge,
  VoidCallback onTap,
});

/// Card family `like-tile` (Visual Lab V2): who liked the member (Premium). O photo tile with name
/// below in two columns; A name on photo; B list rows; C three columns; D large one-column cards
/// with a prompt preview. Same people, order and badges in every variant; the free state (count
/// and locked tiles) is separate and unchanged.
class LikesGrid extends ConsumerWidget {
  const LikesGrid({super.key, required this.items, this.variant});

  final List<LikeItem> items;
  final String? variant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final v = variant ?? ref.watch(labVariantProvider('like-tile'));
    final l10n = context.l10n;
    String title(SamplePerson p) => l10n.profileNameAge(p.name, p.age);
    Widget name(SamplePerson p, {Color? color, TextStyle? style}) =>
        NameWithBadge(
          name: title(p),
          verified: p.verified,
          verifiedLabel: l10n.photoVerifiedLabel,
          maxLines: 1,
          badgeColor: color,
          style:
              (style ??
                      AppTypography.weight(
                        AppTypography.row,
                        AppTypography.semibold,
                      ))
                  .copyWith(color: color),
        );
    Widget photo(SamplePerson p, {double ratio = 3 / 4}) => ClipRRect(
      borderRadius: AppRadii.all(AppRadii.card),
      child: PhotoPlaceholder(
        label: l10n.discoverPhotoLabel(p.name, 1),
        aspectRatio: ratio,
        child: personPhotoImage(p, 1),
      ),
    );
    Widget tap(LikeItem i, Widget child) => Pressable(
      onTap: i.onTap,
      semanticLabel: i.semanticLabel,
      excludeChildSemantics: true,
      pressedScale: 0.98,
      borderRadius: AppRadii.all(AppRadii.card),
      child: child,
    );

    switch (v) {
      case 'B':
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadii.all(AppRadii.card),
          ),
          child: Column(
            children: [
              for (final i in items)
                tap(
                  i,
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppLayout.cardPadding,
                      vertical: AppSpacing.s3,
                    ),
                    child: Row(
                      children: [
                        InitialsAvatar(
                          initial: i.person.initial,
                          size: 56,
                          image: personAvatarImage(i.person),
                          imageAlignment: personAvatarFocus(i.person),
                        ),
                        const SizedBox(width: AppSpacing.s3),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              name(i.person),
                              MetaText(i.caption, style: AppTypography.caption),
                            ],
                          ),
                        ),
                        if (i.badge != null) i.badge!,
                        const SizedBox(width: AppSpacing.s1),
                        const NumayaIcon(
                          NumayaIcons.chevronRight,
                          size: 18,
                          color: AppColors.iconSupporting,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      case 'D':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final i in items) ...[
              tap(
                i,
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadii.all(AppRadii.card),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: 4 / 3,
                            child: PhotoPlaceholder(
                              label: l10n.discoverPhotoLabel(i.person.name, 1),
                              aspectRatio: 4 / 3,
                              child: personPhotoImage(i.person, 1),
                            ),
                          ),
                          if (i.badge != null)
                            Positioned(
                              left: AppSpacing.s3,
                              top: AppSpacing.s3,
                              child: i.badge!,
                            ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(AppLayout.cardPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            name(i.person, style: AppTypography.card),
                            MetaText(i.caption, style: AppTypography.caption),
                            if (i.person.prompt != null) ...[
                              const SizedBox(height: AppSpacing.s3),
                              Text(
                                i.person.prompt!.question,
                                style: AppTypography.caption,
                              ),
                              Text(
                                i.person.prompt!.answer,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.body,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s3),
            ],
          ],
        );
      default:
        final cols = v == 'C' ? 3 : 2;
        final gap = v == 'C' ? AppSpacing.s2 : AppSpacing.s3;
        return LayoutBuilder(
          builder: (context, box) {
            // Large text on a narrow phone: fewer columns rather than truncated names.
            final big = MediaQuery.textScalerOf(context).scale(15) > 22;
            final n = big ? (cols - 1).clamp(1, 3) : cols;
            final w = (box.maxWidth - gap * (n - 1)) / n;
            return BackdropGroup(
              child: Wrap(
                spacing: gap,
                runSpacing: v == 'A' ? gap : AppSpacing.s5,
                children: [
                  for (final i in items)
                    SizedBox(
                      width: w,
                      child: tap(
                        i,
                        v == 'A'
                            ? Stack(
                                children: [
                                  photo(i.person),
                                  if (i.badge != null)
                                    Positioned(
                                      left: AppSpacing.s2,
                                      top: AppSpacing.s2,
                                      child: i.badge!,
                                    ),
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        bottom: Radius.circular(AppRadii.card),
                                      ),
                                      child: PhotoScrim(
                                        child: Padding(
                                          padding: const EdgeInsets.all(
                                            AppSpacing.s2,
                                          ),
                                          child: Align(
                                            alignment: Alignment.bottomLeft,
                                            child: PhotoLabel(
                                              compact: true,
                                              child: name(
                                                i.person,
                                                color:
                                                    AppColors.accentForeground,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      photo(i.person),
                                      if (i.badge != null)
                                        Positioned(
                                          left: AppSpacing.s2,
                                          top: AppSpacing.s2,
                                          child: i.badge!,
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.s2),
                                  name(
                                    i.person,
                                    style: v == 'C'
                                        ? AppTypography.weight(
                                            AppTypography.bodySm,
                                            AppTypography.semibold,
                                          )
                                        : null,
                                  ),
                                  if (v != 'C')
                                    MetaText(
                                      i.caption,
                                      style: AppTypography.caption,
                                    ),
                                ],
                              ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
    }
  }
}
