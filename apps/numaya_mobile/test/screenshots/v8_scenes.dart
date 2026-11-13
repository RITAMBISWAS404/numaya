import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';

Future<void> _tapLabel(WidgetTester t, String label) async {
  await t.tap(find.bySemanticsLabel(RegExp('^${RegExp.escape(label)}')).first);
  await t.pump();
  await t.pump(const Duration(milliseconds: 700));
}

Future<void> _tapText(WidgetTester t, String text) async {
  await t.tap(find.text(text).last);
  await t.pump();
  await t.pump(const Duration(milliseconds: 700));
}

Future<void> _scrollLast(WidgetTester t, double dy) async {
  await t.drag(find.byType(Scrollable).last, Offset(0, -dy));
  await t.pump(const Duration(milliseconds: 500));
}

/// One V8 review render: a route in the full demo world with optional lab choices, typography,
/// Premium, a setup step (open a sheet, type) and a scroll offset.
class V8Scene {
  const V8Scene(
    this.id,
    this.route, {
    this.choices = const {},
    this.type = TypeSettings.baseline,
    this.premium = false,
    this.scroll = 0,
    this.height = 852,
    this.setup,
  });

  final String id;
  final String route;
  final Map<String, String> choices;
  final TypeSettings type;
  final bool premium;
  final double scroll;
  final double height;
  final Future<void> Function(WidgetTester tester, ProviderContainer c)? setup;
}

/// Representative screens for the shared-system passes (baseline evidence and iteration).
final List<V8Scene> v8Scenes = [
  const V8Scene('base-discover', Routes.home),
  const V8Scene('base-discover-more', Routes.home, scroll: 640),
  const V8Scene('base-likes', Routes.likes),
  const V8Scene('base-messages', Routes.messages),
  const V8Scene('base-archive', Routes.archive),
  const V8Scene('base-chat-priya', '${Routes.chat}/priya'),
  const V8Scene('base-chat-sam', '${Routes.chat}/sam'),
  const V8Scene('base-profile', Routes.profile),
  const V8Scene('base-profile-more', Routes.profile, scroll: 620),
  const V8Scene('base-settings', Routes.settings),
  const V8Scene('base-completion', Routes.completion),
  const V8Scene('base-wallet', Routes.wallet),
  const V8Scene('base-streak', Routes.streak),
  const V8Scene('base-premium', Routes.premium),
  const V8Scene('base-preview', Routes.preview),
  const V8Scene('base-edit-basics', Routes.editBasics),
  const V8Scene('base-setup-meet', Routes.setupMeet),
  const V8Scene('base-setup-prompts', Routes.setupPrompts),
  const V8Scene('base-setup-review', Routes.setupReview),
  V8Scene(
    'flow-filters-basic',
    Routes.home,
    setup: (t, c) => _tapLabel(t, 'Filters'),
  ),
  V8Scene(
    'flow-filters-basic-bottom',
    Routes.home,
    setup: (t, c) async {
      await _tapLabel(t, 'Filters');
      await _scrollLast(t, 700);
    },
  ),
  V8Scene(
    'flow-filters-advanced',
    Routes.home,
    setup: (t, c) async {
      await _tapLabel(t, 'Filters');
      await _tapText(t, 'Advanced');
    },
  ),
  const V8Scene('flow-match-maya', '${Routes.match}/maya'),
  const V8Scene('flow-like-profile', '${Routes.like}/noor'),
  const V8Scene('flow-likes-premium', Routes.likes, premium: true),
  V8Scene(
    'flow-photo-tips',
    Routes.photos,
    setup: (t, c) => _tapText(t, 'Photo tips'),
  ),
  const V8Scene('flow-setup-interests', Routes.interests),
  const V8Scene('flow-setup-height', Routes.setupHeight),
  const V8Scene('flow-setup-name', Routes.setupName),
  const V8Scene('flow-setup-verify', Routes.setupVerify),
  const V8Scene('flow-setup-done', Routes.setupDone),
  const V8Scene('flow-welcome', Routes.welcome),
  const V8Scene('base-typography', Routes.reviewTypography),
  const V8Scene(
    'base-typography-14',
    Routes.reviewTypography,
    type: TypeSettings(bodySize: 14),
  ),
];
