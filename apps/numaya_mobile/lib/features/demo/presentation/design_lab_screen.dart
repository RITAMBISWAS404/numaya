import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../events/domain/sample_events.dart';
import '../../events/presentation/event_parts.dart';

/// DEVELOPMENT ONLY. The Monochrome Meetup Design Lab: every surface, type role, control and
/// state of the experimental design system on one scrolling page, for visual review
/// (docs/design-experiments/monochrome-meetup/DESIGN_SYSTEM.md). Reached from the Demo Hub; the
/// router refuses it whenever the Demo Hub is refused (release builds). Copy here is English-only
/// on purpose: it is a tool, not product UI.
class DesignLabScreen extends StatefulWidget {
  const DesignLabScreen({super.key});

  @override
  State<DesignLabScreen> createState() => _DesignLabScreenState();
}

class _DesignLabScreenState extends State<DesignLabScreen> {
  int _tab = 0;
  int _segment = 0;
  bool _switch = true;
  int _radio = 0;
  bool _check = true;
  final _chips = <String>{'Jazz'};
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final event = sampleEvents(now).first;
    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () =>
            context.canPop() ? context.pop() : context.go(Routes.demo),
        title: 'Design Lab',
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s4),
          const InfoCard(
            icon: NumayaIcons.info,
            title: 'Monochrome Meetup',
            body:
                'Development build only. Every token and component of the experimental '
                'design system, for visual review.',
          ),
          _section('Surfaces'),
          Wrap(
            spacing: AppSpacing.s3,
            runSpacing: AppSpacing.s3,
            children: [
              _swatch('Canvas', AppColors.canvas, border: true),
              _swatch('Surface', AppColors.surface, border: true),
              _swatch('Fill', AppColors.fill),
              _swatch('Photo', AppColors.photo),
              _swatch('Line', AppColors.border),
              _swatch('Outline', AppColors.outline, light: true),
              _swatch('Ink', AppColors.ink, light: true),
              _swatch('Text 2', AppColors.textSecondary, light: true),
              _swatch('Muted', AppColors.textMuted, light: true),
              _swatch('Brand', AppColors.accent, light: true),
              _swatch('Brand text', AppColors.accentOnTint, light: true),
              _swatch('Brand subtle', AppColors.accentTint),
              _swatch('Success', AppColors.positive, light: true),
              _swatch('Danger', AppColors.negative, light: true),
            ],
          ),
          _section('Type'),
          WhiteCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Maya, 29', style: AppTypography.hero),
                Text('Events', style: AppTypography.pageTitle),
                Text(
                  'Let’s start with an intro',
                  style: AppTypography.flowTitle,
                ),
                Text('Your prompt', style: AppTypography.section),
                Text('Board games and natural wine', style: AppTypography.card),
                Text(
                  'Picnic in the park with board games. Bring a friend, we’ll have snacks.',
                  style: AppTypography.body,
                ),
                Text(
                  'Liked your profile · about 4 km',
                  style: AppTypography.caption,
                ),
                Text('SAT, 31 OCT · 19:00', style: AppTypography.labelCaps),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('84', style: AppTypography.metric),
                    const SizedBox(width: AppSpacing.s1),
                    Text('/ 100', style: AppTypography.metricUnit),
                  ],
                ),
              ],
            ),
          ),
          _section('Buttons'),
          NumayaButton(label: 'Join event', onPressed: () {}),
          const SizedBox(height: AppSpacing.s3),
          NumayaButton(
            label: 'Not now',
            variant: NumayaButtonVariant.secondary,
            onPressed: () {},
          ),
          const SizedBox(height: AppSpacing.s3),
          NumayaButton(
            label: 'Set Opening Moves',
            variant: NumayaButtonVariant.brand,
            onPressed: () {},
          ),
          const SizedBox(height: AppSpacing.s3),
          const NumayaButton(label: 'Disabled', onPressed: null),
          const SizedBox(height: AppSpacing.s3),
          NumayaButton(
            label: 'Unmatch',
            variant: NumayaButtonVariant.destructiveSolid,
            onPressed: () {},
          ),
          const SizedBox(height: AppSpacing.s3),
          Wrap(
            spacing: AppSpacing.s3,
            runSpacing: AppSpacing.s3,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              NumayaButton(
                label: 'Edit profile',
                small: true,
                icon: NumayaIcons.edit,
                variant: NumayaButtonVariant.secondary,
                onPressed: () {},
              ),
              NumayaButton(
                label: 'Find your people',
                small: true,
                onPressed: () {},
              ),
              NumayaButton(
                label: 'Loading',
                small: true,
                loading: true,
                onPressed: () {},
              ),
              NavIconButton(
                icon: NumayaIcons.share,
                label: 'Share',
                onPressed: () {},
              ),
              NavIconButton(
                icon: NumayaIcons.heart,
                label: 'Save',
                outline: !_saved,
                onPressed: () => setState(() => _saved = !_saved),
              ),
              NumayaFab(onPressed: () {}, semanticLabel: 'Next'),
            ],
          ),
          const SizedBox(height: AppSpacing.s3),
          TextLink(label: 'Edit attendance', onPressed: () {}),
          _section('Pills, segments and chips'),
          ViewTabs(
            label: 'Filter',
            options: const [
              (label: 'Upcoming', count: null),
              (label: 'Today', count: null),
              (label: 'Tomorrow', count: null),
              (label: 'Weekend', count: null),
            ],
            selected: _tab,
            onSelect: (i) => setState(() => _tab = i),
          ),
          const SizedBox(height: AppSpacing.s3),
          ViewTabs(
            label: 'Segments',
            options: const [
              (label: 'All', count: 7),
              (label: 'New', count: 4),
              (label: 'Nearby', count: 3),
            ],
            selected: _segment,
            onSelect: (i) => setState(() => _segment = i),
          ),
          const SizedBox(height: AppSpacing.s3),
          Wrap(
            spacing: AppSpacing.s2,
            runSpacing: AppSpacing.s2,
            children: [
              for (final c in ['Jazz', 'Natural wine', 'Climbing'])
                NumayaChip(
                  label: c,
                  selected: _chips.contains(c),
                  onTap: () => setState(
                    () => _chips.contains(c) ? _chips.remove(c) : _chips.add(c),
                  ),
                ),
              NumayaChip(
                label: 'Unavailable',
                selected: false,
                available: false,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s3),
          const Wrap(
            spacing: AppSpacing.s2,
            runSpacing: AppSpacing.s2,
            children: [
              StatusBadge(label: 'First event', tone: BadgeTone.brand),
              StatusBadge(label: 'Full'),
              StatusBadge(label: 'Few spots left', tone: BadgeTone.brand),
            ],
          ),
          _section('Fields'),
          const NumayaTextField(label: 'First name', placeholder: 'Your name'),
          const SizedBox(height: AppSpacing.s3),
          const NumayaTextField(
            label: 'Email',
            placeholder: 'you@example.com',
            error: 'Enter an email like name@example.com',
          ),
          const SizedBox(height: AppSpacing.s3),
          NumayaSearchField(placeholder: 'Search events', onChanged: (_) {}),
          _section('Controls'),
          ListGroup(
            children: [
              ListRow(
                label: 'Show gender on profile',
                switchValue: _switch,
                onSwitch: (v) => setState(() => _switch = v),
              ),
              const ListRow(
                label: 'Incognito',
                detail: 'Premium',
                switchValue: false,
              ),
              ListRow(
                leading: NumayaIcons.shield,
                label: 'Safety centre',
                value: 'Open',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s3),
          WhiteCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (final (i, l) in ['Woman', 'Man', 'Nonbinary'].indexed)
                  OptionCard(
                    label: l,
                    selected: _radio == i,
                    onTap: () => setState(() => _radio = i),
                  ),
                OptionCard(
                  label: 'Show me in Discover',
                  kind: OptionKind.checkbox,
                  selected: _check,
                  onTap: () => setState(() => _check = !_check),
                ),
              ],
            ),
          ),
          _section('Cards'),
          EventCard(
            event: event,
            now: now,
            area: null,
            saved: _saved,
            onOpen: () {},
            onToggleSave: () => setState(() => _saved = !_saved),
          ),
          const SizedBox(height: AppSpacing.s3),
          Row(
            children: [
              Expanded(
                child: _metric(
                  'Profile completeness',
                  '84',
                  '%',
                  'Above the 70% target',
                ),
              ),
              const SizedBox(width: AppSpacing.s3),
              Expanded(
                child: _metric(
                  'Likes this week',
                  '—',
                  '',
                  'Not enough data yet',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s3),
          CompletionCard(
            percent: 62,
            title: 'Profile 62% complete',
            body: 'Profiles with more to talk about get more matches.',
            actionLabel: 'Complete profile',
            onAction: () {},
          ),
          const SizedBox(height: AppSpacing.s3),
          const StatusBanner(
            title: 'You’re offline',
            body: 'Changes will send when you reconnect.',
            tone: BannerTone.error,
          ),
          _section('People and messages'),
          const Row(
            children: [
              InitialsAvatar(initial: 'P', verified: true),
              SizedBox(width: AppSpacing.s3),
              InitialsAvatar(initial: 'J', ring: true),
              SizedBox(width: AppSpacing.s3),
              InitialsAvatar(initial: 'A', size: 64),
            ],
          ),
          const SizedBox(height: AppSpacing.s3),
          const Align(
            alignment: Alignment.centerRight,
            child: MessageBubble(text: 'That bakery on Columbia Road, right?'),
          ),
          const SizedBox(height: AppSpacing.s2),
          const Align(
            alignment: Alignment.centerLeft,
            child: MessageBubble(
              text: 'Yes! The cardamom buns sell out by ten.',
              mine: false,
            ),
          ),
          const SizedBox(height: AppSpacing.s3),
          DecisionBar(
            passLabel: 'Pass',
            superLabel: 'SuperSwipe',
            likeLabel: 'Like',
            onPass: () {},
            onSuper: () {},
            onLike: () {},
          ),
          _section('States'),
          const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
          EmptyState(
            title: 'No incoming likes yet',
            body: 'When someone likes your profile, they’ll show up here.',
            art: const IllustrationSlot(
              slot: 'likes_empty',
              label: 'No incoming likes yet',
              width: 200,
            ),
            action: NumayaButton(
              label: 'Find your people',
              small: true,
              onPressed: () {},
            ),
          ),
          _section('Illustration slots'),
          const IllustrationSlot(
            slot: 'events_explore',
            label: 'Explore events near you',
            aspectRatio: 16 / 9,
          ),
          const SizedBox(height: AppSpacing.s3),
          Row(
            children: [
              NumayaButton(
                label: 'Open sheet',
                small: true,
                variant: NumayaButtonVariant.secondary,
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  sheetAnimationStyle: AppMotion.sheet(context),
                  builder: (_) => Padding(
                    padding: const EdgeInsets.all(AppLayout.screenGutter),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('A bottom sheet', style: AppTypography.sheetTitle),
                        const SizedBox(height: AppSpacing.s2),
                        Text(
                          'White, 28pt top corners, the modal scrim behind.',
                          style: AppTypography.body,
                        ),
                        const SizedBox(height: AppSpacing.s5),
                        NumayaButton(
                          label: 'Done',
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppLayout.screenBottom),
        ],
      ),
    );
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(
      top: AppSpacing.sectionGap,
      bottom: AppLayout.headingGap,
    ),
    child: Semantics(
      header: true,
      child: Text(title, style: AppTypography.section),
    ),
  );

  Widget _swatch(
    String name,
    Color c, {
    bool light = false,
    bool border = false,
  }) {
    return Container(
      width: 96,
      height: 64,
      padding: const EdgeInsets.all(AppSpacing.s2),
      alignment: Alignment.bottomLeft,
      decoration: BoxDecoration(
        color: c,
        borderRadius: AppRadii.all(AppRadii.tile),
        border: border ? Border.all(color: AppColors.border) : null,
      ),
      child: Text(
        name,
        style: AppTypography.micro.copyWith(
          color: light ? AppColors.inkForeground : AppColors.ink,
        ),
      ),
    );
  }

  /// A Bevel-style metric card: label, large number with unit, status line.
  Widget _metric(String label, String value, String unit, String status) {
    return WhiteCard(
      padding: const EdgeInsets.all(AppLayout.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.caption),
          const SizedBox(height: AppSpacing.s2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: AppTypography.metric),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 2),
                Text(unit, style: AppTypography.metricUnit),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.s1),
          Text(
            status,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
