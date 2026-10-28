import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the app can reach its services (states-and-recovery §3, "Offline"). This build has no
/// services and no network plugin, so the value only changes from the Demo Hub's "Simulate being
/// offline" switch; a real build would feed it from the platform's network status.
///
/// While offline: a banner says so on every screen, chat messages wait and go out on reconnect,
/// and changes that need a server's answer (joining an event) fail with a retry.
class ConnectivityController extends Notifier<bool> {
  @override
  bool build() => true;

  void setOnline(bool online) => state = online;
}

/// `true` when online.
final connectivityProvider = NotifierProvider<ConnectivityController, bool>(
  ConnectivityController.new,
);
