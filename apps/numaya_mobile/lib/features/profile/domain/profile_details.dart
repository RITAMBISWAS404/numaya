import 'package:flutter/foundation.dart';

import '../../onboarding/domain/profile_draft.dart';

/// "More about you" attributes (B-24, Mobbin "Editing my profile": height, exercise, star sign,
/// education level, drinking, smoking, family plans, kids, religion, politics). The values are
/// product content, kept in the domain like interests until translation starts.
enum DetailKey {
  exercise,
  education,
  drinking,
  smoking,
  starSign,
  familyPlans,
  kids,
  religion,
  politics;

  String get label => switch (this) {
    exercise => 'Exercise',
    education => 'Education level',
    drinking => 'Drinking',
    smoking => 'Smoking',
    starSign => 'Star sign',
    familyPlans => 'Family plans',
    kids => 'Have kids',
    religion => 'Religion',
    politics => 'Politics',
  };

  /// The question shown on filters and pickers.
  String get question => switch (this) {
    exercise => 'How often do you exercise?',
    education => 'What’s your education?',
    drinking => 'Do you drink?',
    smoking => 'Do you smoke?',
    starSign => 'What’s your star sign?',
    familyPlans => 'What are your family plans?',
    kids => 'Do you have kids?',
    religion => 'What’s your religion?',
    politics => 'What are your politics?',
  };

  List<String> get options => switch (this) {
    exercise => const ['Active', 'Sometimes', 'Almost never'],
    education => const [
      'Secondary school',
      'Vocational',
      'Undergraduate degree',
      'Postgraduate degree',
    ],
    drinking => const ['Socially', 'Rarely', 'Never', 'Sober'],
    smoking => const ['Socially', 'Never', 'Regularly', 'Trying to quit'],
    starSign => const [
      'Aries',
      'Taurus',
      'Gemini',
      'Cancer',
      'Leo',
      'Virgo',
      'Libra',
      'Scorpio',
      'Sagittarius',
      'Capricorn',
      'Aquarius',
      'Pisces',
    ],
    familyPlans => const [
      'Want children',
      'Don’t want children',
      'Open to children',
      'Not sure yet',
    ],
    kids => const ['Have kids', 'Don’t have kids'],
    religion => const [
      'Agnostic',
      'Atheist',
      'Buddhist',
      'Christian',
      'Hindu',
      'Jewish',
      'Muslim',
      'Sikh',
      'Spiritual',
      'Other',
    ],
    politics => const ['Apolitical', 'Moderate', 'Liberal', 'Conservative'],
  };

  /// Advanced filters offered as "Add this filter" rows (B-35).
  static const filterable = [
    familyPlans,
    kids,
    religion,
    education,
    drinking,
    smoking,
    starSign,
  ];
}

/// The "About you" text rows (B-24).
enum AboutKey {
  work,
  school,
  hometown,
  location;

  String get label => switch (this) {
    work => 'Work',
    school => 'Education',
    hometown => 'Hometown',
    location => 'Location',
  };

  String get hint => switch (this) {
    work => 'e.g. Designer at a studio',
    school => 'e.g. University of Leeds',
    hometown => 'e.g. Bristol',
    location => 'e.g. Hackney, London',
  };

  static const maxLength = 60;
}

const List<String> kLanguages = [
  'English',
  'Spanish',
  'French',
  'German',
  'Portuguese',
  'Italian',
  'Arabic',
  'Hindi',
  'Mandarin',
  'Yoruba',
  'Polish',
  'Turkish',
];

/// More specific gender identities (B-12), offered under the broad choice.
const Map<Gender, List<String>> kGenderDetails = {
  Gender.woman: ['Cis woman', 'Trans woman', 'Intersex woman', 'Transfeminine'],
  Gender.man: ['Cis man', 'Trans man', 'Intersex man', 'Transmasculine'],
  Gender.nonbinary: [
    'Agender',
    'Bigender',
    'Genderfluid',
    'Genderqueer',
    'Two-spirit',
  ],
};

/// Suggested Opening Moves (B-27, Mobbin "Your Opening Moves": up to three questions new matches
/// can answer).
const List<String> kOpeningMoveSuggestions = [
  'What’s something I wouldn’t know from your profile?',
  'What’s your go-to order at a café?',
  'Describe your ideal Sunday in three words.',
  'What’s the best trip you’ve ever taken?',
  'What are you looking forward to this month?',
];

/// Areas offered when location isn't used (OD-7). Sample list for the demo build.
const List<String> kSampleAreas = [
  'Hackney, London',
  'Islington, London',
  'Peckham, London',
  'Brixton, London',
  'Camden, London',
  'Manchester',
  'Bristol',
  'Leeds',
  'Brighton',
  'Glasgow',
  'Edinburgh',
  'Cardiff',
];

/// The area the simulated location prompt sets (the demo never reads the phone's location).
const String kSampleDeviceArea = 'Hackney, London';

