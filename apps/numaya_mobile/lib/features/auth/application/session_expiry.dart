import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the server has ended this session (states-and-recovery §3, "Session expired": a 401).
/// This build has no server, so only the Demo Hub sets it. While it is set the app shows "Please
/// sign in again" over the current screen; confirming with a code clears it and returns there.
class SessionExpiryController extends Notifier<bool> {
  @override
  bool build() => false;

  void expire() => state = true;

  void clear() => state = false;
}

final sessionExpiryProvider = NotifierProvider<SessionExpiryController, bool>(
  SessionExpiryController.new,
);
