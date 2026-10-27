import 'package:flutter/widgets.dart';

import '../../onboarding/domain/profile_draft.dart';
import '../../profile/domain/profile_details.dart';

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
    this.gender = Gender.woman,
    this.heightCm = 170,
    this.details = const {},
    this.openingMove,
    this.bio,
    this.morePrompts = const [],
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

  /// For the "Who you want to date" filter.
  final Gender gender;
  final int heightCm;

  /// "More about you" answers by [DetailKey], used on the profile and by advanced filters.
  final Map<DetailKey, String> details;

  /// The question this person asks new matches (Opening Moves, B-27).
  final String? openingMove;
  final String? bio;

  /// Further prompts (a profile can have up to three).
  final List<({String question, String answer})> morePrompts;

  String get initial => name.characters.first.toUpperCase();

  @override
  String toString() => 'SamplePerson($id)';
}

/// Sample profiles, in discovery order.
const List<SamplePerson> kSamplePeople = [
  SamplePerson(
    id: 'maya',
    gender: Gender.woman,
    heightCm: 168,
    details: {
      DetailKey.drinking: 'Socially',
      DetailKey.familyPlans: 'Open to children',
      DetailKey.starSign: 'Libra',
      DetailKey.education: 'Undergraduate degree',
    },
    openingMove: 'What’s the last record you bought?',
    bio: 'Designer by day, crate-digger by night.',
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
    gender: Gender.man,
    heightCm: 183,
    details: {
      DetailKey.drinking: 'Rarely',
      DetailKey.kids: 'Don’t have kids',
      DetailKey.education: 'Postgraduate degree',
    },
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
    gender: Gender.woman,
    heightCm: 162,
    details: {
      DetailKey.familyPlans: 'Want children',
      DetailKey.religion: 'Muslim',
      DetailKey.smoking: 'Never',
    },
    openingMove: 'Sweet or savoury breakfast? Defend it.',
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
    gender: Gender.woman,
    heightCm: 171,
    details: {
      DetailKey.exercise: 'Active',
      DetailKey.drinking: 'Socially',
      DetailKey.starSign: 'Pisces',
    },
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
    gender: Gender.nonbinary,
    heightCm: 175,
    details: {
      DetailKey.education: 'Postgraduate degree',
      DetailKey.politics: 'Liberal',
    },
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
    gender: Gender.man,
    heightCm: 186,
    details: {DetailKey.kids: 'Have kids', DetailKey.drinking: 'Socially'},
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
    gender: Gender.woman,
    heightCm: 174,
    name: 'Kemi',
    age: 27,
    distanceKm: 4,
    verified: true,
    likesYou: true,
    shared: ['Running'],
  ),
];

