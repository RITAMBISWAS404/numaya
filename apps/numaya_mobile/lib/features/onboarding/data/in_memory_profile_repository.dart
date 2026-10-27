import '../domain/profile_draft.dart';
import '../domain/profile_repository.dart';

/// Keeps profiles in memory for this app session. Nothing is written to disk, so no personal data
/// outlives the process.
class InMemoryProfileRepository implements ProfileRepository {
  final Map<String, ProfileDraft> _profiles = {};

  @override
  Future<ProfileDraft?> load(String userId) async => _profiles[userId];

  @override
  Future<void> save(String userId, ProfileDraft profile) async =>
      _profiles[userId] = profile;

  @override
  Future<void> delete(String userId) async => _profiles.remove(userId);
}
