import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/design_system/design_system.dart';

/// DEVELOPMENT ONLY (Visual Lab). Ente alignment V3 semantic specimen: the owner-approved anchors
/// (#EB2D2F, #FF9B0F, #0D9F61) and their derived roles in real components, default and each
/// status side by side: banner, badge, inline field error, destructive row, disabled action and
/// confirmation, plus action groups. Measured pairs are in
/// docs/design/ente-alignment/FOUNDATIONS.md. Copy is fixture text, not product copy.
class SemanticSpecimenScreen extends StatelessWidget {
  const SemanticSpecimenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void none() {}
    Widget swatch(String name, Color c, Color on) => Expanded(
      child: Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: c,
          borderRadius: AppRadii.all(AppRadii.iconButton),
        ),
        child: Text(
          name,
          textAlign: TextAlign.center,
          style: AppTypography.caption.copyWith(color: on),
        ),
      ),
    );
    Widget section(String title, List<Widget> children) => Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sectionGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: AppTypography.section),
          const SizedBox(height: AppSpacing.s3),
          ...children,
        ],
      ),
    );
    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () =>
            context.canPop() ? context.pop() : context.go(Routes.visualLab),
        title: 'Semantic specimen',
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          section('Anchors and roles', [
            Row(
              children: [
                swatch('#EB2D2F\nanchor', AppColors.errorBase, AppColors.ink),
                const SizedBox(width: AppSpacing.s2),
                swatch('#FF9B0F\nanchor', AppColors.warningBase, AppColors.ink),
                const SizedBox(width: AppSpacing.s2),
                swatch('#0D9F61\nanchor', AppColors.successBase, AppColors.ink),
              ],
            ),
            const SizedBox(height: AppSpacing.s2),
            Row(
              children: [
                swatch('Error text', AppColors.dangerTint, AppColors.danger),
                const SizedBox(width: AppSpacing.s2),
                swatch(
                  'Warning text',
                  AppColors.warningTint,
                  AppColors.warning,
                ),
                const SizedBox(width: AppSpacing.s2),
                swatch(
                  'Success text',
                  AppColors.successTint,
                  AppColors.success,
                ),
              ],
            ),
          ]),
          section('Banners', const [
            StatusBanner(
              title: 'Sample events in this demo',
              body: 'Default (information).',
            ),
            SizedBox(height: AppSpacing.s2),
            StatusBanner(
              tone: BannerTone.pending,
              title: 'Reconfirm by Wed 28 Oct',
              body: 'Warning: a recoverable, pending action.',
            ),
            SizedBox(height: AppSpacing.s2),
            StatusBanner(
              tone: BannerTone.success,
              title: 'You kept your place',
              body: 'Success: a completed, confirmed state.',
            ),
            SizedBox(height: AppSpacing.s2),
            StatusBanner(
              tone: BannerTone.error,
              title: 'Couldn’t reserve',
              body: 'Error: nothing changed. Check your connection.',
            ),
          ]),
          section('Badges', [
            const Wrap(
              spacing: AppSpacing.s2,
              runSpacing: AppSpacing.s2,
              children: [
                StatusBadge(label: 'Free'),
                StatusBadge(label: 'You’re going', tone: BadgeTone.brand),
                StatusBadge(
                  label: 'Confirmed',
                  tone: BadgeTone.success,
                  icon: NumayaIcons.check,
                ),
                StatusBadge(
                  label: 'Reconfirm needed',
                  tone: BadgeTone.warning,
                  icon: NumayaIcons.clock,
                ),
                StatusBadge(
                  label: 'Cancelled',
                  tone: BadgeTone.error,
                  icon: NumayaIcons.close,
                ),
              ],
            ),
          ]),
          section('Inline field error', [
            NumayaTextField(
              label: 'Event name',
              error: 'Add a name of at least 3 characters.',
              controller: TextEditingController(text: 'Ch'),
            ),
          ]),
          section('Rows', [
            ListGroup(
              children: [
                ListRow(label: 'Mumbai', selected: true, onTap: none),
                ListRow(label: 'Bengaluru', selected: false, onTap: none),
                ListRow(
                  label: 'Cancel reservation',
                  leading: NumayaIcons.trash,
                  danger: true,
                  onTap: none,
                ),
              ],
            ),
          ]),
          section('Actions', [
            NumayaButtonGroup(
              children: [
                NumayaButton(
                  label: 'Pass',
                  small: true,
                  expand: true,
                  variant: NumayaButtonVariant.secondary,
                  onPressed: none,
                ),
                NumayaButton(
                  label: 'Interested',
                  small: true,
                  expand: true,
                  onPressed: none,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s3),
            const NumayaButton(
              label: 'Reserve a free place (disabled)',
              onPressed: null,
            ),
            const SizedBox(height: AppSpacing.s3),
            // Ente yes/no confirmation: stacked Button Large, main action on top, Cancel below.
            NumayaButtonGroup(
              layout: NumayaButtonGroupLayout.stacked,
              children: [
                NumayaButton(
                  label: 'Cancel reservation',
                  variant: NumayaButtonVariant.destructiveSolid,
                  onPressed: none,
                ),
                NumayaButton(
                  label: 'Keep my place',
                  variant: NumayaButtonVariant.secondary,
                  onPressed: none,
                ),
              ],
            ),
          ]),
          const SizedBox(height: AppSpacing.s8),
        ],
      ),
    );
  }
}
