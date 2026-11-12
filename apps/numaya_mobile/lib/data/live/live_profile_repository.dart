import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/logging/app_logger.dart';
import '../../features/onboarding/domain/profile_draft.dart';
import '../../features/onboarding/domain/profile_repository.dart';
import 'live_config.dart';
import 'live_errors.dart';

/// Profile fields that live outside [ProfileDraft] in the approved UI (the bio and height are
/// edited on "More about you").
typedef ProfileExtras = ({String bio, int? heightCm});

/// Consent versions recorded at onboarding. The policy texts are not yet approved
/// (docs/backend/DECISIONS_REQUIRED.md); this label says so in every stored consent.
const kConsentVersion = '2026-11-draft';

/// Saves the onboarding profile to Supabase (backend V1).
///
/// - Profile fields: `profiles` (own row; server-owned columns cannot be written).
/// - Prompts: `prompts` (own rows).
/// - Photos: uploaded into the member's own folder of the private `photos` bucket, then
///   registered with `register_photo` (six at most; each waits for moderation before anyone else
///   can see it).
/// - Completion: `complete_onboarding` checks age (18+) and records consents on the server.
class LiveProfileRepository implements ProfileRepository {
  LiveProfileRepository(this._client, {required this.extras});

  final SupabaseClient _client;
  final ProfileExtras Function() extras;
  static const _log = AppLogger('LiveProfile');

  /// Local file path -> object path already uploaded in this session (no double uploads on retry).
  final Map<String, String> _uploaded = {};

  @override
  Future<ProfileDraft?> load(String userId) => guardLive(() async {
    final p = await _client
        .from('profiles')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    if (p == null) return null;
    final prompts = await _client
        .from('prompts')
        .select()
        .eq('user_id', userId)
        .order('position');
    final photos = await _client
        .from('photos')
        .select()
        .eq('user_id', userId)
        .inFilter('status', ['pending', 'approved'])
        .order('position');
    final acc = await _client.rpc<dynamic>('account_state');
    final drafted = <DraftPhoto>[];
    for (final ph in photos) {
      final signed = await _client.storage
          .from('photos')
          .createSignedUrl(
            ph['object_path'] as String,
            LiveConfig.signedUrlSeconds,
          );
      drafted.add(
        DraftPhoto(
          id: ph['position'] as int,
          tone: (ph['position'] as int) % 4,
          source: signed,
        ),
      );
    }
    final first = prompts.isEmpty ? null : prompts.first;
    _log.info('Profile loaded (${photos.length} photos)');
    return ProfileDraft(
      firstName: p['first_name'] as String? ?? '',
      // The member's own birth date, returned only to them by account_state.
      birthDate: switch ((acc as Map)['birth_date']) {
        final String d => DateTime.parse(d),
        _ => null,
      },
      gender: _gender(p['gender'] as String?),
      pronouns: [
        for (final x in (p['pronouns'] as List? ?? const [])) x as String,
      ],
      showPronouns: p['show_pronouns'] as bool? ?? false,
      openTo: {
        for (final g in (p['open_to'] as List? ?? const []))
          ?_gender(g as String),
      },
      lookingFor: {
        for (final l in (p['looking_for'] as List? ?? const []))
          ?_lookingFor(l as String),
      },
      interests: [
        for (final x in (p['interests'] as List? ?? const [])) x as String,
      ],
      prompt: first == null
          ? null
          : PromptAnswer(
              question: first['question'] as String,
              answer: first['answer'] as String,
            ),
      photos: drafted,
    );
  });

  @override
  Future<void> save(String userId, ProfileDraft profile) => guardLive(() async {
    final more = extras();
    await _client
        .from('profiles')
        .update({
          'first_name': profile.firstName.trim(),
          'gender': profile.gender?.name,
          'pronouns': profile.pronouns,
          'show_pronouns': profile.showPronouns,
          'open_to': [
            for (final g in profile.openTo ?? const <Gender>{}) g.name,
          ],
          'looking_for': [for (final l in profile.lookingFor) l.name],
          'interests': profile.interests,
          'bio': more.bio.trim(),
          'height_cm': more.heightCm,
        })
        .eq('user_id', userId);

    final prompt = profile.prompt;
    if (prompt != null) {
      await _client.from('prompts').upsert({
        'user_id': userId,
        'position': 1,
        'question': prompt.question,
        'answer': prompt.answer.trim(),
      }, onConflict: 'user_id,position');
    }

    var position = 0;
    for (final photo in profile.photos) {
      position++;
      final source = photo.source;
      // Remote (already registered) photos and missing ones are left as they are.
      if (source == null ||
          source.startsWith('http') ||
          source.startsWith('asset:')) {
        continue;
      }
      if (_uploaded.containsKey(source)) continue;
      final file = File(source);
      if (!file.existsSync()) continue;
      // Re-encoded on the device before upload: drops every metadata block (EXIF GPS included)
      // and caps the long side at 1600 px. The server-side worker is still required
      // (PROVIDER_STATUS: image processing) because the device is not trusted.
      final clean = await compute(sanitizePhoto, await file.readAsBytes());
      if (clean == null) throw const LiveFailure('type_not_allowed');
      final objectPath =
          '$userId/${DateTime.now().microsecondsSinceEpoch}-$position.jpg';
      await _client.storage
          .from('photos')
          .uploadBinary(
            objectPath,
            clean,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );
      await _client.rpc<dynamic>(
        'register_photo',
        params: {'p_object_path': objectPath, 'p_position': position},
      );
      _uploaded[source] = objectPath;
    }

    final birth = profile.birthDate;
    if (birth != null) {
      final res = await _client.rpc<dynamic>(
        'complete_onboarding',
        params: {
          'p_birth_date':
              '${birth.year.toString().padLeft(4, '0')}-'
              '${birth.month.toString().padLeft(2, '0')}-${birth.day.toString().padLeft(2, '0')}',
          'p_terms_version': kConsentVersion,
          'p_privacy_version': kConsentVersion,
          'p_community_version': kConsentVersion,
        },
      );
      if ((res as Map)['result'] == 'underage') {
        throw const LiveFailure('underage');
      }
    }
    _log.info('Profile saved');
  });

  /// Account deletion runs through the auth repository (request_account_deletion).
  @override
  Future<void> delete(String userId) async {}

  static Gender? _gender(String? v) =>
      v == null ? null : Gender.values.asNameMap()[v];
  static LookingFor? _lookingFor(String v) => LookingFor.values.asNameMap()[v];
}

/// Decodes any supported image, applies its EXIF orientation, drops all metadata and returns a
/// JPEG at most 1600 px on the long side; null when the bytes are not an image.
Uint8List? sanitizePhoto(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return null;
  var image = img.bakeOrientation(decoded);
  image.exif = img.ExifData();
  final long = image.width > image.height ? image.width : image.height;
  if (long > 1600) {
    image = image.width >= image.height
        ? img.copyResize(image, width: 1600)
        : img.copyResize(image, height: 1600);
  }
  return img.encodeJpg(image, quality: 88);
}
