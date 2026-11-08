import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';
import 'package:numaya_mobile/core/design_system/tokens/monochrome_tokens.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';
import 'package:numaya_mobile/features/lab/lab_registry.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// Overnight polish (docs/design-experiments/overnight-polish/): the 14/20 body (OP-01), its role
/// exceptions (OP-02, OP-03), the large-text layout fixes (OP-04), the glass highlight (OP-05) and
/// the mascot (OP-06).
void main() {
  setUpAll(loadAppFonts);

  Future<void> largeText(WidgetTester tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }

  group('OP-01 to OP-03: type roles', () {
    test('the semantic body is 15/20 (X15); rows and typing match it', () {
      expect(MonoType.scale, 'body14');
      expect(AppTypography.body.fontSize, 15);
      expect(AppTypography.body.height! * 15, closeTo(20, 0.001));
      // Ente experiment: Menu Item titles and Text Input values are Body 14/20.
      expect(AppTypography.row.fontSize, 15);
      expect(AppTypography.input.fontSize, 15);
    });

    testWidgets('option rows use the row role, not the reading body', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptionCard(
              label: 'Fake profile',
              selected: false,
              onTap: () {},
            ),
          ),
        ),
      );
      final text = tester.widget<Text>(find.text('Fake profile'));
      expect(text.style?.fontSize, AppTypography.row.fontSize);
    });
  });

  group('OP-04: large text on a 320pt phone', () {
    testWidgets('R12: the large title is not truncated at 200% text', (
      tester,
    ) async {
      await usePhoneSize(tester, size: const Size(320, 693));
      await largeText(tester);
      final c = await quickStartApp(tester);
      await goTo(c, tester, Routes.profile);
      final title = find.byKey(const ValueKey('large-title'));
      expect(title, findsOneWidget);
      expect(tester.widget<Text>(title).style?.fontSize, 30);
      final painter = TextPainter(
        text: TextSpan(
          text: 'Profile',
          style: tester.widget<Text>(title).style,
        ),
        textScaler: const TextScaler.linear(2),
        textDirection: TextDirection.ltr,
      )..layout();
      expect(painter.width, lessThanOrEqualTo(tester.getSize(title).width));
      await settle(tester);
    });

    testWidgets('the Profile hero puts the avatar above the name', (
      tester,
    ) async {
      await usePhoneSize(tester, size: const Size(320, 693));
      await largeText(tester);
      final c = await quickStartApp(tester);
      await goTo(c, tester, Routes.profile);
      final name = find.textContaining('Alex');
      final avatarBottom = tester.getBottomLeft(find.text('A').first).dy;
      expect(tester.getTopLeft(name.first).dy, greaterThan(avatarBottom));
      await settle(tester);
    });

    testWidgets('at 100% text the photo is centred above the name (UI-042)', (
      tester,
    ) async {
      await usePhoneSize(tester, size: const Size(390, 844));
      final c = await quickStartApp(tester);
      // Pins the O profile header this test describes (owner picked A; see visual_lab_v2).
      c.read(labChoicesProvider.notifier).choose('profile-header', 'O');
      await goTo(c, tester, Routes.profile);
      final name = tester.getRect(find.textContaining('Alex').first);
      final photo = tester.getRect(find.text('A').first);
      expect(name.top, greaterThan(photo.bottom));
      expect(photo.center.dx, closeTo(name.center.dx, 1));
      await settle(tester);
    });
  });

  group('OP-05: glass highlight', () {
    Finder highlight() => find.byWidgetPredicate(
      (w) => w is ColoredBox && w.color == MonoGlass.highlight,
    );

    testWidgets('the frosted bar draws one top highlight', (tester) async {
      // Ente experiment: the frosted bar is a comparison surface, no longer the app default.
      await usePhoneSize(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: NumayaTabBar(
              surface: TabBarSurface.frosted,
              currentIndex: 0,
              onSelect: (_) {},
              items: const [
                TabItem(label: 'Home', icon: NumayaIcons.home),
                TabItem(label: 'Profile', icon: NumayaIcons.user),
              ],
            ),
          ),
        ),
      );
      expect(
        find.descendant(of: find.byType(NumayaTabBar), matching: highlight()),
        findsOneWidget,
      );
    });

    testWidgets('High Contrast drops the glass and its highlight', (
      tester,
    ) async {
      await usePhoneSize(tester);
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(highContrast: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await quickStartApp(tester);
      expect(highlight(), findsNothing);
      expect(find.byType(BackdropFilter), findsNothing);
      await settle(tester);
    });
  });

  testWidgets('OP-06: a like that moved on shows the mascot', (tester) async {
    await usePhoneSize(tester);
    final c = await quickStartApp(tester);
    await goTo(c, tester, '${Routes.like}/nobody');
    final art = find.byWidgetPredicate(
      (w) =>
          w is IllustrationView &&
          w.illustration == NumayaIllustration.mascotWaiting,
    );
    expect(art, findsOneWidget);
    // Decorative: the title and body carry the meaning.
    expect(
      find.descendant(of: art, matching: find.byType(ExcludeSemantics)),
      findsWidgets,
    );
    await settle(tester);
  });

  group('route gaps: routes no other test opened', () {
    const routes = [
      Routes.editBasics,
      Routes.editInterests,
      Routes.editPhotos,
      Routes.editPrompt,
      '${Routes.editPrompt}?slot=2',
      Routes.restore,
      Routes.reauth,
    ];
    for (final (size, text) in const [
      (Size(320, 693), 2.0),
      (Size(390, 844), 1.0),
    ]) {
      testWidgets(
        'lay out at ${size.width.toInt()}pt with ${(text * 100).toInt()}% text',
        (tester) async {
          await usePhoneSize(tester, size: size);
          tester.platformDispatcher.textScaleFactorTestValue = text;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          final c = await quickStartApp(tester);
          for (final r in routes) {
            await goTo(c, tester, r);
            expect(tester.takeException(), isNull, reason: r);
          }
          await settle(tester);
        },
      );
    }
  });

  group('final QA regressions', () {
    testWidgets('a long value with a detail stacks under the label (p05)', (
      tester,
    ) async {
      await usePhoneSize(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListGroup(
              children: [
                ListRow(
                  label: 'Recovery email',
                  detail: 'Not verified: no email service in this build',
                  value: 'alex.longname@example.com',
                  onTap: () {},
                ),
                ListRow(
                  label: 'Current location',
                  value: 'Not set',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      );
      final label = tester.getRect(find.text('Recovery email'));
      final value = tester.getRect(find.text('alex.longname@example.com'));
      // Stacked: the value starts where the label starts, on a lower line.
      expect(value.left, label.left);
      expect(value.top, greaterThan(label.bottom - 1));
      // The label keeps one line (it had wrapped to "Recovery / email").
      expect(label.height, lessThan(30));
      // A short value without a detail stays trailing.
      expect(
        tester.getRect(find.text('Not set')).left,
        greaterThan(tester.getRect(find.text('Current location')).right),
      );
    });

    testWidgets('a rapid double tap on Send sends one message', (tester) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester);
      await goTo(c, tester, '${Routes.chat}/priya');
      final before = c.read(datingProvider).threads['priya']?.length ?? 0;
      await tester.enterText(find.byType(TextField), 'Sunday market?');
      await tester.pump();
      final send = find.bySemanticsLabel('Send');
      await tester.tap(send.last);
      await tester.tap(send.last, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 600));
      expect(c.read(datingProvider).threads['priya']!.length, before + 1);
      await settle(tester);
    });

    testWidgets('the Design Lab dates its sample event from the app clock', (
      tester,
    ) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester);
      await goTo(c, tester, Routes.designLab);
      // testNow is Tue 27 Oct 2026; the Lab no longer reads the wall clock.
      // R07: sentence case, no upper-cased date eyebrow.
      expect(find.textContaining('Tue 27 Oct'), findsWidgets);
      await settle(tester);
    });

    testWidgets('keyboard over a tab screen: the search field stays visible', (
      tester,
    ) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester);
      await goTo(c, tester, Routes.messages);
      await tester.tap(
        find.bySemanticsLabel('Search names and messages').first,
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.byType(TextField).first);
      // A 300pt keyboard (physical pixels at 3x).
      tester.view.viewInsets = const FakeViewPadding(bottom: 900);
      addTearDown(tester.view.resetViewInsets);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull);
      final field = tester.getRect(find.byType(TextField).first);
      expect(field.bottom, lessThanOrEqualTo(852 - 300));
      await settle(tester);
    });
  });
}
