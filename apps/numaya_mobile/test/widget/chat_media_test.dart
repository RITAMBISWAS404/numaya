import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/connectivity/connectivity.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';
import 'package:numaya_mobile/features/dating/data/media_picker.dart';
import 'package:numaya_mobile/features/dating/presentation/chat_attachments.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// A picker that returns [result] or throws [failure]; null result = the person cancelled.
class _FakePicker implements MediaPicker {
  _FakePicker({this.result, this.failure});
  final MessageAttachment? result;
  final MediaFailure? failure;

  Future<MessageAttachment?> _go() async {
    if (failure != null) throw MediaPickException(failure!);
    return result;
  }

  @override
  Future<MessageAttachment?> pickPhoto() => _go();

  @override
  Future<MessageAttachment?> pickVideo() => _go();
}

Future<void> _openMenu(WidgetTester tester) async {
  await tapOn(
    tester,
    find.bySemanticsLabel('Add a photo, video or voice note'),
  );
  await tester.pump(const Duration(milliseconds: 600));
}

Future<void> _choose(WidgetTester tester, String option) async {
  await _openMenu(tester);
  await tester.tap(find.text(option).last);
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pump(const Duration(milliseconds: 600));
}

Future<void> _sendNow(WidgetTester tester) async {
  await tapOn(tester, find.bySemanticsLabel('Send'));
  await tester.pump(const Duration(milliseconds: 600));
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'photo: preview, remove, caption, send; it shows in the chat and the inbox, and opens full screen',
    (tester) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(
        tester,
        overrides: [
          mediaPickerProvider.overrideWithValue(const SampleMediaPicker()),
        ],
      );
      await goTo(c, tester, '${Routes.chat}/priya');

      await _choose(tester, 'Photo');
      expect(find.byType(PendingAttachment), findsOneWidget);
      expect(find.text('columbia-road.jpg'), findsOneWidget);
      expect(find.bySemanticsLabel('Ready to send: Photo'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Remove attachment'));
      await tester.pump();
      expect(find.byType(PendingAttachment), findsNothing);

      await _choose(tester, 'Photo');
      await tester.enterText(find.byType(TextField), 'The stall I mentioned');
      await tester.pump();
      await _sendNow(tester);
      final last = c.read(datingProvider).threads['priya']!.last;
      expect(last.attachment?.kind, AttachmentKind.photo);
      expect(last.text, 'The stall I mentioned');
      expect(last.status, MessageStatus.onDevice);
      expect(find.byType(PendingAttachment), findsNothing);
      expect(find.byType(AttachmentMessage), findsOneWidget);
      expect(find.text('The stall I mentioned'), findsOneWidget);

      // The photo, its caption and the open action are read as one message.
      await tapOn(
        tester,
        find.bySemanticsLabel(RegExp('Photo.*Open photo', dotAll: true)),
      );
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(InteractiveViewer), findsOneWidget);
      await tester.tap(
        find
            .byWidgetPredicate((w) => w is NavIconButton && w.label == 'Close')
            .last,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(InteractiveViewer), findsNothing);

      await goTo(c, tester, Routes.messages);
      expect(
        find.textContaining('Photo: The stall I mentioned'),
        findsOneWidget,
      );
      await settle(tester);
    },
  );

  testWidgets(
    'video without a caption: a file card; playback says it is not in this build',
    (tester) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(
        tester,
        overrides: [
          mediaPickerProvider.overrideWithValue(const SampleMediaPicker()),
        ],
      );
      await goTo(c, tester, '${Routes.chat}/priya');
      await _choose(tester, 'Video');
      expect(find.textContaining('8.4 MB'), findsOneWidget);
      await _sendNow(tester);
      expect(
        c.read(datingProvider).threads['priya']!.last.attachment?.kind,
        AttachmentKind.video,
      );
      expect(find.text('market-walk.mp4'), findsOneWidget);
      await tapOn(tester, find.text('market-walk.mp4'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        find.textContaining('Video playback isn’t in this build'),
        findsOneWidget,
      );
      await settle(tester);
    },
  );

  testWidgets(
    'voice note: too short is refused; a timed demo note is sent and labelled',
    (tester) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(tester);
      await goTo(c, tester, '${Routes.chat}/priya');
      await _choose(tester, 'Voice note');
      expect(find.textContaining('doesn’t use the microphone'), findsOneWidget);

      await tapOn(tester, find.widgetWithText(NumayaButton, 'Start recording'));
      // Stopped before a second has passed.
      await tester.tap(find.widgetWithText(NumayaButton, 'Stop'));
      await tester.pump();
      expect(
        find.text('Too short. Record for at least a second.'),
        findsOneWidget,
      );

      await tapOn(tester, find.widgetWithText(NumayaButton, 'Start recording'));
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('0:03'), findsOneWidget);
      await tester.tap(find.widgetWithText(NumayaButton, 'Stop'));
      await tester.pump();
      await tapOn(tester, find.widgetWithText(NumayaButton, 'Add to message'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(PendingAttachment), findsOneWidget);
      await _sendNow(tester);
      final note = c.read(datingProvider).threads['priya']!.last.attachment!;
      expect(note.kind, AttachmentKind.voice);
      expect(note.duration, const Duration(seconds: 3));
      expect(note.sample, isTrue);
      expect(find.text('Demo · no sound recorded'), findsOneWidget);
      await settle(tester);
    },
  );

  testWidgets(
    'picker cancelled or refused: nothing is attached and the reason is shown',
    (tester) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(
        tester,
        overrides: [
          mediaPickerProvider.overrideWithValue(
            _FakePicker(failure: MediaFailure.permissionDenied),
          ),
        ],
      );
      await goTo(c, tester, '${Routes.chat}/priya');
      await _choose(tester, 'Photo');
      expect(find.byType(PendingAttachment), findsNothing);
      expect(find.textContaining('can’t see your photos'), findsOneWidget);
      await settle(tester);

      // Cancelled: no attachment and no message.
      c.read(sampleMediaProvider.notifier).set(false);
      await tester.pump(const Duration(seconds: 3));
      await settle(tester);
    },
  );

  testWidgets(
    'offline: an attachment waits with its caption and sends on reconnect',
    (tester) async {
      await usePhoneSize(tester);
      final c = await quickStartApp(
        tester,
        overrides: [
          mediaPickerProvider.overrideWithValue(_FakePicker(result: null)),
        ],
      );
      await goTo(c, tester, '${Routes.chat}/priya');
      // Cancelling the picker attaches nothing.
      await _choose(tester, 'Photo');
      expect(find.byType(PendingAttachment), findsNothing);

      c.read(connectivityProvider.notifier).setOnline(false);
      await tester.pump();
      await c
          .read(datingProvider.notifier)
          .send('priya', 'Look', attachment: SampleMediaPicker.photo);
      await tester.pump();
      expect(
        c.read(datingProvider).threads['priya']!.last.status,
        MessageStatus.waiting,
      );
      c.read(connectivityProvider.notifier).setOnline(true);
      await tester.pump(const Duration(seconds: 1));
      final last = c.read(datingProvider).threads['priya']!.last;
      expect(last.status, MessageStatus.onDevice);
      expect(last.attachment, SampleMediaPicker.photo);
      await settle(tester);
    },
  );
}
