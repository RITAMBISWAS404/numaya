import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/connectivity/connectivity.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';
import 'package:numaya_mobile/features/auth/application/session_expiry.dart';
import 'package:numaya_mobile/features/dating/data/media_picker.dart';
import 'package:numaya_mobile/features/dating/presentation/chat_attachments.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// The surfaces added in the complete-product and overnight passes at a small phone (320 × 568),
/// large text and with the keyboard up. Any overflow fails the test; the controls a person needs
/// must stay above the keyboard.
const _small = Size(320, 568);
const _keyboard = 260.0;

Future<void> _setUp(WidgetTester tester, {double text = 2}) async {
  tester.view.physicalSize = _small * 2;
  tester.view.devicePixelRatio = 2;
  tester.platformDispatcher.textScaleFactorTestValue = text;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

void _keyboardUp(WidgetTester tester) =>
    tester.view.viewInsets = const FakeViewPadding(bottom: _keyboard * 2);

/// [f]'s bottom edge is above the keyboard.
void _aboveKeyboard(WidgetTester tester, Finder f) {
  expect(
    tester.getRect(f.last).bottom,
    lessThanOrEqualTo(_small.height - _keyboard + 0.5),
  );
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('chat: pending photo, long caption, keyboard up, 2x text', (
    tester,
  ) async {
    await _setUp(tester);
    final c = await quickStartApp(
      tester,
      overrides: [
        mediaPickerProvider.overrideWithValue(const SampleMediaPicker()),
      ],
    );
    await goTo(c, tester, '${Routes.chat}/priya');
    await tapOn(
      tester,
      find.bySemanticsLabel('Add a photo, video or voice note'),
    );
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.text('Photo').last);
    await tester.pump(const Duration(seconds: 1));
    _keyboardUp(tester);
    await tester.enterText(
      find.byType(TextField),
      'A very long caption about the flower stall on Columbia Road that keeps going '
      'well past one line so the composer has to grow.',
    );
    await tester.pump(const Duration(milliseconds: 600));
    expect(tester.takeException(), isNull);
    _aboveKeyboard(tester, find.byType(Composer));
    _aboveKeyboard(tester, find.bySemanticsLabel('Remove attachment'));
    await tapOn(tester, find.bySemanticsLabel('Send'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(AttachmentMessage), findsOneWidget);
    expect(tester.takeException(), isNull);
    await settle(tester);
  });

  testWidgets(
    'recovery email and Share Date sheets with the keyboard up, 1.5x text',
    (tester) async {
      await _setUp(tester, text: 1.5);
      final c = await quickStartApp(tester);
      await goTo(c, tester, Routes.settings);
      await tapOn(tester, find.text('Recovery email'));
      await tester.pump(const Duration(milliseconds: 600));
      _keyboardUp(tester);
      await tester.enterText(find.byType(TextField), 'not-an-email');
      await tester.pump(const Duration(milliseconds: 600));
      await tester.ensureVisible(find.widgetWithText(NumayaButton, 'Save'));
      await tester.pump();
      _aboveKeyboard(tester, find.widgetWithText(NumayaButton, 'Save'));
      await tester.tap(find.widgetWithText(NumayaButton, 'Save'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        find.text('Enter an email address like name@example.com'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      tester.view.resetViewInsets();
      await tester.binding.handlePopRoute();
      await tester.pump(const Duration(seconds: 1));

      await goTo(c, tester, '${Routes.chat}/sasha');
      await tapOn(tester, find.bySemanticsLabel('Conversation options'));
      await tester.pump(const Duration(milliseconds: 600));
      // Six actions fit or scroll; none overflows.
      expect(tester.takeException(), isNull);
      await tapOn(tester, find.text('Share date details'));
      await tester.pump(const Duration(milliseconds: 600));
      _keyboardUp(tester);
      Finder field(int i) => find.descendant(
        of: find.byType(NumayaTextField).at(i),
        matching: find.byType(TextField),
      );
      await tester.enterText(
        field(0),
        'The Royal Vauxhall Tavern, Kennington Lane',
      );
      await tester.enterText(field(1), 'Saturday 14th, around half past seven');
      await tester.pump(const Duration(milliseconds: 600));
      await tester.ensureVisible(find.widgetWithText(NumayaButton, 'Share'));
      await tester.pump();
      _aboveKeyboard(tester, find.widgetWithText(NumayaButton, 'Share'));
      expect(tester.takeException(), isNull);
      await settle(tester);
    },
  );

  testWidgets('sign in again with the code and keyboard, 2x text', (
    tester,
  ) async {
    await _setUp(tester);
    final c = await quickStartApp(tester);
    c.read(sessionExpiryProvider.notifier).expire();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tapOn(tester, find.widgetWithText(NumayaButton, 'Send code'));
    await tester.pump(const Duration(milliseconds: 600));
    _keyboardUp(tester);
    await tester.pump(const Duration(milliseconds: 600));
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.byType(CodeInput));
    await tester.pump();
    _aboveKeyboard(tester, find.byType(CodeInput));
    await settle(tester);
  });

  testWidgets('offline banner over Home and a chat, 2x text', (tester) async {
    await _setUp(tester);
    final c = await quickStartApp(tester);
    c.read(connectivityProvider.notifier).setOnline(false);
    await tester.pump(const Duration(milliseconds: 600));
    expect(tester.takeException(), isNull);
    await goTo(c, tester, '${Routes.chat}/priya');
    await tester.pump(const Duration(milliseconds: 600));
    expect(tester.takeException(), isNull);
    // The banner never covers the chat header.
    expect(
      tester.getRect(find.byType(ConnectionBanner)).bottom,
      lessThanOrEqualTo(
        tester.getRect(find.bySemanticsLabel('Back to messages').last).top,
      ),
    );
    await settle(tester);
  });
}
