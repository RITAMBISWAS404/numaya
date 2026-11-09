/// What the first release exposes (UI-016, UI-031, UI-032; Events: Tabler MVP pass).
///
/// Opening Moves, Follow and SuperSwipe are excluded from the first release. Their code, stored
/// data and state are kept dormant (no data is deleted and no contract changes); every UI entry
/// point and route checks these flags, so none can be reached in a release build, through a
/// screen, a menu, a deep link or the Demo Hub.
///
/// Internal builds can bring a feature back for comparison with
/// `--dart-define=NUMAYA_OPENING_MOVES=true` or `--dart-define=NUMAYA_SUPER_SWIPE=true`. Follow has
/// no implementation in this app, so it has no switch.
abstract final class ReleaseScope {
  static const bool openingMoves = bool.fromEnvironment('NUMAYA_OPENING_MOVES');
  static const bool superSwipe = bool.fromEnvironment('NUMAYA_SUPER_SWIPE');
  static const bool follow = false;

  /// Events (the tab, event pages, creating an event) is not in the MVP. Its screens, data,
  /// controller and repository stay in `lib/features/events/` untouched; with this off the tab is
  /// not built, every entry point is hidden, and `/events`, `/event/...` and their child routes
  /// (deep links included) redirect to Discover. Bring it back for an internal build with
  /// `--dart-define=NUMAYA_EVENTS=true`, or at launch by setting the default to true
  /// (docs/design-experiments/ente-design-system/tabler-mvp/EVENTS_GATE.md).
  static const bool events = bool.fromEnvironment('NUMAYA_EVENTS');

  /// Photos and voice notes in chat (V6 messaging pass, owner request). Files stay on this device:
  /// there is no upload service yet. Off with `--dart-define=NUMAYA_CHAT_ATTACHMENTS=false`.
  static const bool chatAttachments = bool.fromEnvironment(
    'NUMAYA_CHAT_ATTACHMENTS',
    defaultValue: true,
  );
}
