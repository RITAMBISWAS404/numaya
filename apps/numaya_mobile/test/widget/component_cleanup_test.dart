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
    testWidgets('on: purple track, white thumb, no visible outline', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(NumayaSwitch(value: true, onChanged: (_) {})),
      );
      expect(trackOf(tester).color, AppColors.accent);
      // The 1pt edge is kept in both states (stable geometry) and matches the track when on.
      final edge = (trackOf(tester).border! as Border).top;
      expect(edge.color, AppColors.accent);
      expect(thumbOf(tester).color, AppColors.surface);
      expect(find.byType(Opacity), findsNothing);
    });

    testWidgets(
      'off: light fill track with a 3:1 control-grey edge, plain white thumb (FT-04)',
      (tester) async {
        await tester.pumpWidget(
          host(NumayaSwitch(value: false, onChanged: (_) {})),
        );
        // FT-04 (2026-11-07): Ente 2482:6644 specifies a fill/dark track for Selected=False.
        // The light track alone is under 3:1, so a 1pt control-grey edge keeps the boundary at
        // 3:1 against the white card and the grey page.
        final track = trackOf(tester).color!;
        expect(track, AppColors.switchOff);
        expect(track, AppColors.fill);
        final edge = (trackOf(tester).border! as Border).top;
        expect(edge.color, AppColors.switchOffEdge);
        expect(edge.width, 1);
        double ratio(Color a, Color b) {
          final la = a.computeLuminance(), lb = b.computeLuminance();
          return ((la > lb ? la : lb) + 0.05) / ((la > lb ? lb : la) + 0.05);
        }

        expect(ratio(edge.color, AppColors.surface), greaterThanOrEqualTo(3));
        expect(ratio(edge.color, AppColors.canvas), greaterThanOrEqualTo(3));
        // Lighter than the UC-01 track it replaces.
        expect(
          track.computeLuminance(),
          greaterThan(AppColors.outline.computeLuminance()),
        );
        final thumb = thumbOf(tester);
        expect(thumb.color, AppColors.surface);
        expect(thumb.border, isNull);
        expect(thumb.boxShadow, isNotEmpty);
      },
    );

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

  testWidgets('OV-01 alerts are Ente banners: white, no tint or border, the '
      'status in the icon and (for errors) the title', (tester) async {
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
    final cards = tester
        .widgetList<Container>(find.byType(Container))
        .map((c) => c.decoration)
        .whereType<BoxDecoration>()
        .where((d) => d.borderRadius == AppRadii.all(AppRadii.card))
        .toList();
    expect(cards, hasLength(2));
    for (final d in cards) {
      expect(d.color, AppColors.surface);
      expect(d.border, isNull);
    }
    final infoIcon = tester.widget<NumayaIcon>(
      find.byWidgetPredicate(
        (w) => w is NumayaIcon && w.icon == NumayaIcons.info,
      ),
    );
    expect(infoIcon.color, AppColors.accent);
    expect(
      tester.widget<Text>(find.text('Heads up')).style!.color,
      AppColors.negative,
    );
    expect(
      tester.widget<Text>(find.text('Body.').first).style!.color,
      AppColors.textMuted,
    );
    // Tabler MVP pass (supersedes UI-010): the icon is centred on the content (title and body)
    // and drawn with Tabler's filled artwork.
    expect(infoIcon.filled, isTrue);
    final contentMid =
        (tester.getTopLeft(find.text('Tip')).dy +
            tester.getBottomLeft(find.text('Body.').first).dy) /
        2;
    expect(
      tester.getCenter(find.byWidget(infoIcon)).dy,
      closeTo(contentMid, 1),
    );
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

  testWidgets('CL-06/07, UI-038/041 chat: one composer bar, no demo notice', (
    tester,
  ) async {
    await usePhoneSize(tester);
    final c = await quickStartApp(tester);
    await goTo(c, tester, '${Routes.chat}/priya');
    // UI-038: the composer is one white bar (chat_review3_test checks it edge to edge); inside
    // it, the field is the light fill with no idle stroke (UI-037) and no second white tray.
    final whites = find.descendant(
      of: find.byType(Composer),
      matching: find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration! as BoxDecoration).color == AppColors.surface,
      ),
    );
    expect(whites, findsNothing);
    final field = find.descendant(
      of: find.byType(Composer),
      matching: find.byWidgetPredicate(
        (w) =>
            w is AnimatedContainer &&
            w.decoration is BoxDecoration &&
            (w.decoration! as BoxDecoration).color == AppColors.fill,
      ),
    );
    expect(
      find.descendant(of: field, matching: find.byType(TextField)),
      findsOneWidget,
    );
    expect(find.text('Sample conversation'), findsNothing);
    expect(find.textContaining('Demo: '), findsNothing); // UI-041
    await settle(tester);
  });
}
