import 'numaya_icon_data.g.dart';

/// Tabler Icons (https://tabler.io/icons), the app's icon family since the Tabler MVP pass.
///
/// - Source: the official SVGs from npm `@tabler/icons` 3.50.0 (github.com/tabler/tabler-icons,
///   MIT; notice in `assets/icons/tabler/LICENSE`), copied unmodified into
///   `assets/icons/tabler/{outline,filled}/` by `tool/sync_tabler_icons.py`. Nothing is fetched at
///   runtime.
/// - Outline glyphs are drawn with a stroke set by size role ([tablerOutlineStroke], X15-I), not
///   Tabler's shipped 2. The bundled files are unchanged; the shared renderer rewrites the root
///   `stroke-width` when it loads an outline asset. Filled artwork is never touched.
/// - [NumayaIcon] tints with `BlendMode.srcIn`, so holes stay transparent and the silhouette is
///   kept.
///
/// Each name maps to `(outline, filled)`. `filled` is Tabler's own solid artwork for the same glyph,
/// used for selected and emphasised states (the selected tab); null where a role has no filled
/// state, and then [NumayaIcon] draws the outline. The names stay the shared vocabulary; only this
/// map changes the drawing (docs/design-experiments/ente-design-system/tabler-mvp/ICON_MAP.md).
typedef TablerGlyph = ({String outline, String? filled});

