import 'package:flutter_test/flutter_test.dart';
import 'package:numaya_mobile/features/onboarding/domain/profile_draft.dart';

void main() {
  final today = DateTime(2026, 10, 27, 12);

  ({DateTime? date, BirthDateProblem? problem}) parse(
    String d,
    String m,
    String y,
  ) => parseBirthDate(day: d, month: m, year: y, today: today);

  group('Date of birth (OD-1, OD-2)', () {
    test('needs all three fields, with a four-digit year', () {
      expect(parse('', '', '').problem, BirthDateProblem.incomplete);
      expect(parse('12', '04', '96').problem, BirthDateProblem.incomplete);
      expect(parse('12', '', '1996').problem, BirthDateProblem.incomplete);
    });

    test('refuses dates that do not exist', () {
      expect(parse('31', '02', '1996').problem, BirthDateProblem.invalid);
      expect(parse('29', '02', '1997').problem, BirthDateProblem.invalid);
      expect(parse('00', '05', '1996').problem, BirthDateProblem.invalid);
      expect(parse('12', '13', '1996').problem, BirthDateProblem.invalid);
      // A leap day that exists.
      expect(parse('29', '02', '1996').problem, isNull);
    });

    test('18 on the birthday itself, 17 the day before', () {
      expect(parse('27', '10', '2008').problem, isNull);
      expect(ageInYears(DateTime(2008, 10, 27), today), 18);
      expect(parse('28', '10', '2008').problem, BirthDateProblem.underage);
      expect(ageInYears(DateTime(2008, 10, 28), today), 17);
    });

    test('future dates and ages over 100 are refused', () {
      expect(parse('28', '10', '2026').problem, BirthDateProblem.future);
      expect(parse('01', '01', '2030').problem, BirthDateProblem.future);
      expect(parse('27', '10', '1926').problem, isNull); // exactly 100
      expect(parse('26', '10', '1925').problem, BirthDateProblem.unrealistic);
    });
  });

  group('First name', () {
    test('trimmed, not empty, letters in any script', () {
      expect(nameProblem(''), NameProblem.empty);
      expect(nameProblem('   '), NameProblem.empty);
      expect(nameProblem('Sam'), isNull);
      expect(nameProblem(' Mary-Elizabeth '), isNull);
      expect(nameProblem("O'Neill"), isNull);
      expect(nameProblem('Zoë'), isNull);
      expect(nameProblem('José María'), isNull);
      expect(nameProblem('明美'), isNull);
      expect(nameProblem('Сергей'), isNull);
    });

    test('digits, emoji and leading punctuation are refused', () {
      expect(nameProblem('Sam2'), NameProblem.characters);
      expect(nameProblem('Sam 😀'), NameProblem.characters);
      expect(nameProblem('-Sam'), NameProblem.characters);
      expect(nameProblem('@sam'), NameProblem.characters);
    });
  });

  group('What is missing before the profile can be created', () {
    const prompt = PromptAnswer(
      question: 'A green flag',
      answer: 'Remembers names.',
    );
    final complete = ProfileDraft(
      firstName: 'Sam',
      birthDate: DateTime(1995, 6, 1),
      gender: Gender.nonbinary,
      openTo: const {},
      lookingFor: const {LookingFor.open},
      interests: const ['a', 'b', 'c'],
      prompt: prompt,
      photos: const [DraftPhoto(id: 1, tone: 0), DraftPhoto(id: 2, tone: 1)],
    );

    test('nothing when every required answer is there', () {
      expect(complete.missing(today), isEmpty);
      expect(complete.aboutYouComplete(today), isTrue);
      expect(complete.lookingForComplete, isTrue);
    });

    test('each required item is named, in flow order', () {
      expect(const ProfileDraft().missing(today), MissingItem.values);
      expect(complete.copyWith(firstName: '  ').missing(today), [
        MissingItem.name,
      ]);
      expect(
        complete.copyWith(birthDate: DateTime(2010, 1, 1)).missing(today),
        [MissingItem.birthday],
      );
      expect(complete.copyWith(clearOpenTo: true).missing(today), [
        MissingItem.openTo,
      ]);
      expect(complete.copyWith(lookingFor: {}).missing(today), [
        MissingItem.intentions,
      ]);
      expect(
        complete
            .copyWith(photos: const [DraftPhoto(id: 1, tone: 0)])
            .missing(today),
        [MissingItem.photos],
      );
      expect(complete.copyWith(interests: ['a', 'b']).missing(today), [
        MissingItem.interests,
      ]);
      expect(complete.copyWith(clearPrompt: true).missing(today), [
        MissingItem.prompt,
      ]);
    });

    test('interests need 3 to 5; a whitespace answer is no answer', () {
      expect(
        const ProfileDraft(interests: ['a', 'b']).interestsComplete,
        isFalse,
      );
      expect(
        const ProfileDraft(interests: ['a', 'b', 'c']).interestsComplete,
        isTrue,
      );
      expect(
        const ProfileDraft(
          prompt: PromptAnswer(question: 'q', answer: '   '),
        ).promptComplete,
        isFalse,
      );
    });

    test('photos need at least two', () {
      expect(
        const ProfileDraft(photos: [DraftPhoto(id: 1, tone: 0)]).photosComplete,
        isFalse,
      );
      expect(complete.photosComplete, isTrue);
    });

    test('toString leaves out personal data', () {
      expect(complete.toString(), isNot(contains('Sam')));
      expect(complete.toString(), isNot(contains('1995')));
    });
  });
}
