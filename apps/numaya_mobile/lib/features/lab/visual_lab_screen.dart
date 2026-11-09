import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/routes.dart';
import '../../core/design_system/design_system.dart';
import '../../core/time/ist.dart';
import '../../l10n/l10n.dart';
import '../auth/presentation/welcome_screen.dart';
import '../commerce/application/economy_controller.dart';
import '../commerce/domain/catalog.dart';
import '../commerce/presentation/wallet_screen.dart';
import '../compliments/domain/compliment.dart';
import '../compliments/presentation/compliments_inbox.dart';
import '../dating/application/dating_controller.dart';
import '../dating/domain/sample_people.dart';
import '../dating/presentation/conversation_row.dart';
import '../dating/presentation/match_avatar.dart';
import '../dating/presentation/person_profile.dart';
import '../events_mvp/domain/sample_events_mvp.dart';
import '../events_mvp/presentation/ev_parts.dart';
import '../events_mvp/presentation/my_events_screens.dart';
import '../health/application/health_providers.dart';
import '../onboarding/application/onboarding_controller.dart';
import '../premium/application/premium_controller.dart';
import '../premium/presentation/premium_screens.dart';
import '../profile/presentation/profile_header_more.dart';
import '../profile/presentation/profile_setup_card.dart';
import '../profile/presentation/profile_variants.dart';
import '../verification/application/verification_controller.dart';
import 'activity_cards.dart';
import 'lab_banners.dart';
import 'lab_empty_state.dart';
import 'lab_registry.dart';
import 'likes_grid.dart';
import 'plan_picker.dart';
import 'profile_prompt_card.dart';

/// DEVELOPMENT ONLY. Visual Lab V2 Design Lab: choose any variant of every card family, priority
/// screen and motion preset; preview one family in isolation; switch the insights scenario. The
/// router refuses it wherever the Demo Hub is refused (release builds), and release builds
/// render the proposed defaults whatever is chosen here. English only: a tool, not product UI.
class VisualLabScreen extends ConsumerWidget {
  const VisualLabScreen({super.key});