const Map<NumayaIcons, TablerGlyph> kTablerIcons = {
  // back control (Ente arrow-left-02)
  NumayaIcons.chevronLeft: (outline: 'arrow-left', filled: null),
  // row disclosure
  NumayaIcons.chevronRight: (outline: 'chevron-right', filled: null),
  // expand / picker
  NumayaIcons.chevronDown: (outline: 'chevron-down', filled: null),
  // collapse
  NumayaIcons.chevronUp: (outline: 'chevron-up', filled: null),
  // go / actionable banner
  NumayaIcons.arrowRight: (outline: 'arrow-right', filled: null),
  // chat send
  NumayaIcons.arrowUp: (outline: 'arrow-up', filled: null),
  // done / selected
  NumayaIcons.check: (outline: 'check', filled: null),
  // add
  NumayaIcons.plus: (outline: 'plus', filled: null),
  // remove step
  NumayaIcons.minus: (outline: 'minus', filled: null),
  // close / dismiss
  NumayaIcons.close: (outline: 'x', filled: null),
  // search
  NumayaIcons.search: (outline: 'search', filled: null),
  // private / locked
  NumayaIcons.lock: (outline: 'lock', filled: 'lock'),
  // like / Likes tab
  NumayaIcons.heart: (outline: 'heart', filled: 'heart'),
  // new / highlight
  NumayaIcons.star: (outline: 'star', filled: 'star'),
  // delete character
  NumayaIcons.delete: (outline: 'backspace', filled: 'backspace'),
  // chat / Messages tab
  NumayaIcons.message: (outline: 'message-circle', filled: 'message-circle'),
  // safety / unverified state
  NumayaIcons.shield: (outline: 'shield-check', filled: 'shield-check'),
  // verified badge
  NumayaIcons.verified: (
    outline: 'rosette-discount-check',
    filled: 'rosette-discount-check',
  ),
  // report
  NumayaIcons.flag: (outline: 'flag', filled: 'flag'),
  // block (destructive)
  NumayaIcons.block: (outline: 'ban', filled: null),
  // information
  NumayaIcons.info: (outline: 'info-circle', filled: 'info-circle'),
  // warning / error
  NumayaIcons.alert: (outline: 'alert-triangle', filled: 'alert-triangle'),
  // offline
  NumayaIcons.wifiOff: (outline: 'wifi-off', filled: null),
  // camera / photo
  NumayaIcons.camera: (outline: 'camera', filled: 'camera'),
  // image placeholder
  NumayaIcons.image: (outline: 'photo', filled: 'photo'),
  // voice note
  NumayaIcons.mic: (outline: 'microphone', filled: 'microphone'),
  // send
  NumayaIcons.send: (outline: 'send', filled: null),
  // more menu
  NumayaIcons.more: (outline: 'dots', filled: null),
  // filters
  NumayaIcons.filter: (
    outline: 'adjustments-horizontal',
    filled: 'adjustments-horizontal',
  ),
  // settings
  NumayaIcons.settings: (outline: 'settings', filled: 'settings'),
  // person / Profile tab
  NumayaIcons.user: (outline: 'user', filled: 'user'),
  // unmatch
  NumayaIcons.userMinus: (outline: 'user-minus', filled: null),
  // delete (destructive)
  NumayaIcons.trash: (outline: 'trash', filled: 'trash'),
  // location
  NumayaIcons.location: (outline: 'map-pin', filled: 'map-pin'),
  // notifications
  NumayaIcons.bell: (outline: 'bell', filled: 'bell'),
  // hidden
  NumayaIcons.eyeOff: (outline: 'eye-off', filled: null),
  // undo / rewind
  NumayaIcons.undo: (outline: 'arrow-back-up', filled: null),
  // Discover tab
  NumayaIcons.home: (outline: 'home', filled: 'home'),
  // Events tab (gated off)
  NumayaIcons.event: (outline: 'calendar-heart', filled: null),
  // date
  NumayaIcons.calendar: (outline: 'calendar', filled: 'calendar'),
  // time
  NumayaIcons.clock: (outline: 'clock', filled: 'clock'),
  // people / attendees
  NumayaIcons.groups: (outline: 'users', filled: null),
  // share
  NumayaIcons.share: (outline: 'share', filled: null),
  // edit
  NumayaIcons.edit: (outline: 'pencil', filled: 'pencil'),
  // waitlist
  NumayaIcons.waitlist: (outline: 'hourglass', filled: 'hourglass'),
  // event full / cancelled
  NumayaIcons.eventBusy: (outline: 'calendar-x', filled: null),
  // help
  NumayaIcons.help: (outline: 'help-circle', filled: 'help-circle'),
  // Premium
  NumayaIcons.premium: (outline: 'crown', filled: 'crown'),
  // link
  NumayaIcons.link: (outline: 'link', filled: null),
  // music interest
  NumayaIcons.music: (outline: 'music', filled: null),
  // maintenance
  NumayaIcons.maintenance: (outline: 'tool', filled: null),
  // public / visibility
  NumayaIcons.public: (outline: 'world', filled: 'world'),
  // nearby
  NumayaIcons.nearby: (outline: 'navigation', filled: 'navigation'),
  // tag / details
  NumayaIcons.tag: (outline: 'tag', filled: 'tag'),
  // draft
  NumayaIcons.draft: (outline: 'file-text', filled: 'file-text'),
  // incomplete / pending state (dashed ring; no filled `progress` in Tabler, so alerts use clock)
  NumayaIcons.pending: (outline: 'progress', filled: null),
  // retry / refresh
  NumayaIcons.refresh: (outline: 'refresh', filled: null),
  // quick start / add
  NumayaIcons.userAdd: (outline: 'user-plus', filled: null),
  // explore / visibility
  NumayaIcons.explore: (outline: 'compass', filled: 'compass'),
  // food interest
  NumayaIcons.food: (outline: 'tools-kitchen-2', filled: null),
  // outdoors interest
  NumayaIcons.park: (outline: 'trees', filled: null),
  // sport interest
  NumayaIcons.run: (outline: 'run', filled: null),
  // design lab / art
  NumayaIcons.palette: (outline: 'palette', filled: 'palette'),
  // games interest
  NumayaIcons.games: (outline: 'dice', filled: 'dice'),
  // interests
  NumayaIcons.interests: (outline: 'category', filled: 'category'),
  // cards / layers
  NumayaIcons.cards: (outline: 'stack-2', filled: 'stack-2'),
  // experiments / highlight
  NumayaIcons.sparkle: (outline: 'sparkles', filled: 'sparkles'),
};

/// Glyphs the mobile app needs beyond the shared web set.
enum NumayaMobileIcons {
  /// Work (the job line under a name).
  work,
  video,
  play,
  pause,
  stop,
  attach,
  logout,
  compliment,
  flame,
  wallet,
  gift,
  chart,
  receipt,
  legal,
  hourglass,
  bellOff,
  extend,
  archive,
  eye,
  users,
  bulb,
  trendingUp,
  trendingDown,
  funnel,
}

