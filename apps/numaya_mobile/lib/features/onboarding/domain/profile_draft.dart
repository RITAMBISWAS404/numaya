import 'package:flutter/foundation.dart';

enum Gender { woman, man, nonbinary }

enum LookingFor { longTerm, open, casual }

/// Pronouns offered during setup (Hinge "What are your pronouns? Optional. Pick up to 4" [O]).
const List<String> kPronouns = [
  'she',
  'her',
  'hers',
  'he',
  'him',
  'his',
  'they',
  'them',
  'theirs',
  'ze',
  'zir',
];

/// Prompt categories (UI-008): a small set of browsable groups, each with at least ten prompts.
/// The six original prompts (ported from src/flows/data.js) are kept, spread across the groups;
/// the rest are original Numaya copy. Like the original six, prompt copy lives here as domain data
/// (it is also what a saved answer stores), not in the ARB files.
const List<({String name, List<String> prompts})> kPromptCategories = [
  (
    name: 'Dating',
    prompts: [
      'A perfect first date',
      'A green flag',
      'The way to win me over',
      'We’ll get along if',
      'The best date I’ve been on',
      'I’m looking for someone who',
      'A dealbreaker for me',
      'I know it’s going well when',
      'Together we could',
      'My love language is',
      'My most irrational dating fear',
    ],
  ),
  (
    name: 'About me',
    prompts: [
      'I’m weirdly good at',
      'I’ll never shut up about',
      'A fact about me that surprises people',
      'My friends ask me for advice about',
      'I get far too excited about',
      'I recharge by',
      'My simple pleasures',
      'I’m quietly proud of',
      'Something I’m learning',
      'My go-to karaoke song',
      'A random fact I love',
    ],
  ),
  (
    name: 'Opinions',
    prompts: [
      'Let’s debate this',
      'My unpopular opinion',
      'Pineapple on pizza: yes or no, and why',
      'The most overrated thing',
      'I could argue for hours about',
      'The best film of all time is',
      'A hill I’ll happily die on',
      'Morning person or night owl, and why',
      'The best way to spend a free tenner',
      'Something everyone should try once',
      'Cats, dogs or neither',
    ],
  ),
  (
    name: 'Weekends',
    prompts: [
      'My Sunday ritual',
      'My ideal weekend',
      'A perfect Saturday morning',
      'The last great thing I ate',
      'My favourite spot in the city',
      'A trip I’d take tomorrow',
      'What I’m listening to lately',
      'Something I’d recommend watching',
      'My go-to comfort meal',
      'If I had a free afternoon',
      'The best gig I’ve been to',
    ],
  ),
];

/// Every prompt, in category order. The first is the default question elsewhere.
final List<String> kPromptQuestions = [
  for (final c in kPromptCategories) ...c.prompts,
];

/// Interest sets shown during setup, with each set's emoji mark and tone (ported from
/// `INTEREST_GROUPS` in src/flows/data.js). Tones: peach, lilac, mint, butter.
const List<({String label, String emoji, String tone, List<String> interests})>
kInterestGroups = [
  (
    label: 'Food and nights in',
    emoji: '🍝',
    tone: 'peach',
    interests: ['Natural wine', 'Cooking', 'Board games'],
  ),
  (
    label: 'Culture',
    emoji: '🎭',
    tone: 'lilac',
    interests: ['Jazz', 'Museums', 'Poetry', 'Film photography'],
  ),
  (
    label: 'Out and about',
    emoji: '🌿',
    tone: 'mint',
    interests: ['Climbing', 'Running', 'Travel'],
  ),
];

/// Decorative emoji per interest (`INTEREST_EMOJI` in src/flows/data.js). The name stays the label.
const Map<String, String> kInterestEmoji = {
  'Natural wine': '🍷',
  'Cooking': '🍳',
  'Board games': '🎲',
  'Jazz': '🎷',
  'Museums': '🏛️',
  'Poetry': '📖',
  'Film photography': '📷',
  'Climbing': '🧗',
  'Running': '🏃',
  'Travel': '✈️',
};

@immutable
class PromptAnswer {
  const PromptAnswer({required this.question, required this.answer});
  final String question;
  final String answer;

  static const int maxLength = 150;
}

@immutable
class DraftPhoto {
  const DraftPhoto({required this.id, required this.tone, this.source});
  final int id;

  /// Placeholder shade, shown while there is no [source].
  final int tone;

  /// The photo chosen on this phone (a file path, or `asset:` for the sample). Kept on the device;
  /// there is no upload service in this build. Null: a placeholder tile.
  final String? source;
}

/// Profile setup rules, in one place so screens and tests agree
/// (docs/mobile/ONBOARDING_MASTER_INVENTORY.md, decisions OD-1 to OD-11).
abstract final class ProfileRules {
  static const int minAge = 18;
  static const int maxAge = 100;
  static const int maxNameLength = 30;
  static const int maxPronouns = 4;
  static const int maxLookingFor = 2;
  static const int minInterests = 3;
  static const int maxInterests = 5;
  static const int minPrompts = 1;
  static const int minPhotos = 2;
  static const int recommendedPhotos = 4;
  static const int maxPhotos = 6;
}

enum NameProblem { empty, characters }

enum BirthDateProblem { incomplete, invalid, future, underage, unrealistic }

/// Letters in any script (with their marks), spaces, hyphens, apostrophes and full stops; it must
/// start with a letter. Digits and emoji aren't names.
final RegExp _namePattern = RegExp(
  r"^[\p{L}\p{M}][\p{L}\p{M} '’.\-]*$",
  unicode: true,
);

