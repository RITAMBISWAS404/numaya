import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../domain/help_articles.dart';

/// Help centre (F29, Mobbin "Get help article"): search, the articles, and a way to contact
/// support. Readable signed in or out.
class HelpCentreScreen extends StatefulWidget {
  const HelpCentreScreen({super.key});

  @override
  State<HelpCentreScreen> createState() => _HelpCentreScreenState();
}

class _HelpCentreScreenState extends State<HelpCentreScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final q = _query.trim().toLowerCase();
    final articles = kHelpArticles
        .where(
          (a) =>
              q.isEmpty ||
              a.title.toLowerCase().contains(q) ||
              a.sections.any(
                (s) =>
                    s.heading.toLowerCase().contains(q) ||
                    s.body.toLowerCase().contains(q),
              ),
        )
        .toList();
    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () => context.pop(),
        backLabel: l10n.back,
        title: l10n.helpTitle,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s4),
          NumayaSearchField(
            placeholder: l10n.helpSearch,
            clearLabel: l10n.close,
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: AppSpacing.s5),
          if (articles.isEmpty)
            EmptyState(
              art: const NumayaIcon(
                NumayaIcons.search,
                size: 36,
                color: AppColors.ink,
              ),
              title: l10n.searchEmptyTitle(_query.trim()),
              body: l10n.helpNoResults,
            )
          else
            ListGroup(
              title: l10n.helpTopics,
              children: [
                for (final a in articles)
                  ListRow(
                    label: a.title,
                    detail: a.summary,
                    onTap: () => context.push('${Routes.help}/${a.id.name}'),
                  ),
              ],
            ),
          const SizedBox(height: AppSpacing.sectionGap),
          ListGroup(
            title: l10n.helpStillStuck,
            children: [
              ListRow(
                leading: NumayaIcons.message,
                label: l10n.helpContact,
                onTap: () => context.push(Routes.helpContact),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One help article (B-58 long form).
class HelpArticleScreen extends StatelessWidget {
  const HelpArticleScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final articleId = HelpArticleId.values.where((a) => a.name == id);
    if (articleId.isEmpty) {
      return NumayaScreen(
        top: NumayaTopBar(onBack: () => context.pop(), backLabel: l10n.back),
        body: EmptyState(
          title: l10n.notFoundTitle,
          body: l10n.helpMissing,
          action: NumayaButton(
            label: l10n.helpTitle,
            small: true,
            onPressed: () => context.pushReplacement(Routes.help),
          ),
        ),
      );
    }
    final article = helpArticle(articleId.first);
    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () => context.pop(),
        backLabel: l10n.back,
        title: l10n.helpTitle,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s4),
          Semantics(
            header: true,
            child: Text(article.title, style: AppTypography.pageTitle),
          ),
          const SizedBox(height: AppSpacing.s2),
          Text(
            article.summary,
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          for (final s in article.sections) ...[
            const SizedBox(height: AppSpacing.s5),
            Semantics(
              header: true,
              child: Text(
                s.heading,
                style: AppTypography.weight(
                  AppTypography.row,
                  AppTypography.semibold,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s2),
            Text(s.body, style: AppTypography.body),
          ],
          const SizedBox(height: AppSpacing.sectionGap),
          ListGroup(
            children: [
              ListRow(
                leading: NumayaIcons.message,
                label: l10n.helpContact,
                onTap: () => context.push(Routes.helpContact),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Contact support: a topic and a message. Nothing is sent in this build, and the result says so.
class ContactSupportScreen extends StatefulWidget {
  const ContactSupportScreen({super.key});

  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen> {
  final _text = TextEditingController();
  String? _topic;
  bool _sent = false;

  @override
  void initState() {
    super.initState();
    _text.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final topics = [
      l10n.contactTopicAccount,
      l10n.contactTopicSafety,
      l10n.contactTopicVerification,
      l10n.contactTopicBilling,
      l10n.contactTopicOther,
    ];
    if (_sent) {
      return NumayaScreen(
        top: NumayaTopBar(onBack: () => context.pop(), backLabel: l10n.back),
        footer: NumayaButton(label: l10n.done, onPressed: () => context.pop()),
        body: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.s10),
          child: ResultPanel(
            illustration: NumayaIllustration.hello,
            title: l10n.contactSentTitle,
            body: l10n.contactSentBody,
          ),
        ),
      );
    }
    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () => context.pop(),
        backLabel: l10n.back,
        title: l10n.helpContact,
      ),
      footer: NumayaButton(
        label: l10n.contactSend,
        onPressed: _topic == null || _text.text.trim().isEmpty
            ? null
            : () => setState(() => _sent = true),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s4),
          OptionGroup(
            legend: l10n.contactTopic,
            children: [
              for (final t in topics)
                OptionCard(
                  label: t,
                  selected: _topic == t,
                  onTap: () => setState(() => _topic = t),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.fieldGap),
          NumayaTextField(
            label: l10n.contactMessage,
            controller: _text,
            multiline: true,
            maxLength: 500,
            textCapitalization: TextCapitalization.sentences,
            trailingNote: l10n.promptCharsLeft(500 - _text.text.length),
          ),
          const SizedBox(height: AppSpacing.s3),
          Text(l10n.contactDemoNote, style: AppTypography.caption),
        ],
      ),
    );
  }
}

/// Safety and wellbeing (B-23 tab): tips, and the tools that already exist (block list, reporting,
/// verification, snooze), each one tap away.
class SafetyCentreScreen extends StatelessWidget {
  const SafetyCentreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return NumayaScreen(
      top: NumayaTopBar(
        onBack: () => context.pop(),
        backLabel: l10n.back,
        title: l10n.safetyTitle,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s4),
          ScreenHeader(title: l10n.safetyHeading, lede: l10n.safetyLede),
          const SizedBox(height: AppSpacing.s5),
          InfoCard(
            icon: NumayaIcons.shield,
            title: l10n.safetyTip1Title,
            body: l10n.safetyTip1Body,
          ),
          const SizedBox(height: AppSpacing.s3),
          InfoCard(
            icon: NumayaIcons.event,
            title: l10n.safetyTip2Title,
            body: l10n.safetyTip2Body,
          ),
          const SizedBox(height: AppSpacing.s3),
          InfoCard(
            icon: NumayaIcons.flag,
            title: l10n.safetyTip3Title,
            body: l10n.safetyTip3Body,
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          ListGroup(
            title: l10n.safetyTools,
            children: [
              ListRow(
                leading: NumayaIcons.verified,
                label: l10n.editVerify,
                onTap: () => context.push(Routes.verifyPhoto),
              ),
              ListRow(
                leading: NumayaIcons.block,
                label: l10n.settingsBlocked,
                onTap: () => context.push(Routes.blocked),
              ),
              ListRow(
                leading: NumayaIcons.flag,
                label: helpArticle(HelpArticleId.reporting).title,
                onTap: () => context.push(
                  '${Routes.help}/${HelpArticleId.reporting.name}',
                ),
              ),
              ListRow(
                leading: NumayaIcons.event,
                label: helpArticle(HelpArticleId.safetyTips).title,
                onTap: () => context.push(
                  '${Routes.help}/${HelpArticleId.safetyTips.name}',
                ),
              ),
              ListRow(
                leading: NumayaIcons.clock,
                label: helpArticle(HelpArticleId.snooze).title,
                onTap: () =>
                    context.push('${Routes.help}/${HelpArticleId.snooze.name}'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
