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

  test('birth year keeps digits only', () {
    controller().setBirthYear('19a9-5');
    expect(draft().birthYear, '1995');
  });

  test('next step follows completed steps', () {
    expect(container.read(onboardingProvider).nextStep, SetupStep.basics);
    controller().completeStep(SetupStep.basics);
    expect(container.read(onboardingProvider).nextStep, SetupStep.interests);
    controller().completeStep(SetupStep.interests);
    controller().completeStep(SetupStep.photos);
    expect(container.read(onboardingProvider).nextStep, isNull);
  });

  test('cancelling an edit restores the profile', () {
    controller().setFirstName('Sam');
    controller().beginEdit();
    controller().setFirstName('Changed');
    controller().cancelEdit();
    expect(draft().firstName, 'Sam');
  });
}
