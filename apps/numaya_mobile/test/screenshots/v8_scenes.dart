import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';

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
  const V8Scene('base-typography', Routes.reviewTypography),
  const V8Scene(
    'base-typography-14',
    Routes.reviewTypography,
    type: TypeSettings(bodySize: 14),
  ),
];
