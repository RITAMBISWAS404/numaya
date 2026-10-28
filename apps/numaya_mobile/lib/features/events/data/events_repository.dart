import '../domain/event.dart';
import '../domain/sample_events.dart';

/// Thrown when the events service can't be reached (or the demo's simulated failure is on).
class EventsUnavailable implements Exception {
  const EventsUnavailable();

  @override
  String toString() => 'EventsUnavailable';
}

/// Where events come from and where RSVPs and host changes go. A real implementation calls the
/// events service; [DemoEventsRepository] keeps everything on this device.
abstract interface class EventsRepository {
  /// The events visible to the member at [now].
  List<DemoEvent> initial(DateTime now);

  /// Records a change (join, leave, publish, cancel …). Throws [EventsUnavailable] on failure; the
  /// caller then leaves its state unchanged.
  Future<void> send(String action, String eventId);
}

/// The prototype's events: sample data, nothing leaves the device. [failing] reads the Demo Hub's
/// "Simulate connection problems" switch.
class DemoEventsRepository implements EventsRepository {
  DemoEventsRepository({
    required this.failing,
    required this.fullWorld,
    this.latency = const Duration(milliseconds: 300),
  });

  final bool Function() failing;
  final bool fullWorld;
  final Duration latency;

  @override
  List<DemoEvent> initial(DateTime now) => sampleEvents(now, full: fullWorld);

  @override
  Future<void> send(String action, String eventId) async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    if (failing()) throw const EventsUnavailable();
  }
}
