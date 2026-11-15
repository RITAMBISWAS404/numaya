import 'sample_people.dart';

/// Members loaded from the live backend (backend V1), by id. Empty in demo builds, so the demo's
/// sample people resolve exactly as before. `personById` checks this first.
final Map<String, SamplePerson> liveDirectory = {};