  static const _screenRoutes = {
    'screen-profile': Routes.profile,
    'screen-heart': Routes.likes,
    'screen-chats': Routes.messages,
    'screen-discover': Routes.home,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final choices = ref.watch(labChoicesProvider);
    final lab = ref.read(labChoicesProvider.notifier);
    Widget group(LabGroup g) {
      final current = choices[g.id] ?? g.proposed;
      final v = g.variant(current);
      final needs = g.requires[current];
      return Container(
        key: ValueKey('lab-group-${g.id}'),
        margin: const EdgeInsets.only(bottom: AppSpacing.s3),
        padding: const EdgeInsets.all(AppLayout.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.all(AppRadii.card),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    g.title,
                    style: AppTypography.weight(
                      AppTypography.body,
                      AppTypography.semibold,
                    ),
                  ),
                ),
                Text(g.id, style: AppTypography.micro),
              ],
            ),
            const SizedBox(height: AppSpacing.s1),
            Text(g.question, style: AppTypography.caption),
            const SizedBox(height: AppSpacing.s3),
            Wrap(
              spacing: AppSpacing.s2,
              runSpacing: AppSpacing.s2,
              children: [
                for (final o in g.variants)
                  NumayaChip(
                    key: ValueKey('lab-${g.id}-${o.id}'),
                    label: o.id == g.proposed ? '${o.id} · proposed' : o.id,
                    selected: o.id == current,
                    onTap: () => lab.choose(g.id, o.id),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.s2),
            Text(
              '${v.id}: ${v.name} (${v.pass}). ${v.note}',
              style: AppTypography.bodySm,
            ),
            if (needs != null) ...[
              const SizedBox(height: AppSpacing.s1),
              Text(
                'Inside this screen it uses: ${needs.join(', ')}',
                style: AppTypography.caption,
              ),
            ],
            const SizedBox(height: AppSpacing.s2),
            Align(
              alignment: Alignment.centerLeft,
              child: switch (g.kind) {
                LabKind.component => TextLink(
                  label: 'Preview in isolation',
                  onPressed: () => context.push(
                    '${Routes.visualLabPreview}/${g.id}?v=$current',
                  ),
                ),
                LabKind.screen => TextLink(
                  label: 'Open the screen',
                  onPressed: () => context.go(_screenRoutes[g.id]!),
                ),
                LabKind.motion => Text(
                  'Applies app-wide now (route, sheet, tab and press timing).',
                  style: AppTypography.caption,
                ),
              },
            ),
          ],
        ),
      );
    }

    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () =>
            context.canPop() ? context.pop() : context.go(Routes.demo),
        title: 'Visual Lab V2',
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s4),
          const LabStatusBanner(
            variant: 'O',
            title: 'Development build only',
            body:
                'Proposed defaults show until you pick something here. Choices change '
                'layout only: never data, never navigation. Release builds ignore them.',
          ),
          const SizedBox(height: AppSpacing.s4),
          Wrap(
            spacing: AppSpacing.s2,
            runSpacing: AppSpacing.s2,
            children: [
              NumayaButton(
                key: const ValueKey('lab-reset'),
                label: 'Proposed defaults',
                small: true,
                expand: false,
                onPressed: lab.reset,
              ),
              NumayaButton(
                key: const ValueKey('lab-all-o'),
                label: 'All baselines (O)',
                small: true,
                expand: false,
                variant: NumayaButtonVariant.secondary,
                onPressed: () => lab
                  ..chooseAll('O')
                  ..choose('motion', 'M1'),
              ),
              for (final d in ['A', 'B', 'C'])
                NumayaButton(
                  key: ValueKey('lab-direction-$d'),
                  label: 'Direction $d',
                  small: true,
                  expand: false,
                  variant: NumayaButtonVariant.secondary,
                  onPressed: () => lab.chooseAll(d, kind: LabKind.screen),
                ),
            ],
          ),
          for (final kind in LabKind.values) ...[
            const SizedBox(height: AppSpacing.sectionGap),
            Text(switch (kind) {
              LabKind.component => 'Card families',
              LabKind.screen => 'Screens (directions)',
              LabKind.motion => 'Motion',
            }, style: AppTypography.section),
            const SizedBox(height: AppSpacing.s3),
            for (final g in kLabGroups)
              if (g.kind == kind &&
                  (ref.watch(eventsAvailableProvider) ||
                      !isDeferredLabGroup(g.id)))
                group(g),
          ],
        ],
      ),
    );
  }
}

/// DEVELOPMENT ONLY. One card family, one variant at a time, on the same fixture data, for the
/// gallery's component crops. The chip row switches variants in place.
class LabPreviewScreen extends ConsumerWidget {
  const LabPreviewScreen({super.key, required this.groupId, this.variant});

