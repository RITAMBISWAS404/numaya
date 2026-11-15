@Tags(['comparison'])
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/core/design_system/design_system.dart'
    show Pressable;
import 'package:numaya_mobile/core/media/demo_photos.dart';
import 'package:numaya_mobile/features/dating/application/dating_controller.dart';
import 'package:numaya_mobile/features/dating/data/media_picker.dart';
import 'package:numaya_mobile/features/dating/domain/sample_people.dart';
import 'package:numaya_mobile/features/onboarding/application/onboarding_controller.dart';
import 'package:numaya_mobile/features/verification/application/verification_controller.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// Quality refinement (2026-11-15): states the UI-087..102 evidence did not cover. Same data and
/// viewport (393 x 852 at 3x) on the checkpoint (`before`) and the refinement branch (`after`);
/// only APIs both revisions share. Writes `test/screenshots/qr/<id>.png` (git-ignored).
///
///     flutter test --tags comparison --run-skipped --update-goldens \
///       test/screenshots/qr_capture_test.dart [--dart-define=QR_ONLY=<prefix>]
const _only = String.fromEnvironment('QR_ONLY');
const _scale = String.fromEnvironment('QR_SCALE', defaultValue: '1');
const _width = String.fromEnvironment('QR_WIDTH', defaultValue: '393');

class _Scene {
  const _Scene(this.id, this.route, {this.before, this.setup});
  final String id;
  final String route;

  /// Runs before navigation (seeding state).
  final void Function(ProviderContainer c)? before;

  /// Runs on the screen.
  final Future<void> Function(WidgetTester t, ProviderContainer c)? setup;
}

MessageAttachment _photo() => MessageAttachment(
  kind: AttachmentKind.photo,
  source: personById('priya')!.photoAt(2),
  sample: true,
);

const _voice = MessageAttachment(
  kind: AttachmentKind.voice,
  duration: Duration(seconds: 8),
  sample: true,
);

Future<void> _wait(WidgetTester t, [int ms = 700]) async {
  await t.pump();
  await t.pump(Duration(milliseconds: ms));
}

final List<_Scene> _qrScenes = [
  // UI-091: an image reply in Chat (not only Compliments).
  _Scene(
    'ui091-chat-photo-sent',
    '${Routes.chat}/priya',
    before: (c) => unawaited(
      c.read(datingProvider.notifier).send('priya', '', attachment: _photo()),
    ),
  ),
  _Scene(
    'ui091-chat-photo-reply',
    '${Routes.chat}/priya',
    before: (c) => unawaited(
      c.read(datingProvider.notifier).send('priya', '', attachment: _photo()),
    ),
    setup: (t, c) async {
      // Swipe the newest bubble (the photo) right to reply to it.
      final bubbles = find.byKey(const ValueKey('bubble-photo'));
      final target = bubbles.evaluate().isNotEmpty
          ? bubbles.last
          : find.byType(Image).last;
      await t.drag(target, const Offset(140, 0));
      await _wait(t, 900);
      await t.enterText(find.byType(EditableText).last, 'Where was this?');
      await _wait(t, 400);
    },
  ),
  // UI-070: a voice note idle and playing (filled play and pause glyphs).
  _Scene(
    'ui070-voice-idle',
    '${Routes.chat}/priya',
    before: (c) => unawaited(
      c.read(datingProvider.notifier).send('priya', '', attachment: _voice),
    ),
  ),
  _Scene(
    'ui070-voice-playing',
    '${Routes.chat}/priya',
    before: (c) => unawaited(
      c.read(datingProvider.notifier).send('priya', '', attachment: _voice),
    ),
    setup: (t, c) async {
      await t.tap(
        find
            .byWidgetPredicate(
              (w) =>
                  w is Pressable &&
                  (w.semanticLabel ?? '').startsWith('Play voice note'),
            )
            .last,
      );
      await _wait(t, 1200);
    },
  ),
  // UI-094 / QR-007: comparable status screens.
  _Scene(
    'ui094-verify-pending',
    Routes.verifyPhoto,
    before: (c) =>
        unawaited(c.read(photoVerificationProvider.notifier).submit()),
  ),
  _Scene(
    'ui094-verify-done',
    Routes.verifyPhoto,
    before: (c) {
      c.read(photoVerificationProvider.notifier).setApproveNext(true);
      unawaited(c.read(photoVerificationProvider.notifier).submit());
    },
    setup: (t, c) => _wait(t, 4000),
  ),
  const _Scene('ui094-underage', Routes.setupUnderage),
  // UI-049: the own-profile header overlays; QR-003: photo corners.
  const _Scene('ui049-profile-header', Routes.profile),
  const _Scene('qr003-discover-photo', Routes.home),
  const _Scene('qr003-preview', Routes.preview),
];

void main() {
  setUpAll(() async {
    await loadAppFonts();
    await DemoPhotoLibrary.load();
  });

  final stress = _scale != '1' || _width != '393';
  final dir = stress ? 'qr/stress/w${_width}_x$_scale' : 'qr';

  for (final s in _qrScenes) {
    if (_only.isNotEmpty && !_only.split(',').any((p) => s.id.startsWith(p))) {
      continue;
    }
    testWidgets(s.id, (tester) async {
      final w = double.parse(_width);
      tester.view.devicePixelRatio = 3;
      tester.view.physicalSize = Size(w, 852) * 3;
      tester.platformDispatcher.textScaleFactorTestValue = double.parse(_scale);
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final c = await quickStartApp(tester, world: DemoWorld.full);
      c.read(onboardingProvider.notifier).loadSample();
      s.before?.call(c);
      await goTo(c, tester, s.route);
      for (var i = 0; i < 4; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 150)),
        );
        await tester.pump(const Duration(milliseconds: 300));
      }
      if (s.setup != null) {
        await s.setup!(tester, c);
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 300)),
        );
        await tester.pump(const Duration(milliseconds: 300));
      }
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('$dir/${s.id}.png'),
      );
      await settle(tester);
    });
  }
}
