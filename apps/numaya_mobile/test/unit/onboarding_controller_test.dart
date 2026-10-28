import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/app/providers.dart';
import 'package:numaya_mobile/features/onboarding/application/onboarding_controller.dart';
import 'package:numaya_mobile/features/onboarding/domain/profile_draft.dart';

void main() {
  late ProviderContainer container;
  OnboardingController controller() =>
      container.read(onboardingProvider.notifier);
  ProfileDraft draft() => container.read(onboardingProvider).draft;

  setUp(() {
    container = ProviderContainer(
      overrides: [
        clockProvider.overrideWithValue(() => DateTime(2026, 10, 27)),
      ],
    );
  });
  tearDown(() => container.dispose());

  test('extra interest taps past five are ignored', () {
    for (final i in ['a', 'b', 'c', 'd', 'e', 'f']) {
      controller().toggleInterest(i);
    }
    expect(draft().interests, ['a', 'b', 'c', 'd', 'e']);
    controller().toggleInterest('a');
    expect(draft().interests, ['b', 'c', 'd', 'e']);
  });

  test('looking-for allows two choices at most', () {
    controller().toggleLookingFor(LookingFor.longTerm);
    controller().toggleLookingFor(LookingFor.open);
    controller().toggleLookingFor(LookingFor.casual);
    expect(draft().lookingFor, {LookingFor.longTerm, LookingFor.open});
  });

  test('photos cap at six and can be removed', () {
    for (var i = 0; i < 8; i++) {
      controller().addPhoto();
    }
    expect(draft().photos.length, ProfileRules.maxPhotos);
    controller().removePhoto(draft().photos.first.id);
    expect(draft().photos.length, 5);
  });

  test('pronouns cap at four; who-to-meet maps every group to everyone', () {
    for (final p in kPronouns.take(6)) {
      controller().togglePronoun(p);
    }
    expect(draft().pronouns, kPronouns.take(4).toList());
    expect(draft().openTo, isNull);
    controller().toggleOpenTo(Gender.woman);
    expect(draft().openTo, {Gender.woman});
    controller().toggleOpenTo(Gender.man);
    controller().toggleOpenTo(Gender.nonbinary);
    expect(draft().openTo, isEmpty); // everyone
    controller().toggleOpenTo(Gender.man);
    expect(draft().openTo, {Gender.man});
    controller().toggleOpenTo(Gender.man);
    expect(draft().openTo, isNull); // nothing picked is no answer
    controller().setOpenToEveryone();
    expect(draft().openTo, isEmpty);
  });

  test('confirming an age under 18 locks setup', () {
    expect(container.read(onboardingProvider).ageLocked, isFalse);
    controller().confirmUnderage();
    expect(container.read(onboardingProvider).ageLocked, isTrue);
  });

  test('next step follows the flow; sections finish with their last step', () {
    OnboardingState state() => container.read(onboardingProvider);
    expect(state().nextStep, SetupStep.name);
    controller().completeStep(SetupStep.name);
    expect(state().nextStep, SetupStep.gender);
    expect(state().sectionDone(SetupSection.aboutYou), isFalse);
    controller().completeStep(SetupStep.gender);
    expect(state().sectionDone(SetupSection.aboutYou), isTrue);
    for (final s in SetupStep.values) {
      controller().completeStep(s);
    }
    expect(state().nextStep, isNull);
  });

  test('cancelling an edit restores the profile', () {
    controller().setFirstName('Sam');
    controller().beginEdit();
    controller().setFirstName('Changed');
    controller().cancelEdit();
    expect(draft().firstName, 'Sam');
  });

  test(
    'make main photo moves a photo to the front; the main photo stays put',
    () {
      controller()
        ..addPhoto()
        ..addPhoto()
        ..addPhoto();
      final ids = [for (final p in draft().photos) p.id];
      controller().makeMain(ids[2]);
      expect([for (final p in draft().photos) p.id], [ids[2], ids[0], ids[1]]);
      controller().makeMain(ids[2]);
      expect(draft().photos.first.id, ids[2]);
      controller().removePhoto(ids[2]);
      expect([for (final p in draft().photos) p.id], [ids[0], ids[1]]);
    },
  );
}
