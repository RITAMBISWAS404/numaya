import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// Review batch 3, Chat: UI-035 (left swipe reveals the time), UI-036 (right swipe replies),
/// UI-038 (one white composer bar), UI-039 (up-arrow Send), UI-040 (bubble colours), UI-041 (no
/// demo footer).
/// The swipe-reveal time, not the one printed inside the bubble.
Finder _reveal(String time) =>
    find
        .descendant(
          of: find.byType(SwipeableMessage),
          matching: find.byWidgetPredicate((w) => w is Text && w.data == time),
        )
        .evaluate()
        .isEmpty
    ? find.text(time)
    : _outsideBubble(time);

Finder _outsideBubble(String time) => find.byElementPredicate(
  (e) =>
      e.widget is Text &&
      (e.widget as Text).data == time &&
      e.findAncestorWidgetOfExactType<MessageBubble>() == null,
  description: 'reveal $time',
);

void main() {
  setUpAll(loadAppFonts);

  Future<ProviderContainer> openPriya(WidgetTester tester) async {
    await usePhoneSize(tester);
    final c = await quickStartApp(tester);
    await goTo(c, tester, '${Routes.chat}/priya');
    return c;
  }

  List<DemoMessage> thread(ProviderContainer c) =>
      c.read(datingProvider).threads['priya']!;

  /// The opacity of the revealed time for a message, or null when it is not built.
  double timeOpacity(WidgetTester tester, String time) {
    final f = find.ancestor(of: _reveal(time), matching: find.byType(Opacity));
    return tester.widget<Opacity>(f.first).opacity;
  }

  group('UI-035 exact times', () {
    testWidgets(
      'V8 review (UI-035): no bubble shows its time at rest; the day line stays',
      (tester) async {
        await openPriya(tester);
        expect(find.text('Today'), findsOneWidget);
        for (final t in ['07:00', '10:26']) {
          expect(
            find.descendant(
              of: find.byType(MessageBubble),
              matching: find.text(t),
            ),
            findsNothing,
            reason: t,
          );
        }
        // The separate swipe reveal stays hidden at rest.
        for (final t in ['07:00', '10:26']) {
          for (final e in _reveal(t).evaluate()) {
            final o = tester.widget<Opacity>(
              find
                  .ancestor(
                    of: find.byWidget(e.widget),
                    matching: find.byType(Opacity),
                  )
                  .first,
            );
            expect(o.opacity, 0, reason: t);
          }
        }
        await settle(tester);
      },
    );

    testWidgets('a left drag reveals that message’s time; release hides it', (
      tester,
    ) async {
      await openPriya(tester);
      final mine = find.text('That bakery on Columbia Road, right?');
      final g = await tester.startGesture(tester.getCenter(mine));
      await g.moveBy(const Offset(-20, 0));
      await g.moveBy(const Offset(-60, 0));
      await tester.pump();
      expect(timeOpacity(tester, '07:00'), 1);
      // Bounded: the bubble moved, but no further than the reveal allows.
      final moved = tester.getCenter(mine).dx;
      await g.up();
      await tester.pumpAndSettle();
      expect(timeOpacity(tester, '07:00'), 0);
      expect(tester.getCenter(mine).dx, greaterThan(moved));
      expect(
        tester.getCenter(mine).dx - moved,
        lessThanOrEqualTo(SwipeableMessage.maxLeft),
      );
      // No reply was started by the opposite gesture.
      expect(find.textContaining('Replying to'), findsNothing);
      await settle(tester);
    });

    testWidgets('long press offers Show time without a precise swipe', (
      tester,
    ) async {
      await openPriya(tester);
      await tester.longPress(find.text('Have you been?'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Show time'));
      await tester.pumpAndSettle();
      // Both Priya messages were sent at 10:26; the one long-pressed is pinned open.
      final shown = _reveal('10:26').evaluate().where((e) {
        final o = tester.widget<Opacity>(
          find
              .ancestor(
                of: find.byWidget(e.widget),
                matching: find.byType(Opacity),
              )
              .first,
        );
        return o.opacity == 1;
      });
      expect(shown, hasLength(1));
      await settle(tester);
    });
  });

  group('UI-036 swipe to reply', () {
    testWidgets('a right swipe replies to exactly that message', (
      tester,
    ) async {
      final c = await openPriya(tester);
      final target = thread(c).firstWhere((m) => m.text == 'Have you been?');
      await tester.drag(
        find.text('Have you been?'),
        const Offset(SwipeableMessage.replyThreshold + 20, 0),
      );
      await tester.pumpAndSettle();
      expect(find.text('Replying to Priya'), findsOneWidget);
      // The bubble sprang back to its resting place.
      expect(
        tester.getTopLeft(find.text('Have you been?').first).dx,
        lessThan(AppLayout.screenGutter + 40),
      );
      await tester.enterText(find.byType(TextField), 'Not yet!');
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Send'));
      await tester.pump(const Duration(milliseconds: 600));
      final sent = thread(c).last;
      expect(sent.text, 'Not yet!');
      expect(sent.replyToId, target.id);
      expect(find.text('Replying to Priya'), findsNothing);
      // The new bubble quotes the message it answers.
      expect(
        find.descendant(
          of: find.ancestor(
            of: find.text('Not yet!'),
            matching: find.byType(MessageBubble),
          ),
          matching: find.text('Have you been?'),
        ),
        findsOneWidget,
      );
      await settle(tester);
    });

    testWidgets('a short or vertical drag does not start a reply', (
      tester,
    ) async {
      await openPriya(tester);
      await tester.drag(find.text('Have you been?'), const Offset(24, 0));
      await tester.pumpAndSettle();
      await tester.drag(find.text('Have you been?'), const Offset(4, -200));
      await tester.pumpAndSettle();
      expect(find.textContaining('Replying to'), findsNothing);
      await settle(tester);
    });

    testWidgets('cancel clears the reply; the next message is ordinary', (
      tester,
    ) async {
      final c = await openPriya(tester);
      await tester.drag(
        find.text('That bakery on Columbia Road, right?'),
        const Offset(90, 0),
      );
      await tester.pumpAndSettle();
      expect(find.text('Replying to yourself'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Cancel reply'));
      await tester.pump();
      expect(find.textContaining('Replying to'), findsNothing);
      await tester.enterText(find.byType(TextField), 'Plain');
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Send'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(thread(c).last.replyToId, isNull);
      await settle(tester);
    });

    testWidgets('changing the target replaces it; double Send sends once', (
      tester,
    ) async {
      final c = await openPriya(tester);
      final before = thread(c).length;
      await tester.drag(find.text('Have you been?'), const Offset(90, 0));
      await tester.pumpAndSettle();
      await tester.drag(
        find.text('Yes! The cardamom buns sell out by ten.'),
        const Offset(90, 0),
      );
      await tester.pumpAndSettle();
      expect(find.text('Replying to Priya'), findsOneWidget);
      final target = thread(c)
          .firstWhere((m) => m.text.startsWith('Yes! The cardamom'));
      await tester.enterText(find.byType(TextField), 'They do!');
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Send'));
      await tester.tap(find.bySemanticsLabel('Send'), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 600));
      expect(thread(c).length, before + 1);
      expect(thread(c).last.replyToId, target.id);
      await settle(tester);
    });

    testWidgets('screen readers get Reply as an action', (tester) async {
      final handle = tester.ensureSemantics();
      await openPriya(tester);
      final node = tester.getSemantics(
        find.ancestor(
          of: find.text('Have you been?'),
          matching: find.byType(SwipeableMessage),
        ),
      );
      final actions = node.getSemanticsData().customSemanticsActionIds ?? [];
      expect(actions, isNotEmpty);
      handle.dispose();
      await settle(tester);
    });
  });

  testWidgets(
    'UI-038/039/040/041: one white bar, up-arrow Send, white incoming '
    'bubbles, no demo footer',
    (tester) async {
      await openPriya(tester);
      final bar = find.byKey(const ValueKey('chat-composer-bar'));
      expect(tester.widget<ColoredBox>(bar).color, AppColors.surface);
      // Edge to edge, with the field and Send inside it. MVP PRD: text and emoji only, so no Plus.
      expect(
        tester.getSize(bar).width,
        tester.view.physicalSize.width / tester.view.devicePixelRatio,
      );
      expect(find.bySemanticsLabel('Add a photo'), findsNothing);
      for (final f in [find.byType(TextField), find.bySemanticsLabel('Send')]) {
        expect(find.descendant(of: bar, matching: f), findsWidgets);
      }
      final icons = tester
          .widgetList<NumayaIcon>(
            find.descendant(of: bar, matching: find.byType(NumayaIcon)),
          )
          .map((i) => i.icon);
      expect(icons, contains(NumayaIcons.arrowUp));
      expect(icons, isNot(contains(NumayaIcons.send)));
      // Bubble fills: theirs white, yours purple.
      Color fill(String text) =>
          (tester
                      .widget<Container>(
                        find
                            .ancestor(
                              of: find.text(text),
                              matching: find.byType(Container),
                            )
                            .first,
                      )
                      .decoration!
                  as BoxDecoration)
              .color!;
      expect(fill('Have you been?'), AppColors.surface);
      expect(fill('That bakery on Columbia Road, right?'), AppColors.accent);
      expect(find.textContaining('scripted'), findsNothing);
      expect(find.textContaining('leaves this device'), findsNothing);
      await settle(tester);
    },
  );

  testWidgets(
    'UI-037: the idle composer field has no stroke; focus adds the purple edge',
    (tester) async {
      await openPriya(tester);
      BoxBorder? edge() =>
          (tester
                      .widget<AnimatedContainer>(
                        find
                            .ancestor(
                              of: find.byType(TextField),
                              matching: find.byType(AnimatedContainer),
                            )
                            .first,
                      )
                      .decoration!
                  as BoxDecoration)
              .border;
      expect((edge()! as Border).top.color.a, 0);
      await tester.tap(find.byType(TextField));
      await tester.pump(const Duration(milliseconds: 400));
      expect((edge()! as Border).top.color, AppColors.focusField);
      await settle(tester);
    },
  );
}
