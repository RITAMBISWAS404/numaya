/// What the first release exposes (UI-016, UI-031, UI-032).
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
}
