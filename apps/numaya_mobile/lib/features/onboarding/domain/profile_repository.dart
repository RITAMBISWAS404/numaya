import 'profile_draft.dart';

/// Saves the member's own profile. The only implementation today keeps it in memory for the app
/// session ([InMemoryProfileRepository]); a backend implementation replaces it later.
abstract interface class ProfileRepository {
  Future<ProfileDraft?> load(String userId);
  Future<void> save(String userId, ProfileDraft profile);
  Future<void> delete(String userId);
}