abstract final class DetailRules {
  static const int maxPrompts = 3;
  static const int maxOpeningMoves = 3;
  static const int openingMoveLength = 160;
  static const int bioLength = 300;
  static const int maxLanguages = 5;
  static const int minHeight = 140;
  static const int maxHeight = 210;
}

/// Everything on the member's profile beyond the onboarding draft (B-24). In memory only, like the
/// draft.
@immutable
class ProfileDetails {
  const ProfileDetails({
    this.bio = '',
    this.about = const {},
    this.heightCm,
    this.details = const {},
    this.languages = const [],
    this.extraPrompts = const [],
    this.openingMoves = const [],
    this.genderDetail,
    this.showGender = true,
    this.showAge = true,
    this.showDistance = true,
    this.area,
    this.areaFromDevice = false,
  });

  final String bio;
  final Map<AboutKey, String> about;
  final int? heightCm;
  final Map<DetailKey, String> details;
  final List<String> languages;

  /// Prompts beyond the one written during onboarding (up to [DetailRules.maxPrompts] in all).
  final List<PromptAnswer> extraPrompts;
  final List<String> openingMoves;
  final String? genderDetail;
  final bool showGender;
  final bool showAge;
  final bool showDistance;

  /// Where the member meets people: an area name only, never coordinates (OD-7).
  final String? area;

  /// Whether [area] came from the (simulated) location prompt rather than the member's choice.
  final bool areaFromDevice;

  ProfileDetails copyWith({
    String? bio,
    Map<AboutKey, String>? about,
    int? heightCm,
    bool clearHeight = false,
    Map<DetailKey, String>? details,
    List<String>? languages,
    List<PromptAnswer>? extraPrompts,
    List<String>? openingMoves,
    String? genderDetail,
    bool clearGenderDetail = false,
    bool? showGender,
    bool? showAge,
    bool? showDistance,
    String? area,
    bool clearArea = false,
    bool? areaFromDevice,
  }) => ProfileDetails(
    bio: bio ?? this.bio,
    about: about ?? this.about,
    heightCm: clearHeight ? null : (heightCm ?? this.heightCm),
    details: details ?? this.details,
    languages: languages ?? this.languages,
    extraPrompts: extraPrompts ?? this.extraPrompts,
    openingMoves: openingMoves ?? this.openingMoves,
    genderDetail: clearGenderDetail
        ? null
        : (genderDetail ?? this.genderDetail),
    showGender: showGender ?? this.showGender,
    showAge: showAge ?? this.showAge,
    showDistance: showDistance ?? this.showDistance,
    area: clearArea ? null : (area ?? this.area),
    areaFromDevice: areaFromDevice ?? this.areaFromDevice,
  );

  /// Personal data stays out of logs.
  @override
  String toString() =>
      'ProfileDetails(${details.length} details, ${extraPrompts.length} prompts)';
}

/// One part of the completion hub (B-21): how many of [total] are filled.
@immutable
class CompletionPart {
  const CompletionPart(this.done, this.total);
  final int done;
  final int total;
  bool get complete => done >= total;
}

/// Profile completion (B-21 / B-23 ring), computed from what the member actually entered.
@immutable
class ProfileCompletion {
  const ProfileCompletion({
    required this.photos,
    required this.prompts,
    required this.interests,
    required this.about,
    required this.bio,
    required this.moreAbout,
  });

  factory ProfileCompletion.of(ProfileDraft draft, ProfileDetails details) {
    final aboutFilled = AboutKey.values
        .where((k) => (details.about[k] ?? '').trim().isNotEmpty)
        .length;
    return ProfileCompletion(
      photos: CompletionPart(
        draft.photos.length.clamp(0, ProfileRules.recommendedPhotos),
        ProfileRules.recommendedPhotos,
      ),
      prompts: CompletionPart(
        (draft.prompt == null ? 0 : 1) + details.extraPrompts.length,
        DetailRules.maxPrompts,
      ),
      interests: CompletionPart(
        draft.interests.length,
        ProfileRules.maxInterests,
      ),
      about: CompletionPart(aboutFilled, AboutKey.values.length),
      bio: CompletionPart(details.bio.trim().isEmpty ? 0 : 1, 1),
      moreAbout: CompletionPart(
        details.details.length + (details.heightCm == null ? 0 : 1),
        DetailKey.values.length + 1,
      ),
    );
  }

  final CompletionPart photos;
  final CompletionPart prompts;
  final CompletionPart interests;
  final CompletionPart about;
  final CompletionPart bio;
  final CompletionPart moreAbout;

  List<CompletionPart> get parts => [
    photos,
    prompts,
    interests,
    about,
    bio,
    moreAbout,
  ];

  /// Equal weight per part, so one long list can't dominate.
  int get percent {
    final sum = parts.fold<double>(
      0,
      (a, p) => a + (p.total == 0 ? 1 : (p.done / p.total).clamp(0, 1)),
    );
    return (sum / parts.length * 100).round();
  }
}
