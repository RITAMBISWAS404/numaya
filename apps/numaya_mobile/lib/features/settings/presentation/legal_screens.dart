import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../commerce/presentation/store_screens.dart';
import '../../help/application/support_tickets.dart';

/// The legal documents (S45). Reachable signed out (Welcome) and signed in (Settings).
enum LegalDoc { privacy, terms, community, safety }

String legalDocTitle(AppLocalizations l10n, LegalDoc d) => switch (d) {
  LegalDoc.privacy => l10n.legalPrivacyTitle,
  LegalDoc.terms => l10n.legalTermsTitle,
  LegalDoc.community => l10n.legalCommunity,
  LegalDoc.safety => l10n.legalSafetyContacts,
};

/// S45: the list of documents.
class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () => context.pop(),
        backLabel: l10n.back,
        title: l10n.legalTitle,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.s4),
        child: ListGroup(
          children: [
            for (final d in LegalDoc.values)
              ListRow(
                key: ValueKey('legal-${d.name}'),
                leadingMobile: d == LegalDoc.safety
                    ? null
                    : NumayaMobileIcons.legal,
                leading: d == LegalDoc.safety ? NumayaIcons.shield : null,
                label: legalDocTitle(l10n, d),
                onTap: () => context.push('${Routes.legal}/${d.name}'),
              ),
          ],
        ),
      ),
    );
  }
}

/// One document. The texts are drafts for review (PRD 04: retention and DPDP obligations need
/// legal validation before launch), and say so.
class LegalDocScreen extends StatelessWidget {
  const LegalDocScreen({super.key, required this.doc});

  final LegalDoc doc;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final body = switch (doc) {
      LegalDoc.privacy => [l10n.legalPrivacySummary],
      LegalDoc.terms => [l10n.legalTermsSummary],
      LegalDoc.community => [l10n.legalCommunitySummary],
      LegalDoc.safety => [
        l10n.legalSafetyIntro,
        l10n.legalSafetyEmergency,
        l10n.legalSafetyWomen,
        l10n.legalSafetyCyber,
        l10n.legalSafetyVerify,
      ],
    };
    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () => context.pop(),
        backLabel: l10n.back,
        title: legalDocTitle(l10n, doc),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s4),
          StatusBanner(title: l10n.legalDraft, body: l10n.legalPending),
          const SizedBox(height: AppSpacing.s4),
          for (final p in body) ...[
            Text(p, style: AppTypography.body),
            const SizedBox(height: AppSpacing.s3),
          ],
        ],
      ),
    );
  }
}

/// S43: support and appeal requests with their status. Demo requests are labelled as not sent.
class SupportRequestsScreen extends ConsumerWidget {
  const SupportRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tickets = ref.watch(supportTicketsProvider);
    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () => context.pop(),
        backLabel: l10n.back,
        title: l10n.supportRequestsTitle,
      ),
      footer: NumayaButton(
        label: l10n.supportNew,
        variant: NumayaButtonVariant.secondary,
        onPressed: () => context.push(Routes.helpContact),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.s4),
        child: tickets.isEmpty
            ? EmptyState(
                art: const NumayaIcon(
                  NumayaIcons.help,
                  size: 36,
                  color: AppColors.ink,
                ),
                title: l10n.supportRequestsEmpty,
                body: l10n.supportRequestsEmptyBody,
              )
            : ListGroup(
                children: [
                  for (final t in tickets.reversed)
                    ListRow(
                      label: '${t.id} · ${t.topic}',
                      detail:
                          '${l10n.supportStatusReceived} · ${shortDateTime(t.at)} · ${l10n.supportStatusDemo}',
                    ),
                ],
              ),
      ),
    );
  }
}
