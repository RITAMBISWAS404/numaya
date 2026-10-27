import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/features/onboarding/domain/profile_draft.dart';

void main() {
  const year = 2026;

  group('ProfileDraft basics', () {
    test('birth year must be four digits and 18 to 100 years ago', () {
      expect(
        const ProfileDraft(birthYear: '19').birthYearProblem(year),
        BirthYearProblem.incomplete,
      );
      expect(
        const ProfileDraft(birthYear: '2010').birthYearProblem(year),
        BirthYearProblem.underage,
      );
      expect(
        const ProfileDraft(birthYear: '2008').birthYearProblem(year),
        isNull,
      );
      expect(
        const ProfileDraft(birthYear: '1900').birthYearProblem(year),
        BirthYearProblem.unrealistic,
      );
      expect(
        const ProfileDraft(birthYear: '2090').birthYearProblem(year),
        BirthYearProblem.unrealistic,
      );
    });

    test('needs a name, valid year, gender and at least one intention', () {
      const base = ProfileDraft(
        firstName: 'Sam',
        birthYear: '1995',
        gender: Gender.nonbinary,
        lookingFor: {LookingFor.open},
      );
      expect(base.basicsComplete(year), isTrue);
      expect(base.copyWith(firstName: '  ').basicsComplete(year), isFalse);
      expect(base.copyWith(lookingFor: {}).basicsComplete(year), isFalse);
      expect(base.copyWith(birthYear: '2012').basicsComplete(year), isFalse);
    });
  });

  group('ProfileDraft interests and photos', () {
    test('interests need 3 to 5 picks and a prompt answer', () {
      const prompt = PromptAnswer(
        question: 'A green flag',
        answer: 'Remembers names.',
      );
      expect(
        const ProfileDraft(interests: ['a', 'b', 'c']).interestsComplete,
        isFalse,
      );
      expect(
        const ProfileDraft(
          interests: ['a', 'b'],
          prompt: prompt,
        ).interestsComplete,
        isFalse,
      );
      expect(
        const ProfileDraft(
          interests: ['a', 'b', 'c'],
          prompt: prompt,
        ).interestsComplete,
        isTrue,
      );
    });

    test('photos need at least two', () {
      expect(
        const ProfileDraft(photos: [DraftPhoto(id: 1, tone: 0)]).photosComplete,
        isFalse,
      );
      expect(
        const ProfileDraft(
          photos: [DraftPhoto(id: 1, tone: 0), DraftPhoto(id: 2, tone: 1)],
        ).photosComplete,
        isTrue,
      );
    });

    test('toString leaves out personal data', () {
      const draft = ProfileDraft(firstName: 'Sam', birthYear: '1995');
      expect(draft.toString(), isNot(contains('Sam')));
      expect(draft.toString(), isNot(contains('1995')));
    });
  });
}
