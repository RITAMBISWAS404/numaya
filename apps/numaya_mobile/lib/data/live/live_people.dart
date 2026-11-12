import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/dating/domain/live_directory.dart';
import '../../features/dating/domain/sample_people.dart';
import '../../features/onboarding/domain/profile_draft.dart';
import 'live_config.dart';
import 'live_errors.dart';

/// The server's coarse distance band as the whole kilometres the existing UI shows. The value is
/// the band's upper bound (shown with the current "km away" copy; the precise distance is never
/// sent to the app). Copy that says "within" is a frontend follow-up (UI_INTEGRATION.md).
int distanceFromBucket(String? bucket) => switch (bucket) {
  'under_5_km' => 5,
  'under_10_km' => 10,
  'under_25_km' => 25,
  'under_50_km' => 50,
  'over_50_km' => 51,
  _ => 0,
};

String? _lookingForLabel(List<dynamic>? values) =>
    switch (values?.firstOrNull) {
      'longTerm' => 'Long-term',
      'open' => 'Open to seeing',
      'casual' => 'Something casual',
      _ => null,
    };

/// Server ids of each live member's approved photos and prompts, in display order, so a
/// Compliment's "photo N" or "prompt N" maps to the exact item it was about.
final Map<String, ({List<String> photos, List<String> prompts})> liveTargets =
    {};

/// Builds a person from a `profile_card` (discovery_feed, likes_summary, member_card) and adds
/// them to [liveDirectory]. Photos become short-lived signed URLs.
Future<SamplePerson> livePersonFromCard(
  SupabaseClient db,
  Map<String, dynamic> card,
) async {
  final photos = (card['photos'] as List? ?? const [])
      .cast<Map<String, dynamic>>();
  final urls = <String?>[];
  for (final ph in photos) {
    final r = await db.storage
        .from('photos')
        .createSignedUrl(ph['path'] as String, LiveConfig.signedUrlSeconds);
    urls.add(r);
  }
  final prompts = (card['prompts'] as List? ?? const [])
      .cast<Map<String, dynamic>>();
  final first = prompts.firstOrNull;
  final person = SamplePerson(
    id: card['user_id'] as String,
    name: card['first_name'] as String? ?? '',
    age: card['age'] as int? ?? 0,
    distanceKm: distanceFromBucket(card['distance_bucket'] as String?),
    verified: card['verified'] == true,
    bio: card['bio'] as String?,
    lookingFor: _lookingForLabel(card['looking_for'] as List?),
    livesIn: card['city_label'] as String?,
    heightCm:
        card['height_cm'] as int? ??
        0, // 0 hides the height row (unknown, never invented)
    photoSources: urls,
    photoCount: urls.length,
    prompt: first == null
        ? null
        : (
            question: first['question'] as String,
            answer: first['answer'] as String,
          ),
    morePrompts: [
      for (final p in prompts.skip(1))
        (question: p['question'] as String, answer: p['answer'] as String),
    ],
    gender:
        Gender.values.asNameMap()[card['gender'] as String? ?? ''] ??
        Gender.nonbinary,
  );
  liveDirectory[person.id] = person;
  liveTargets[person.id] = (
    photos: [for (final ph in photos) ph['id'] as String],
    prompts: [for (final p in prompts) p['id'] as String],
  );
  return person;
}

/// Loads one counterpart's card (chat header, match screen) through `member_card`.
Future<SamplePerson?> livePersonById(SupabaseClient db, String id) async {
  try {
    final card = await guardLive(
      () => db.rpc<dynamic>('member_card', params: {'p_user': id}),
    );
    return await livePersonFromCard(db, (card as Map).cast<String, dynamic>());
  } on LiveFailure {
    return null;
  }
}