SamplePerson? personById(String id) {
  for (final p in [...kSamplePeople, ...kExtraPeople, ...kSeedMatchPeople]) {
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

// The full demo world --------------------------------------------------------------------------
// Added to the deck and inbox when the demo starts in its "full" world (the default in the app),
// so every screen has something to show. All invented; all labelled as samples.

/// More profiles for Discover, after [kSamplePeople].
const List<SamplePerson> kExtraPeople = [
  SamplePerson(
    id: 'ben',
    name: 'Ben',
    age: 33,
    job: 'Paramedic',
    distanceKm: 3,
    gender: Gender.man,
    heightCm: 180,
    verified: true,
    likesYou: true,
    shared: ['Running', 'Cooking'],
    prompt: (
      question: 'A green flag',
      answer: 'You text back “home safe” without being asked.',
    ),
    lookingFor: 'Long-term',
    livesIn: 'Walthamstow',
    languages: 'English',
    details: {
      DetailKey.exercise: 'Active',
      DetailKey.familyPlans: 'Want children',
      DetailKey.drinking: 'Rarely',
    },
    openingMove: 'What’s the best meal you’ve cooked lately?',
    opener: 'Ask about the night shifts…',
  ),
  SamplePerson(
    id: 'chloe',
    name: 'Chloé',
    age: 27,
    job: 'Illustrator',
    distanceKm: 5,
    gender: Gender.woman,
    heightCm: 165,
    isNew: true,
    shared: ['Poetry', 'Museums'],
    prompt: (
      question: 'My Sunday ritual',
      answer: 'Sketchbook, flat white, people-watching in the market.',
    ),
    lookingFor: 'Open to seeing',
    livesIn: 'Bermondsey',
    languages: 'English, French',
    details: {DetailKey.starSign: 'Gemini', DetailKey.smoking: 'Never'},
  ),
  SamplePerson(
    id: 'ade',
    name: 'Ade',
    age: 30,
    job: 'Sound engineer',
    distanceKm: 7,
    gender: Gender.man,
    heightCm: 178,
    verified: true,
    photoCount: 4,
    shared: ['Jazz', 'Film photography'],
    prompt: (
      question: 'I’ll never shut up about',
      answer: 'The perfect live room for a drum kit.',
    ),
    lookingFor: 'Long-term',
    livesIn: 'Deptford',
    languages: 'English, Yoruba',
    details: {
      DetailKey.religion: 'Christian',
      DetailKey.kids: 'Don’t have kids',
    },
  ),
  SamplePerson(
    id: 'mira',
    name: 'Mira',
    age: 32,
    job: 'Climate researcher',
    distanceKm: 11,
    gender: Gender.woman,
    heightCm: 160,
    verified: true,
    likesYou: true,
    shared: ['Climbing', 'Travel'],
    prompt: (
      question: 'Let’s debate this',
      answer: 'Night trains beat flights, every time.',
    ),
    lookingFor: 'Long-term',
    livesIn: 'Stoke Newington',
    languages: 'English, Hindi',
    details: {
      DetailKey.education: 'Postgraduate degree',
      DetailKey.drinking: 'Sober',
    },
    openingMove: 'Where would you take a night train to?',
  ),
  SamplePerson(
    id: 'finn',
    name: 'Finn',
    age: 26,
    job: 'Bike mechanic',
    distanceKm: 14,
    gender: Gender.nonbinary,
    heightCm: 172,
    isNew: true,
    shared: ['Board games'],
    prompt: (
      question: 'I’m weirdly good at',
      answer: 'Fixing anything with a chain and some patience.',
    ),
    lookingFor: 'Something casual',
    livesIn: 'Leyton',
    details: {DetailKey.exercise: 'Active', DetailKey.politics: 'Liberal'},
  ),
];

/// People the member has already matched with in the full world, with their conversations below.
const List<SamplePerson> kSeedMatchPeople = [
  SamplePerson(
    id: 'priya',
    name: 'Priya',
    age: 30,
    job: 'Bakery owner',
    distanceKm: 3,
    gender: Gender.woman,
    heightCm: 163,
    verified: true,
    likesYou: true,
    shared: ['Cooking', 'Travel'],
    prompt: (
      question: 'A perfect first date',
      answer: 'A bakery crawl that ends somewhere with a view.',
    ),
    lookingFor: 'Long-term',
    livesIn: 'Bethnal Green',
    languages: 'English, Hindi',
    openingMove: 'What’s your go-to order at a bakery?',
  ),
  SamplePerson(
    id: 'rafa',
    name: 'Rafa',
    age: 34,
    job: 'Teacher',
    distanceKm: 6,
    gender: Gender.man,
    heightCm: 179,
    likesYou: true,
    shared: ['Board games'],
    prompt: (
      question: 'I’m weirdly good at',
      answer: 'Explaining board game rules in under a minute.',
    ),
    lookingFor: 'Open to seeing',
    livesIn: 'Camden',
  ),
  SamplePerson(
    id: 'sasha',
    name: 'Sasha',
    age: 28,
    job: 'Nurse',
    distanceKm: 8,
    gender: Gender.woman,
    heightCm: 169,
    verified: true,
    likesYou: true,
    shared: ['Running'],
    prompt: (
      question: 'My Sunday ritual',
      answer: 'Parkrun, then pancakes, then a nap.',
    ),
    lookingFor: 'Long-term',
    livesIn: 'Clapham',
  ),
  SamplePerson(
    id: 'jo',
    name: 'Jo',
    age: 32,
    job: 'Architect',
    distanceKm: 4,
    gender: Gender.nonbinary,
    heightCm: 174,
    likesYou: true,
    shared: ['Museums'],
    prompt: (
      question: 'A green flag',
      answer: 'You have opinions about museum benches.',
    ),
    lookingFor: 'Open to seeing',
    livesIn: 'Shoreditch',
    openingMove: 'Which building in London would you live in?',
  ),
  SamplePerson(
    id: 'amara',
    name: 'Amara',
    age: 29,
    job: 'Solicitor',
    distanceKm: 9,
    gender: Gender.woman,
    heightCm: 170,
    verified: true,
    likesYou: true,
    shared: ['Jazz', 'Poetry'],
    prompt: (
      question: 'Let’s debate this',
      answer: 'Poetry readings are better than gigs.',
    ),
    lookingFor: 'Long-term',
    livesIn: 'Brixton',
    openingMove: 'Which poem do you know by heart?',
  ),
  SamplePerson(
    id: 'lina',
    name: 'Lina',
    age: 31,
    job: 'Physiotherapist',
    distanceKm: 12,
    gender: Gender.woman,
    heightCm: 166,
    likesYou: true,
    shared: ['Climbing'],
    prompt: (
      question: 'I’ll never shut up about',
      answer: 'Bouldering grades are a social construct.',
    ),
    lookingFor: 'Long-term',
    livesIn: 'Greenwich',
  ),
  SamplePerson(
    id: 'ollie',
    name: 'Ollie',
    age: 35,
    job: 'Chef',
    distanceKm: 10,
    gender: Gender.man,
    heightCm: 182,
    likesYou: true,
    shared: ['Natural wine'],
    prompt: (
      question: 'A perfect first date',
      answer: 'A tiny wine bar with a very long menu.',
    ),
    lookingFor: 'Open to seeing',
    livesIn: 'Hackney Wick',
  ),
];

/// Extra likes in the full world, newest first.
const List<({String person, int hoursAgo})> kExtraLikes = [
  (person: 'ben', hoursAgo: 2),
  (person: 'mira', hoursAgo: 30),
];

/// A message in a seeded sample conversation. [mine] is the member's side. Sample only: the member
/// never wrote these and the other side is invented.
@immutable
class SeedMessage {
  const SeedMessage(this.mine, this.text, this.minutesAgo);
  final bool mine;
  final String text;
  final int minutesAgo;
}

/// A seeded match: when it happened and its sample conversation (empty for a new match).
@immutable
class SeedMatch {
  const SeedMatch(this.person, this.hoursAgo, [this.messages = const []]);
  final String person;
  final int hoursAgo;
  final List<SeedMessage> messages;
}

/// Seeded matches, oldest first. New matches with no messages expire [kMatchWindowHours] after the
/// match (P-03 open; the observed 24 hours is used): Jo has 21 hours left, Amara 4, Lina 1, and
/// Ollie's match has expired.
const List<SeedMatch> kSeedMatches = [
  SeedMatch('sasha', 120, [
    SeedMessage(true, 'Parkrun then pancakes is a perfect Sunday.', 7000),
    SeedMessage(false, 'Right? Which parkrun do you do?', 6900),
    SeedMessage(true, 'Hackney Marshes, badly.', 6890),
    SeedMessage(false, 'Ha. Same energy. Pancakes after?', 4400),
    SeedMessage(true, 'Always. With far too much lemon.', 4380),
    SeedMessage(false, 'Coffee at the market on Saturday, maybe?', 1500),
  ]),
  SeedMatch('rafa', 70, [
    SeedMessage(false, 'Settlers of Catan or Codenames?', 3600),
    SeedMessage(true, 'Codenames, but only if I can be the spymaster.', 3500),
    SeedMessage(true, 'Same. Board games next week?', 2200),
  ]),
  SeedMatch('priya', 26, [
    SeedMessage(true, 'That bakery on Columbia Road, right?', 300),
    SeedMessage(false, 'Yes! The cardamom buns sell out by ten.', 95),
    SeedMessage(false, 'Have you been?', 94),
  ]),
  SeedMatch('ollie', 30),
  SeedMatch('lina', 23),
  SeedMatch('amara', 20),
  SeedMatch('jo', 3),
];

/// How long a new match lasts before someone sends a first message (P-03).
const int kMatchWindowHours = 24;

/// Optional reasons after unmatching (B-54, Mobbin "Unmatching a user").
const List<String> kUnmatchReasons = [
  'We’ve moved off the app',
  'Different relationship goals',
  'They didn’t reply',
  'They made me feel uncomfortable',
  'Something else',
];

/// Which part a report is about (B-51), asked for content reasons.
const List<String> kReportParts = ['Photos', 'Profile text', 'Messages'];
