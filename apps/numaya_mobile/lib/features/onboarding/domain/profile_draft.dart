import 'package:flutter/foundation.dart';

enum Gender { woman, man, nonbinary }

enum LookingFor { longTerm, open, casual }

/// One of the six prompt questions (ported from src/flows/data.js).
const List<String> kPromptQuestions = [
  'A perfect first date',
  'I’m weirdly good at',
  'Let’s debate this',
  'My Sunday ritual',
  'A green flag',
  'I’ll never shut up about',
];

/// Interest sets shown during setup (ported from src/flows/data.js).
const List<({String label, List<String> interests})> kInterestGroups = [
  (
    label: 'Food and nights in',
    interests: ['Natural wine', 'Cooking', 'Board games'],
  ),
  (
    label: 'Culture',
    interests: ['Jazz', 'Museums', 'Poetry', 'Film photography'],
  ),
  (label: 'Out and about', interests: ['Climbing', 'Running', 'Travel']),
];

@immutable
class PromptAnswer {
  const PromptAnswer({required this.question, required this.answer});
  final String question;
  final String answer;

  static const int maxLength = 150;
}

@immutable
class DraftPhoto {
  const DraftPhoto({required this.id, required this.tone});
  final int id;

  /// Placeholder shade until real image upload exists.
  final int tone;
}

/// Profile setup rules, in one place so screens and tests agree.
abstract final class ProfileRules {
  static const int minAge = 18;
  static const int maxAge = 100;
  static const int maxLookingFor = 2;
  static const int minInterests = 3;
  static const int maxInterests = 5;
  static const int minPhotos = 2;
  static const int recommendedPhotos = 4;
  static const int maxPhotos = 6;
}

enum BirthYearProblem { incomplete, underage, unrealistic }

/// The profile being built during onboarding. Held in memory only (see ARCHITECTURE.md: no
/// personal data in plain local storage).
@immutable
class ProfileDraft {
  const ProfileDraft({
    this.firstName = '',
    this.birthYear = '',
    this.gender,
    this.lookingFor = const {},
    this.interests = const [],
    this.prompt,
    this.photos = const [],
  });

  final String firstName;
  final String birthYear;
  final Gender? gender;
  final Set<LookingFor> lookingFor;
  final List<String> interests;
  final PromptAnswer? prompt;
  final List<DraftPhoto> photos;

  int? ageIn(int currentYear) {
    if (birthYear.length != 4) return null;
    final year = int.tryParse(birthYear);
    return year == null ? null : currentYear - year;
  }

  BirthYearProblem? birthYearProblem(int currentYear) {
    final age = ageIn(currentYear);
    if (age == null) return BirthYearProblem.incomplete;
    if (age < ProfileRules.minAge && age >= 0) return BirthYearProblem.underage;
    if (age < 0 || age > ProfileRules.maxAge) {
      return BirthYearProblem.unrealistic;
    }
    return null;
  }

  bool basicsComplete(int currentYear) =>
      firstName.trim().isNotEmpty &&
      birthYearProblem(currentYear) == null &&
      gender != null &&
      lookingFor.isNotEmpty;

  bool get interestsComplete =>
      interests.length >= ProfileRules.minInterests &&
      interests.length <= ProfileRules.maxInterests &&
      (prompt?.answer.trim().isNotEmpty ?? false);

  bool get photosComplete => photos.length >= ProfileRules.minPhotos;

  ProfileDraft copyWith({
    String? firstName,
    String? birthYear,
    Gender? gender,
    Set<LookingFor>? lookingFor,
    List<String>? interests,
    PromptAnswer? prompt,
    List<DraftPhoto>? photos,
  }) {
    return ProfileDraft(
      firstName: firstName ?? this.firstName,
      birthYear: birthYear ?? this.birthYear,
      gender: gender ?? this.gender,
      lookingFor: lookingFor ?? this.lookingFor,
      interests: interests ?? this.interests,
      prompt: prompt ?? this.prompt,
      photos: photos ?? this.photos,
    );
  }

  /// Personal data stays out of logs.
  @override
  String toString() =>
      'ProfileDraft(${interests.length} interests, ${photos.length} photos)';
}
