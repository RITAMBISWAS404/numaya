import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// Component cleanup (docs/design-experiments/overnight-polish/COMPONENT_CLEANUP.md).
void main() {
  setUpAll(loadAppFonts);

  Widget host(Widget child) => MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );

  BoxDecoration trackOf(WidgetTester tester) =>
      tester
              .widget<AnimatedContainer>(
                find.descendant(
                  of: find.byType(NumayaSwitch),
                  matching: find.byType(AnimatedContainer),
                ),
              )
              .decoration!
          as BoxDecoration;

  BoxDecoration thumbOf(WidgetTester tester) =>
      tester
              .widget<Container>(
                find.descendant(
                  of: find.byType(AnimatedAlign),
                  matching: find.byType(Container),
                ),
              )
              .decoration!
          as BoxDecoration;

  group('CL-01 switch states', () {
    testWidgets('on: purple track, white thumb, no outline', (tester) async {
      await tester.pumpWidget(
        host(NumayaSwitch(value: true, onChanged: (_) {})),
      );
      expect(trackOf(tester).color, AppColors.accent);
      expect(trackOf(tester).border, isNull);
      expect(thumbOf(tester).color, AppColors.surface);
      expect(find.byType(Opacity), findsNothing);
    });

    testWidgets('off: light-grey track, white thumb, no outline', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(NumayaSwitch(value: false, onChanged: (_) {})),
      );
      expect(trackOf(tester).color, AppColors.switchOff);
      expect(trackOf(tester).border, isNull);
      expect(thumbOf(tester).color, AppColors.surface);
    });

    testWidgets('disabled: same shape, dimmed', (tester) async {
      await tester.pumpWidget(
        host(const NumayaSwitch(value: true, onChanged: null)),
      );
      expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 0.45);
    });

    testWidgets('a switch row keeps toggled semantics and a full-row target', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      var on = false;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, set) => ListRow(
              label: 'Snooze',
              switchValue: on,
              onSwitch: (v) => set(() => on = v),
            ),
          ),
        ),
      );
      expect(
        tester.getSemantics(find.byType(ListRow)),
        isSemantics(
          label: 'Snooze',
          hasToggledState: true,
          isToggled: false,
          isButton: true,
        ),
      );
      // The whole row toggles, not only the 51pt track.
      await tester.tap(find.text('Snooze'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(on, isTrue);
      expect(
        tester.getSize(find.byType(ListRow)).height,
        greaterThanOrEqualTo(48),
      );
      handle.dispose();
    });
  });

  testWidgets('CL-03 tinted cards: a 1pt border in their own hue at 15%', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InfoCard(icon: NumayaIcons.info, title: 'Tip', body: 'Body.'),
            StatusBanner(
              title: 'Heads up',
              body: 'Body.',
              tone: BannerTone.error,
            ),
          ],
        ),
      ),
    );
    final decos = tester
        .widgetList<Container>(find.byType(Container))
        .map((c) => c.decoration)
        .whereType<BoxDecoration>()
        .where((d) => d.border != null)
        .toList();
    final borders = decos.map((d) => (d.border! as Border).top).toList();
    expect(borders, hasLength(greaterThanOrEqualTo(2)));
    for (final b in borders) {
      expect(b.width, 1);
      expect(b.color.a, closeTo(0.15, 0.01));
    }
  });

  group('CL-04 metadata separator', () {
    testWidgets(
      'a vertical bar, excluded from semantics, parts read in order',
      (tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(MetaText(MetaText.join(['Woman', 'Looking for long-term']))),
        );
        expect(find.text('·', findRichText: true), findsNothing);
        expect(
          find.bySemanticsLabel('Woman, Looking for long-term'),
          findsOneWidget,
        );
        // One 1pt separator bar between the two parts.
        final bars = find.descendant(
          of: find.byType(MetaText),
          matching: find.byWidgetPredicate(
            (w) => w is Container && w.constraints?.maxWidth == 1,
          ),
        );
        expect(bars, findsOneWidget);
        handle.dispose();
      },
    );

    testWidgets('the bar takes a separator colour on coloured surfaces', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          MetaText(
            MetaText.join(['Video', '2.4 MB']),
            separatorColor: AppColors.accentForeground,
          ),
        ),
      );
      final bar = tester.widget<Container>(
        find.descendant(
          of: find.byType(MetaText),
          matching: find.byWidgetPredicate(
            (w) => w is Container && w.constraints?.maxWidth == 1,
          ),
        ),
      );
      expect(bar.color, AppColors.accentForeground);
    });

    testWidgets('user text keeps its own punctuation', (tester) async {
      await tester.pumpWidget(
        host(const MetaText('Jazz · 2.5 km · tea, cake')),
      );
      // No joiner: rendered as-is, no separators added and nothing split.
      expect(find.text('Jazz · 2.5 km · tea, cake'), findsOneWidget);
    });
  });

  testWidgets('CL-06/07 chat: no composer tray and one demo notice', (
    tester,
  ) async {
    await usePhoneSize(tester);
    final c = await quickStartApp(tester);
    await goTo(c, tester, '${Routes.chat}/priya');
    final trays = find.descendant(
      of: find.byType(Composer),
      matching: find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration! as BoxDecoration).color == AppColors.surface,
      ),
    );
    expect(trays, findsNothing);
    expect(find.text('Sample conversation'), findsNothing);
    expect(find.textContaining('Demo chat:'), findsOneWidget);
    await settle(tester);
  });
}
