import '../../dating/domain/sample_people.dart';
import '../../onboarding/domain/profile_draft.dart';
import '../domain/profile_details.dart';

/// The member's own profile in the shape other people see it, for the preview (V16 106). Uses only
/// what the member entered; hidden fields stay hidden.
SamplePerson memberAsPerson({
  required ProfileDraft draft,
  required ProfileDetails details,
  required int currentYear,
  required bool verified,
}) {
  final looking = draft.lookingFor.isEmpty
      ? null
      : switch (LookingFor.values.firstWhere(draft.lookingFor.contains)) {
          LookingFor.longTerm => 'Long-term',
          LookingFor.open => 'Open to seeing',
          LookingFor.casual => 'Something casual',
        };
  final prompts = [
    if (draft.prompt != null)
      (question: draft.prompt!.question, answer: draft.prompt!.answer),
    for (final p in details.extraPrompts)
      (question: p.question, answer: p.answer),
  ];
  return SamplePerson(
    id: 'me',
    name: draft.firstName.trim().isEmpty ? '?' : draft.firstName.trim(),
    age: draft.ageIn(currentYear) ?? 0,
    job: details.about[AboutKey.work],
    distanceKm: 0,
    prompt: prompts.isEmpty ? null : prompts.first,
    morePrompts: prompts.skip(1).toList(),
    lookingFor: looking,
    livesIn: details.about[AboutKey.location],
    verified: verified,
    photoCount: draft.photos.length,
    shared: draft.interests,
    languages: details.languages.isEmpty ? null : details.languages.join(', '),
    gender: draft.gender ?? Gender.woman,
    heightCm: details.heightCm ?? 0,
    details: details.details,
    openingMove: details.openingMoves.isEmpty
        ? null
        : details.openingMoves.first,
    bio: details.bio.isEmpty ? null : details.bio,
  );
}
