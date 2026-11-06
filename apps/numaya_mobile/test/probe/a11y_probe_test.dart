import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';
import 'package:numaya_mobile/features/experiments/experiments.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

// PROBE (V4, not committed as-is): Flutter accessibility guideline matchers per route.
void main() {
  setUpAll(loadAppFonts);
  final routes = <(String, String, DemoWorld, Experiment?, ExpVariant?)>[
    ('discover', Routes.home, DemoWorld.full, null, null),
    ('likes', Routes.likes, DemoWorld.full, null, null),
    ('messages', Routes.messages, DemoWorld.full, null, null),
    ('chat', '${Routes.chat}/priya', DemoWorld.full, null, null),
    ('profile', Routes.profile, DemoWorld.full, null, null),
    ('settings', Routes.settings, DemoWorld.full, null, null),
    ('match', '${Routes.match}/maya', DemoWorld.full, null, null),
    ('events', Routes.events, DemoWorld.full, null, null),
    ('completion', Routes.completion, DemoWorld.full, null, null),
    ('edit-profile', Routes.editProfile, DemoWorld.full, null, null),
    ('empty-messages', Routes.messages, DemoWorld.fresh, null, null),
    for (final e in Experiment.values)
      for (final v in [ExpVariant.a, ExpVariant.b, ExpVariant.c])
        (
          '${e.id}-${v.letter}',
          switch (e) {
            Experiment.matchMoment => '${Routes.match}/maya',
            Experiment.emptyChats => Routes.messages,
            _ => Routes.profile,
          },
          e == Experiment.emptyChats ? DemoWorld.fresh : DemoWorld.full,
          e,
          v,
        ),
  ];
  for (final (name, route, world, exp, v) in routes) {
    for (final g in [
      ('tap', androidTapTargetGuideline),
      ('label', labeledTapTargetGuideline),
      ('contrast', textContrastGuideline),
    ]) {
      testWidgets('probe $name ${g.$1}', (tester) async {
        tester.view.physicalSize = const Size(780, 1688);
        tester.view.devicePixelRatio = 2;
        addTearDown(tester.view.reset);
        final handle = tester.ensureSemantics();
        final c = await quickStartApp(tester, world: world);
        if (exp != null) {
          c.read(experimentChoicesProvider.notifier).choose(exp, v!);
        }
        await goTo(c, tester, route);
        await tester.pump(const Duration(seconds: 2));
        await expectLater(tester, meetsGuideline(g.$2));
        handle.dispose();
        await settle(tester);
      });
    }
  }
}
