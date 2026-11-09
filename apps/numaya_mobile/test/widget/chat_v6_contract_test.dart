import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';
import 'package:numaya_mobile/features/auth/domain/country.dart';
import 'package:numaya_mobile/features/auth/presentation/country_sheet.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';
import 'package:numaya_mobile/features/dating/data/media_picker.dart';
import 'package:numaya_mobile/features/dating/data/voice_service.dart';
import 'package:numaya_mobile/l10n/generated/app_localizations.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// V6 messaging contract: composer controls, quoted replies, photos and voice notes.
void main() {
  setUpAll(loadAppFonts);

  const priya = '${Routes.chat}/priya';
  final mic = find.byKey(const ValueKey('chat-voice'));

  Future<ProviderContainer> open(WidgetTester tester) async {
    await usePhoneSize(tester);
    final c = await quickStartApp(
      tester,
      mediaPicker: const SampleMediaPicker(),
      overrides: [
        voiceRecorderFactoryProvider.overrideWithValue(DemoVoiceRecorder.new),
      ],
    );
    await goTo(c, tester, priya);
    await tester.pump(const Duration(milliseconds: 400));
    return c;
  }

  List<DemoMessage> thread(ProviderContainer c) =>
      c.read(datingProvider).threads['priya'] ?? const [];

  group('Composer', () {
    testWidgets('the microphone gives way to Send in the same place', (
      tester,
    ) async {
      await open(tester);
      expect(mic, findsOneWidget);
      final slot = tester.getRect(mic);
      await tester.enterText(find.byType(TextField).last, 'Hello');
      await tester.pump(const Duration(milliseconds: 300));
      expect(mic, findsNothing);
      final send = find.bySemanticsLabel('Send').last;
      expect(tester.getRect(send).right, closeTo(slot.right, 2));
      await settle(tester);
    });

    testWidgets('with attachments off there is no microphone', (tester) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester);
      await goTo(c, tester, priya);
      expect(mic, findsNothing);
      await settle(tester);
    });
  });

  group('Voice', () {
    testWidgets('discarding sends nothing', (tester) async {
      final c = await open(tester);
      final before = thread(c).length;
      await tester.tap(mic);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byKey(const ValueKey('voice-bar')), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      await tester.tap(find.byKey(const ValueKey('voice-discard')));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byKey(const ValueKey('voice-bar')), findsNothing);
      expect(thread(c).length, before);
      await settle(tester);
    });

    testWidgets('stop leads to a preview; Send adds exactly one note', (
      tester,
    ) async {
      final c = await open(tester);
      final before = thread(c).length;
      await tester.tap(mic);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(seconds: 3));
      await tester.tap(find.byKey(const ValueKey('voice-stop')));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byKey(const ValueKey('voice-send')), findsOneWidget);
      expect(find.text('0:03'), findsOneWidget);
      expect(thread(c).length, before);
      await tester.tap(find.byKey(const ValueKey('voice-send')));
      await tester.pump(const Duration(milliseconds: 600));
      expect(thread(c).length, before + 1);
      expect(thread(c).last.attachment?.kind, AttachmentKind.voice);
      expect(thread(c).last.attachment?.duration, const Duration(seconds: 3));
      await settle(tester);
    });

    testWidgets('under a second is refused and not kept', (tester) async {
      final c = await open(tester);
      final before = thread(c).length;
      await tester.tap(mic);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.byKey(const ValueKey('voice-stop')));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byKey(const ValueKey('voice-bar')), findsNothing);
      expect(thread(c).length, before);
      await settle(tester);
    });
  });

  group('Quoted reply', () {
    testWidgets('an original that no longer exists says so', (tester) async {
      final c = await open(tester);
      final dating = c.read(datingProvider.notifier);
      final original = thread(c).first.id;
      dating.send('priya', 'Still up for it?', replyToId: original).ignore();
      await tester.pump(const Duration(milliseconds: 600));
      dating.removeMessage('priya', original);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Original message unavailable'), findsOneWidget);
      await settle(tester);
    });
  });

  group('Country picker', () {
    Future<void> sheet(WidgetTester tester) async {
      await usePhoneSize(tester);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () =>
                    showCountrySheet(context, selected: kCountries.first),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    }

    testWidgets('the selected row is solid purple with no tick', (
      tester,
    ) async {
      await sheet(tester);
      final row = find.byKey(ValueKey('country-${kCountries.first.iso}'));
      final box = tester.widget<DecoratedBox>(
        find.descendant(of: row, matching: find.byType(DecoratedBox)).first,
      );
      expect((box.decoration as BoxDecoration).color, AppColors.accent);
      expect(
        find.descendant(of: row, matching: find.byType(NumayaIcon)),
        findsNothing,
      );
      final other = find.byKey(ValueKey('country-${kCountries[1].iso}'));
      final plain = tester.widget<DecoratedBox>(
        find.descendant(of: other, matching: find.byType(DecoratedBox)).first,
      );
      expect(
        (plain.decoration as BoxDecoration).color,
        isNot(AppColors.accent),
      );
    });

    testWidgets('high contrast adds a tick as a non-colour cue', (
      tester,
    ) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(highContrast: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await sheet(tester);
      final row = find.byKey(ValueKey('country-${kCountries.first.iso}'));
      expect(
        find.descendant(of: row, matching: find.byType(NumayaIcon)),
        findsOneWidget,
      );
    });
  });
}
