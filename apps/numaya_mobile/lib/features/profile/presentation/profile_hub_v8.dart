import 'package:flutter/material.dart';

import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import 'profile_variants.dart';

/// The real blocks of the Profile hub, already built by [ProfileScreen] from the account's data.
/// UI-084 composes the ten directions from these, so every option shows the same identity,
/// figures, setup step, prompt and settings, with the same destinations.
class ProfileHubBlocks {
  const ProfileHubBlocks({
    required this.header,
    required this.completion,
    required this.identityRow,
    required this.statTiles,
    required this.credits,
    required this.streak,
    required this.progress,
    required this.setup,
    required this.profileGroup,
    required this.supportGroup,
    required this.prompt,
    required this.premium,
    required this.onWallet,
    required this.onStreak,
    required this.onSetup,
  });

  final ProfileHeaderData header;
  final int completion;

  /// The selected Profile A identity: photo, name, pills, Edit profile and Preview.
  final Widget identityRow;

  /// The selected credits and streak tiles, side by side.
  final Widget statTiles;
  final StatData credits;
  final StatData streak;
  final StatData progress;

  /// The next setup step card.
  final Widget setup;
  final Widget profileGroup;
  final Widget supportGroup;
  final Widget? prompt;
  final Widget? premium;
  final VoidCallback onWallet;
  final VoidCallback onStreak;
  final VoidCallback onSetup;
}