  final String groupId;
  final String? variant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final g = labGroup(groupId);
    final v = variant ?? g.proposed;
    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () =>
            context.canPop() ? context.pop() : context.go(Routes.visualLab),
        title: '${g.title} · $v',
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s3),
          Wrap(
            spacing: AppSpacing.s2,
            runSpacing: AppSpacing.s2,
            children: [
              for (final o in g.variants)
                NumayaChip(
                  label: o.id,
                  selected: o.id == v,
                  onTap: () => context.pushReplacement(
                    '${Routes.visualLabPreview}/${g.id}?v=${o.id}',
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.s2),
          Text(g.variant(v).name, style: AppTypography.caption),
          const SizedBox(height: AppSpacing.s4),
          KeyedSubtree(
            key: const ValueKey('lab-preview-body'),
            child: _preview(context, ref, g.id, v),
          ),
        ],
      ),
    );
  }

  Widget _preview(BuildContext context, WidgetRef ref, String id, String v) {
    final now = ref.read(clockProvider)();
    final people = [
      personById('maya') ?? kSamplePeople[0],
      kSamplePeople[1],
      kSamplePeople[2],
    ];
    void none() {}
    switch (id) {
      case 'match-avatar':
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final (p, f) in [
                (people[0], 0.92),
                (people[1], 0.45),
                (people[2], 0.12),
              ])
                MatchAvatarTile(
                  person: p,
                  fraction: f,
                  semanticLabel: p.name,
                  onTap: none,
                  variant: v,
                ),
            ],
          ),
        );
      case 'conversation-row':
        DemoMessage m(int id, String t, bool mine, int mins) => DemoMessage(
          id: id,
          text: t,
          status: MessageStatus.onDevice,
          at: now.subtract(Duration(minutes: mins)),
          mine: mine,
          sample: true,
        );
        return Column(
          children: [
            ConversationRow(
              person: people[0],
              last: m(1, 'Coffee at the market on Saturday, maybe?', false, 25),
              unread: 2,
              yourMove: true,
              now: now,
              onTap: none,
              variant: v,
            ),
            ConversationRow(
              person: people[1],
              last: m(2, 'Always. With far too much lemon.', true, 300),
              unread: 0,
              yourMove: false,
              now: now,
              onTap: none,
              variant: v,
            ),
            ConversationRow(
              person: people[2],
              last: m(3, 'Have you been?', false, 2000),
              unread: 0,
              yourMove: true,
              now: now,
              onTap: none,
              variant: v,
            ),
          ],
        );
      case 'compliment-card':
        Compliment c(String id, String p, ComplimentTarget t, String text) =>
            Compliment(
              id: id,
              personId: p,
              fromMe: false,
              target: t,
              text: text,
              sentAt: now.subtract(const Duration(hours: 5)),
            );
        return Column(
          children: [
            ComplimentCard(
              compliment: c(
                'p1',
                people[0].id,
                const ComplimentTarget.photo(0),
                'That light in your first photo is unreal. Where was it taken?',
              ),
              person: people[0],
              now: now,
              onOpen: none,
              onDismiss: none,
              variant: v,
            ),
            const SizedBox(height: AppSpacing.s3),
            ComplimentCard(
              compliment: c(
                'p2',
                people[1].id,
                const ComplimentTarget.prompt(0),
                'Your answer made me laugh out loud on the metro.',
              ),
              person: people[1],
              now: now,
              onOpen: none,
              onDismiss: none,
              variant: v,
            ),
          ],
        );
      case 'like-tile':
        return LikesGrid(
          variant: v,
          items: [
            for (final p in [...people, kSamplePeople[3]])
              (
                person: p,
                caption: '${p.distanceKm} km away',
                semanticLabel: p.name,
                badge: p.isNew
                    ? const StatusBadge(label: 'New', tone: BadgeTone.onPhoto)
                    : null,
                onTap: none,
              ),
          ],
        );
      case 'profile-header':
        final draft = ref.watch(onboardingProvider.select((s) => s.draft));
        final data = ProfileHeaderData(
          photo: draft.photos.isEmpty ? null : draft.photos.first.source,
          initial: draft.firstName.isEmpty ? 'A' : draft.firstName[0],
          name: context.l10n.profileNameAge(
            draft.firstName.isEmpty ? 'Alex' : draft.firstName,
            draft.ageOn(ref.read(onboardingProvider.notifier).today) ?? 30,
          ),
          verification: ref.watch(photoVerificationProvider).status,
          onEdit: none,
          onVerify: none,
          onPreview: none,
        );
        return switch (v) {
          'A' => ProfileHeaderCover(data: data),
          'B' => ProfileHeaderCompact(data: data),
          'C' => ProfileHeaderWithStreak(
            data: data,
            streakDays: 3,
            credits: 4,
            onStreak: none,
            onWallet: none,
          ),
          _ => ProfileHeaderActions(data: data),
        };
      case 'profile-setup':
        return ProfileSetupCard(
          health: ref.watch(profileHealthProvider),
          variant: v,
        );
      case 'prompt-card':
        return Column(
          children: [
            ProfilePromptCard(
              question: 'The way to win me over is',
              answer: 'Bring snacks to a board game night and lose gracefully.',
              action: ComplimentAnchor(name: people[0].name, onPressed: none),
              variant: v,
            ),
            const SizedBox(height: AppSpacing.s3),
            ProfilePromptCard(
              question: 'A long answer, to check the action never covers text',
              answer:
                  'I will happily walk across the whole city for a good bowl of noodles, '
                  'and then complain about my feet for the entire ride home, every time.',
              action: ComplimentAnchor(name: people[0].name, onPressed: none),
              variant: v,
            ),
          ],
        );
      case 'discover-photo':
        return SizedBox(
          child: PersonHeroCard(
            person: people[0],
            photoHeight: 480,
            layout: v,
            photoAction: SquircleIconButton(
              icon: NumayaIcons.more,
              label: 'Options',
              onPressed: none,
            ),
            complimentAction: ComplimentAnchor(
              name: people[0].name,
              onPressed: none,
            ),
          ),
        );
      case 'streak-card':
        final e = ref.watch(economyProvider);
        final run = e.streak.run(now);
        return StreakSummaryCard(
          variant: v,
          data: (
            length: run.length,
            progress: run.progress(7),
            cycle: 7,
            todayCounts: e.streak.qualifies(istDay(now)),
          ),
        );
      case 'wallet-card':
        final l = ref.watch(economyProvider).ledger;
        return WalletSummaryCard(
          variant: v,
          data: (
            weekly: l.weekly,
            earned: l.earned,
            purchased: l.purchased,
            recent: [
              for (final e in l.entries.reversed.take(3))
                (label: walletEntryLabel(context.l10n, e), amount: e.amount),
            ],
          ),
        );
      case 'plan-card':
        final l10n = context.l10n;
        final plans = ref.watch(catalogProvider).plans;
        return PlanPicker(
          variant: v,
          selected: 0,
          onSelect: (_) {},
          plans: [
            for (final p in plans)
              (
                key: ValueKey(p.kind.name),
                title: planLabel(l10n, p),
                price: formatInr(p.pricePaise),
                billing: planBilling(l10n, p),
              ),
          ],
          comparison: const [
            ('Likes a day', '5', '15'),
            ('Compliments a week', '0', '3'),
          ],
        );
      case 'status-banner':
        return Column(
          children: [
            LabStatusBanner(
              variant: v,
              icon: NumayaMobileIcons.archive,
              title: 'This chat is in Archive',
              body: 'No messages for 7 days. Send one and it moves back to Chats.',
            ),
            const SizedBox(height: AppSpacing.s3),
            LabStatusBanner(
              variant: v,
              tone: BannerTone.error,
              title: 'Numaya has limited your profile',
              body: 'A photo is being checked against our photo rules.',
              onTap: none,
            ),
          ],
        );
      case 'v4-welcome':
        return SizedBox(height: 360, child: WelcomeBrandImage(variant: v));
      case 'ea-event-card':
        final evs = sampleEventsMvp(now);
        return Column(
          children: [
            for (final (e, st) in [
              (evs[0], '12 places left'),
              (evs[1], 'Full'),
            ]) ...[
              EvCard(event: e, status: st, onTap: none, variant: v),
              const SizedBox(height: AppSpacing.s3),
            ],
          ],
        );
      case 'ea-met-card':
        return Column(
          children: [
            for (final (p, sent) in [
              (people[1], false),
              (people[2], true),
            ]) ...[
              PeerCard(
                person: p,
                sent: sent,
                passed: false,
                canSend: true,
                onInterested: none,
                onPass: none,
                onProfile: none,
                variant: v,
              ),
              const SizedBox(height: AppSpacing.s3),
            ],
          ],
        );
      case 'empty-state':
        return LabEmptyState(
          variant: v,
          slot: 'compliments_empty',
          slotLabel: 'purple cat holding a small note',
          icon: NumayaMobileIcons.compliment,
          title: 'No Compliments yet',
          body: 'When someone writes about a photo or prompt of yours, it shows here.',
          actionLabel: 'Go to Discover',
          onAction: none,
          steps: [(label: 'Add a prompt', icon: NumayaIcons.plus, onTap: none)],
        );
    }
    return Text('No preview for $id');
  }
}
