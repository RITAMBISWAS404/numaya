import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/routes.dart';
import 'package:numaya_mobile/features/dating/data/media_picker.dart';
import 'package:numaya_mobile/features/onboarding/application/onboarding_controller.dart';

import '../helpers/journeys.dart';
import '../helpers/test_app.dart';

/// A picker that hands back the sample photo, nothing (cancelled), or a refusal.
class _Picker implements MediaPicker {
  _Picker(this.mode);
  String mode;

  Future<MessageAttachment?> _go() async => switch (mode) {
    'cancel' => null,
    'denied' => throw const MediaPickException(MediaFailure.permissionDenied),
    _ => SampleMediaPicker.photo,
  };

  @override
  Future<MessageAttachment?> pickPhoto() => _go();
  @override
  Future<MessageAttachment?> pickVideo() => _go();
  @override
  Future<MessageAttachment?> takePhoto() => _go();
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'Edit profile: a photo from the phone shows in the grid, on Profile and in Preview; '
    'cancel and refusal add nothing; replace keeps the place',
    (tester) async {
      await usePhoneSize(tester);
      final picker = _Picker('photo');
      final c = await quickStartApp(tester, mediaPicker: picker);
      int count() => c.read(onboardingProvider).draft.photos.length;
      final before = count();

      await goTo(c, tester, Routes.editProfile);
      picker.mode = 'cancel';
      await tapOn(tester, find.bySemanticsLabel('Add a photo').first);
      await tester.pump(const Duration(milliseconds: 600));
      expect(count(), before);

      picker.mode = 'denied';
      await tapOn(tester, find.bySemanticsLabel('Add a photo').first);
      await tester.pump(const Duration(milliseconds: 600));
      expect(count(), before);
      expect(find.textContaining('can’t see your photos'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));

      picker.mode = 'photo';
      await tapOn(tester, find.bySemanticsLabel('Add a photo').first);
      await tester.pump(const Duration(milliseconds: 600));
      expect(count(), before + 1);
      final added = c.read(onboardingProvider).draft.photos.last;
      expect(added.source, SampleMediaPicker.photo.source);
      expect(find.byType(Image), findsWidgets);

      // Make it the main photo: Profile's avatar and Preview now show it.
      await tapOn(tester, find.bySemanticsLabel('Photo ${before + 1} options'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.tap(find.text('Make main photo'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(
        c.read(onboardingProvider).draft.photos.first.source,
        SampleMediaPicker.photo.source,
      );
      await goTo(c, tester, Routes.profile);
      expect(
        find.byWidgetPredicate((w) => w is Image && w.width == 176),
        findsOneWidget,
      );
      await goTo(c, tester, Routes.preview);
      expect(find.byType(Image), findsWidgets);

      // Replace the second photo (a placeholder) with one from the phone, in the same place.
      await goTo(c, tester, Routes.editProfile);
      final second = c.read(onboardingProvider).draft.photos[1];
      expect(second.source, isNull);
      await tapOn(tester, find.bySemanticsLabel('Photo 2 options'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.tap(find.text('Replace photo'));
      await tester.pump(const Duration(milliseconds: 600));
      final now = c.read(onboardingProvider).draft.photos;
      expect(now.length, before + 1);
      expect(now[1].source, SampleMediaPicker.photo.source);
      await settle(tester);
    },
  );
}