/// UI-084 (V8): ten whole-page Profile hub directions, from the source preview's studies. P1
/// portrait card, P2 compact account, P3 progress first, P4 two-column dashboard, P5 edit and
/// preview, P6 profile story, P7 action centre, P8 account and activity, P9 settings hub, P10
/// overlapping portrait (the UI-042 sketch). The default stays the selected Profile A.
List<Widget> profileHubV8(BuildContext context, String v, ProfileHubBlocks b) {
  final l10n = context.l10n;
  const gap = SizedBox(height: AppLayout.sectionGap);
  const small = SizedBox(height: AppSpacing.s3);
  Widget section(String title, Widget child) =>
      NumayaSection(title: title, child: child);
  Widget pills({bool center = false}) => Wrap(
    alignment: center ? WrapAlignment.center : WrapAlignment.start,
    spacing: AppSpacing.s2,
    runSpacing: AppSpacing.s2,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      b.header.badge(context),
      StatusBadge(label: l10n.profileCompletionLabel(b.completion)),
    ],
  );
  Widget name({TextAlign align = TextAlign.start, TextStyle? style}) =>
      Semantics(
        header: true,
        child: NameWithBadge(
          name: b.header.name,
          verified: b.header.verified,
          verifiedLabel: l10n.photoVerifiedLabel,
          style: style ?? AppTypography.headline,
        ),
      );
  Widget avatar(double size) => ExcludeSemantics(
    child: ClipOval(
      child: SizedBox.square(
        dimension: size,
        child: b.header.picture(initialSize: size * 0.36),
      ),
    ),
  );
  Widget actions({bool small = false}) => NumayaButtonGroup(
    children: [
      NumayaButton(
        key: const ValueKey('profile-header-edit'),
        label: l10n.profileEdit,
        small: small,
        onPressed: b.header.onEdit,
      ),
      NumayaButton(
        key: const ValueKey('profile-header-preview'),
        label: l10n.previewTitle,
        small: small,
        variant: NumayaButtonVariant.secondary,
        onPressed: b.header.onPreview,
      ),
    ],
  );
  Widget white(Widget child, {EdgeInsets? padding}) => Container(
    width: double.infinity,
    padding: padding ?? const EdgeInsets.all(AppLayout.cardPadding),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: AppRadii.all(AppRadii.heroCard),
    ),
    child: child,
  );
  Widget centered({double photo = 96}) => Column(
    children: [
      avatar(photo),
      const SizedBox(height: AppSpacing.s3),
      name(),
      const SizedBox(height: AppSpacing.s2),
      pills(center: true),
    ],
  );
  final stacked = Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      StatCard(data: b.credits, template: StatTemplate.rail, onTap: b.onWallet),
      small,
      StatCard(
        data: b.streak,
        template: StatTemplate.cadence,
        onTap: b.onStreak,
      ),
    ],
  );
  final promptOrNothing = b.prompt == null ? <Widget>[] : [b.prompt!, gap];
  final premiumOrNothing = b.premium == null ? <Widget>[] : [b.premium!, gap];

  switch (v) {
    case 'P1': // Portrait card: centred identity and nearby editing.
      return [
        white(
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              centered(),
              const SizedBox(height: AppSpacing.s4),
              actions(),
            ],
          ),
        ),
        small,
        b.statTiles,
        small,
        b.setup,
        gap,
        b.profileGroup,
        gap,
        ...promptOrNothing,
        ...premiumOrNothing,
        b.supportGroup,
      ];
    case 'P2': // Compact account: inline identity, paired compact actions, settings early.
      return [
        Row(
          children: [
            avatar(56),
            const SizedBox(width: AppSpacing.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  name(style: AppTypography.card),
                  const SizedBox(height: AppSpacing.s1),
                  pills(),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s3),
        actions(small: true),
        gap,
        b.profileGroup,
        gap,
        b.statTiles,
        small,
        b.setup,
        gap,
        ...promptOrNothing,
        ...premiumOrNothing,
        b.supportGroup,
      ];
    case 'P3': // Progress first.
      return [
        b.identityRow,
        const SizedBox(height: AppSpacing.s5),
        StatCard(
          key: const ValueKey('profile-progress-first'),
          data: b.progress,
          template: StatTemplate.rail,
          onTap: b.onSetup,
        ),
        small,
        b.setup,
        gap,
        b.statTiles,
        gap,
        b.profileGroup,
        gap,
        ...promptOrNothing,
        ...premiumOrNothing,
        b.supportGroup,
      ];
    case 'P4': // Two-column dashboard: highlights apart from identity.
      return [
        b.identityRow,
        gap,
        section(
          l10n.hubActivity,
          LayoutBuilder(
            builder: (context, box) {
              final w = (box.maxWidth - AppSpacing.s3) / 2;
              Widget cell(StatData d, VoidCallback onTap) => SizedBox(
                width: w,
                child: StatCard(
                  data: d,
                  template: StatTemplate.number,
                  onTap: onTap,
                ),
              );
              return Wrap(
                spacing: AppSpacing.s3,
                runSpacing: AppSpacing.s3,
                children: [
                  cell(b.credits, b.onWallet),
                  cell(b.streak, b.onStreak),
                  SizedBox(
                    width: box.maxWidth,
                    child: StatCard(
                      data: b.progress,
                      template: StatTemplate.split,
                      onTap: b.onSetup,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        gap,
        b.profileGroup,
        gap,
        ...promptOrNothing,
        ...premiumOrNothing,
        b.supportGroup,
      ];
    case 'P5': // Edit and preview as adjacent modes.
      return [
        Row(
          children: [
            avatar(64),
            const SizedBox(width: AppSpacing.s4),
            Expanded(child: name()),
          ],
        ),
        const SizedBox(height: AppSpacing.s4),
        NumayaSegmented(
          label: l10n.profileEdit,
          selected: 0,
          options: [
            (label: l10n.profileEdit, count: null, key: null),
            (label: l10n.previewTitle, count: null, key: null),
          ],
          onSelect: (i) => i == 0 ? b.header.onEdit() : b.header.onPreview(),
        ),
        const SizedBox(height: AppSpacing.s3),
        pills(),
        gap,
        ...promptOrNothing,
        b.setup,
        gap,
        b.statTiles,
        gap,
        b.profileGroup,
        gap,
        ...premiumOrNothing,
        b.supportGroup,
      ];
    case 'P6': // Profile story: lead into personal content.
      return [
        b.identityRow,
        gap,
        ...promptOrNothing,
        b.setup,
        gap,
        b.profileGroup,
        gap,
        b.supportGroup,
        gap,
        section(l10n.hubActivity, b.statTiles),
        if (b.premium != null) ...[gap, b.premium!],
      ];
    case 'P7': // Action centre: profile management together at the top.
      return [
        Row(
          children: [
            avatar(64),
            const SizedBox(width: AppSpacing.s4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  name(),
                  const SizedBox(height: AppSpacing.s2),
                  pills(),
                ],
              ),
            ),
          ],
        ),
        gap,
        ListGroup(
          title: l10n.v8ProfileManage,
          children: [
            ListRow(
              leading: NumayaIcons.edit,
              label: l10n.profileEdit,
              onTap: b.header.onEdit,
            ),
            ListRow(
              leading: NumayaIcons.public,
              label: l10n.previewTitle,
              onTap: b.header.onPreview,
            ),
            ListRow(
              leading: NumayaIcons.verified,
              label: l10n.editVerify,
              onTap: b.header.onVerify,
            ),
            ListRow(
              leading: NumayaIcons.pending,
              label: l10n.v8ProfileNextStep,
              value: l10n.profileCompletionLabel(b.completion),
              onTap: b.onSetup,
            ),
          ],
        ),
        gap,
        b.supportGroup,
        gap,
        section(l10n.hubActivity, b.statTiles),
        gap,
        ...promptOrNothing,
        ...premiumOrNothing,
      ];
    case 'P8': // Account and activity: activity in its own section.
      return [
        b.identityRow,
        gap,
        b.profileGroup,
        gap,
        b.setup,
        gap,
        section(l10n.hubActivity, stacked),
        gap,
        ...promptOrNothing,
        ...premiumOrNothing,
        b.supportGroup,
      ];
    case 'P9': // Settings hub: stacked sections with clear boundaries.
      return [
        white(
          Row(
            children: [
              avatar(56),
              const SizedBox(width: AppSpacing.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    name(style: AppTypography.card),
                    const SizedBox(height: AppSpacing.s1),
                    pills(),
                  ],
                ),
              ),
            ],
          ),
        ),
        gap,
        b.profileGroup,
        gap,
        b.supportGroup,
        gap,
        actions(),
        small,
        b.setup,
        gap,
        ...promptOrNothing,
        section(l10n.hubActivity, b.statTiles),
        if (b.premium != null) ...[gap, b.premium!],
      ];
    default: // P10 overlapping portrait (UI-042): the photo straddles the card's top edge.
      const photo = 112.0;
      return [
        const SizedBox(height: AppSpacing.s2),
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: photo / 2),
              child: white(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: photo / 2 + AppSpacing.s2),
                    Center(child: name()),
                    const SizedBox(height: AppSpacing.s2),
                    pills(center: true),
                    const SizedBox(height: AppSpacing.s4),
                    NumayaButton(
                      key: const ValueKey('profile-header-edit'),
                      label: l10n.profileEdit,
                      onPressed: b.header.onEdit,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
              ),
              padding: const EdgeInsets.all(4),
              child: avatar(photo - 8),
            ),
          ],
        ),
        small,
        b.setup,
        gap,
        ...promptOrNothing,
        section(l10n.hubActivity, b.statTiles),
        gap,
        b.profileGroup,
        gap,
        ...premiumOrNothing,
        b.supportGroup,
      ];
  }
}