/// Mobile-only glyphs, drawn with Tabler like [kTablerIcons].
const Map<NumayaMobileIcons, TablerGlyph> kTablerMobileIcons = {
  // video attachment
  NumayaMobileIcons.video: (outline: 'video', filled: 'video'),
  // play
  NumayaMobileIcons.play: (outline: 'player-play', filled: 'player-play'),

  NumayaMobileIcons.pause: (outline: 'player-pause', filled: 'player-pause'),
  // stop recording
  NumayaMobileIcons.stop: (outline: 'player-stop', filled: 'player-stop'),
  // attach
  NumayaMobileIcons.attach: (outline: 'plus', filled: null),
  // sign out (Settings)
  NumayaMobileIcons.logout: (outline: 'logout', filled: null),
  // MVP PRD pass (2026-11-07):
  // Compliment anchor and composer
  NumayaMobileIcons.compliment: (outline: 'message-heart', filled: null),
  // streak
  NumayaMobileIcons.flame: (outline: 'flame', filled: 'flame'),
  // job under a name on a photo (selections pass, 2026-11-13)
  NumayaMobileIcons.work: (outline: 'briefcase', filled: 'briefcase'),
  // credit wallet
  NumayaMobileIcons.wallet: (outline: 'wallet', filled: null),
  // streak reward
  NumayaMobileIcons.gift: (outline: 'gift', filled: 'gift'),
  // insights
  NumayaMobileIcons.chart: (outline: 'chart-bar', filled: null),
  // purchases
  NumayaMobileIcons.receipt: (outline: 'receipt', filled: null),
  // legal documents
  NumayaMobileIcons.legal: (outline: 'scale', filled: null),
  // timers and deadlines
  NumayaMobileIcons.hourglass: (outline: 'hourglass', filled: 'hourglass'),
  // mute
  NumayaMobileIcons.bellOff: (outline: 'bell-off', filled: null),
  // extend a match
  NumayaMobileIcons.extend: (outline: 'clock-plus', filled: null),
  // Visual Lab V2 (2026-11-08):
  // archived chats (R01)
  NumayaMobileIcons.archive: (outline: 'archive', filled: 'archive'),
  // profile appearances (insights)
  NumayaMobileIcons.eye: (outline: 'eye', filled: 'eye'),
  // eligible audience (insights)
  NumayaMobileIcons.users: (outline: 'users', filled: null),
  // evidence-linked suggestion (insights)
  NumayaMobileIcons.bulb: (outline: 'bulb', filled: 'bulb'),
  // period comparison up / down
  NumayaMobileIcons.trendingUp: (outline: 'trending-up', filled: null),
  NumayaMobileIcons.trendingDown: (outline: 'trending-down', filled: null),
  // funnel (insights)
  NumayaMobileIcons.funnel: (outline: 'chart-funnel', filled: null),
};

/// Outline stroke policy (X15-I, 15px experiment 2026-11-07), in Tabler's 24 x 24 viewBox units;
/// the rendered stroke in logical pixels is `stroke * size / 24`. The policy stays within
/// 1.25-1.5 (supersedes FT-03's 1.0 small class, which drew 14-16pt glyphs at 0.58-0.67pt):
/// - **Normal** (up to 24pt: meta, chips, rows, buttons, headers, tabs, chevrons): 1.5, so
///   0.88pt at 14, 1.0 at 16, 1.13 at 18, 1.25 at 20 and 1.5 at 24.
/// - **Light** (over 24pt: empty-state and placeholder art): 1.25, so 1.5pt at 28.8 and 1.88 at 36.
///   Art is drawn large, so the lighter source stroke keeps it from out-weighing the text.
double tablerOutlineStroke(double size) => size <= kTablerLargeMax ? 1.5 : 1.25;

/// The largest size drawn at the normal 1.5 stroke (Ente's Medium icon, 24); larger art is light.
const double kTablerLargeMax = 24;

/// Rewrites the root `stroke-width` of a Tabler outline SVG. Tabler outline files declare the
/// stroke once, on the `<svg>` element, and every path inherits it (checked by
/// test/widget/figma_type_icons_test.dart), so one attribute change reaches every path while the
/// round caps and joins, viewBox and `fill="none"` stay as shipped.
String withTablerStroke(String svg, double stroke) {
  final root = RegExp(r'<svg\s[^>]*>').firstMatch(svg);
  if (root == null) return svg;
  final tag = root.group(0)!;
  final value = stroke == stroke.roundToDouble()
      ? stroke.toStringAsFixed(0)
      : stroke.toString();
  final rewritten = tag.replaceFirst(
    RegExp(r'stroke-width="[^"]*"'),
    'stroke-width="$value"',
  );
  return svg.replaceRange(root.start, root.end, rewritten);
}

/// The bundled asset for [glyph], filled when asked and available.
String tablerAsset(TablerGlyph glyph, {bool filled = false}) =>
    filled && glyph.filled != null
    ? 'assets/icons/tabler/filled/${glyph.filled}.svg'
    : 'assets/icons/tabler/outline/${glyph.outline}.svg';
