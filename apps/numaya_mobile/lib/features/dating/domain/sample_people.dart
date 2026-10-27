import 'package:flutter/widgets.dart';

/// A profile in the demo. Every one is a **sample**: an invented person from the web prototype's
/// fixtures (`PEOPLE` in src/flows/data.js), shown with grey photo placeholders and labelled as a
/// sample profile in the UI. None is a real member.
@immutable
class SamplePerson {
  const SamplePerson({
    required this.id,
    required this.name,
    required this.age,
    required this.distanceKm,
    this.job,
    this.prompt,
    this.lookingFor,
    this.livesIn,
    this.verified = false,
    this.isNew = false,
    this.photoCount = 3,
    this.shared = const [],
    this.languages,
    this.likesYou = false,
    this.opener,
  });

  final String id;
  final String name;
  final int age;
  final String? job;
  final int distanceKm;

  /// Only people with a prompt appear in Discover (as in the web prototype).
  final ({String question, String answer})? prompt;
  final String? lookingFor;
  final String? livesIn;
  final bool verified;
  final bool isNew;
  final int photoCount;

  /// Interests shared with the member (the web prototype's fixed "You both like").
  final List<String> shared;
  final String? languages;

  /// Whether this sample profile has (in the demo) already liked the member.
  final bool likesYou;

  /// A suggested first line for the composer placeholder.
  final String? opener;

  String get initial => name.characters.first.toUpperCase();

  @override
  String toString() => 'SamplePerson($id)';
}

/// Sample profiles, in discovery order.
const List<SamplePerson> kSamplePeople = [
  SamplePerson(
    id: 'maya',
    name: 'Maya',
    age: 29,
    job: 'Product designer',
    distanceKm: 2,
    verified: true,
    isNew: true,
    photoCount: 4,
    likesYou: true,
    shared: ['Jazz', 'Natural wine'],
    prompt: (
      question: 'A perfect first date',
      answer: 'Natural wine, a record shop, and nowhere to be after.',
    ),
    lookingFor: 'Long-term',
    livesIn: 'Hackney',
    languages: 'English, Spanish',
    opener: 'Ask about the record shop…',
  ),
  SamplePerson(
    id: 'sam',
    name: 'Sam',
    age: 31,
    job: 'Architect',
    distanceKm: 4,
    shared: ['Cooking'],
    prompt: (
      question: 'I’m weirdly good at',
      answer: 'Finding the one good table in a crowded café.',
    ),
    lookingFor: 'Open to seeing',
    livesIn: 'Peckham',
  ),
  SamplePerson(
    id: 'noor',
    name: 'Noor',
    age: 28,
    job: 'Pastry chef',
    distanceKm: 6,
    verified: true,
    photoCount: 5,
    likesYou: true,
    shared: ['Cooking', 'Museums'],
    prompt: (
      question: 'Let’s debate this',
      answer: 'Croissants are a dinner food.',
    ),
    lookingFor: 'Long-term',
    livesIn: 'Islington',
    opener: 'Defend the croissant theory…',
  ),
  SamplePerson(
    id: 'ines',
    name: 'Inés',
    age: 24,
    job: 'Marine biologist',
    distanceKm: 9,
    verified: true,
    likesYou: true,
    shared: ['Climbing'],
    prompt: (
      question: 'My Sunday ritual',
      answer: 'Sea swim, then the longest breakfast in the city.',
    ),
    lookingFor: 'Long-term',
    livesIn: 'Brixton',
    opener: 'Ask about the sea swim…',
  ),
  SamplePerson(
    id: 'lea',
    name: 'Léa',
    age: 35,
    job: 'Documentary editor',
    distanceKm: 22,
    photoCount: 4,
    shared: ['Film photography', 'Museums'],
    prompt: (question: 'A green flag', answer: 'You still send postcards.'),
    lookingFor: 'Open to seeing',
    livesIn: 'Richmond',
  ),
  SamplePerson(
    id: 'tomas',
    name: 'Tomás',
    age: 41,
    job: 'Cellist',
    distanceKm: 38,
    verified: true,
    photoCount: 2,
    likesYou: true,
    shared: ['Jazz'],
    prompt: (
      question: 'I’ll never shut up about',
      answer: 'Why every city needs more late-night jazz bars.',
    ),
    lookingFor: 'Long-term',
    livesIn: 'Kingston',
    opener: 'Name your favourite jazz bar…',
  ),
  // In the web data Kemi has no prompt or facts: she appears in Likes, not in Discover.
  SamplePerson(
    id: 'kemi',
    name: 'Kemi',
    age: 27,
    distanceKm: 4,
    verified: true,
    likesYou: true,
    shared: ['Running'],
  ),
];

SamplePerson? personById(String id) {
  for (final p in kSamplePeople) {
    if (p.id == id) return p;
  }
  return null;
}

/// People who liked the member, newest first (`LIKES` in src/flows/data.js, without the activity
/// context, which this app doesn't have). Hours are relative to the demo's start.
const List<({String person, int hoursAgo})> kSampleLikes = [
  (person: 'maya', hoursAgo: 3),
  (person: 'kemi', hoursAgo: 1),
  (person: 'noor', hoursAgo: 18),
  (person: 'ines', hoursAgo: 63),
  (person: 'tomas', hoursAgo: 168),
];

/// Likes this recent count as "New".
const int kNewLikeHours = 24;

/// Likes this close count as "Nearby".
const int kNearbyKm = 5;

/// Generic opening lines (`OPENERS` in src/flows/data.js).
const List<String> kOpeners = [
  'What’s the best thing you’ve eaten this week?',
  'Plans for the weekend, or happily none?',
  'What’s a small thing that made your day recently?',
];

/// Report reasons (`REPORT_REASONS` in src/flows/data.js).
const List<String> kReportReasons = [
  'Fake profile',
  'Inappropriate photos or text',
  'Scam or selling something',
  'Hateful or abusive behaviour',
  'Might be under 18',
  'Something that happened offline',
];