/// Why [name] can't be used, or null when it can.
NameProblem? nameProblem(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return NameProblem.empty;
  if (!_namePattern.hasMatch(trimmed)) return NameProblem.characters;
  return null;
}

/// Age in whole years on [today] for someone born on [birthDate].
int ageInYears(DateTime birthDate, DateTime today) {
  var age = today.year - birthDate.year;
  if (today.month < birthDate.month ||
      (today.month == birthDate.month && today.day < birthDate.day)) {
    age--;
  }
  return age;
}

/// The date typed into the day, month and year fields, or why it isn't usable yet.
({DateTime? date, BirthDateProblem? problem}) parseBirthDate({
  required String day,
  required String month,
  required String year,
  required DateTime today,
}) {
  final d = int.tryParse(day.trim());
  final m = int.tryParse(month.trim());
  final y = int.tryParse(year.trim());
  if (d == null || m == null || y == null || year.trim().length != 4) {
    return (date: null, problem: BirthDateProblem.incomplete);
  }
  if (m < 1 || m > 12 || d < 1 || d > 31) {
    return (date: null, problem: BirthDateProblem.invalid);
  }
  final date = DateTime(y, m, d);
  // DateTime rolls 31 February over into March: that date doesn't exist.
  if (date.month != m || date.day != d) {
    return (date: null, problem: BirthDateProblem.invalid);
  }
  return (date: date, problem: birthDateProblem(date, today));
}

/// Why [birthDate] can't be used on [today], or null.
BirthDateProblem? birthDateProblem(DateTime? birthDate, DateTime today) {
  if (birthDate == null) return BirthDateProblem.incomplete;
  final day = DateTime(today.year, today.month, today.day);
  if (birthDate.isAfter(day)) return BirthDateProblem.future;
  final age = ageInYears(birthDate, today);
  if (age < ProfileRules.minAge) return BirthDateProblem.underage;
  if (age > ProfileRules.maxAge) return BirthDateProblem.unrealistic;
  return null;
}

/// A required part of the profile that is still missing (named on the review screen).
enum MissingItem {
  name,
  birthday,
  gender,
  openTo,
  intentions,
  photos,
  interests,
  prompt,
}

/// The profile being built during onboarding. Held in memory only (see ARCHITECTURE.md: no
/// personal data in plain local storage).
@immutable
class ProfileDraft {
  const ProfileDraft({
    this.firstName = '',
    this.birthDate,
    this.gender,
    this.pronouns = const [],
    this.showPronouns = true,
    this.openTo,
    this.lookingFor = const {},
    this.interests = const [],
    this.prompt,
    this.photos = const [],
  });

  final String firstName;

  /// Only the derived age is ever shown to other people.
  final DateTime? birthDate;
  final Gender? gender;
  final List<String> pronouns;
  final bool showPronouns;

  /// Who the member wants to meet: null until answered, empty for everyone. Never shown on the
  /// profile.
  final Set<Gender>? openTo;
  final Set<LookingFor> lookingFor;
  final List<String> interests;
  final PromptAnswer? prompt;
  final List<DraftPhoto> photos;

  int? ageOn(DateTime today) =>
      birthDate == null ? null : ageInYears(birthDate!, today);

  bool aboutYouComplete(DateTime today) =>
      nameProblem(firstName) == null &&
      birthDateProblem(birthDate, today) == null &&
      gender != null;

  bool get lookingForComplete => openTo != null && lookingFor.isNotEmpty;

  bool get interestsComplete =>
      interests.length >= ProfileRules.minInterests &&
      interests.length <= ProfileRules.maxInterests;

  bool get promptComplete => prompt?.answer.trim().isNotEmpty ?? false;

  bool get photosComplete => photos.length >= ProfileRules.minPhotos;

  /// What still blocks creating the profile, in the order of the flow.
  List<MissingItem> missing(DateTime today) => [
    if (nameProblem(firstName) != null) MissingItem.name,
    if (birthDateProblem(birthDate, today) != null) MissingItem.birthday,
    if (gender == null) MissingItem.gender,
    if (openTo == null) MissingItem.openTo,
    if (lookingFor.isEmpty) MissingItem.intentions,
    if (!photosComplete) MissingItem.photos,
    if (!interestsComplete) MissingItem.interests,
    if (!promptComplete) MissingItem.prompt,
  ];

  ProfileDraft copyWith({
    String? firstName,
    DateTime? birthDate,
    Gender? gender,
    List<String>? pronouns,
    bool? showPronouns,
    Set<Gender>? openTo,
    bool clearOpenTo = false,
    Set<LookingFor>? lookingFor,
    List<String>? interests,
    PromptAnswer? prompt,
    bool clearPrompt = false,
    List<DraftPhoto>? photos,
  }) {
    return ProfileDraft(
      firstName: firstName ?? this.firstName,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      pronouns: pronouns ?? this.pronouns,
      showPronouns: showPronouns ?? this.showPronouns,
      openTo: clearOpenTo ? null : (openTo ?? this.openTo),
      lookingFor: lookingFor ?? this.lookingFor,
      interests: interests ?? this.interests,
      prompt: clearPrompt ? null : (prompt ?? this.prompt),
      photos: photos ?? this.photos,
    );
  }

  /// Personal data stays out of logs.
  @override
  String toString() =>
      'ProfileDraft(${interests.length} interests, ${photos.length} photos)';
}
