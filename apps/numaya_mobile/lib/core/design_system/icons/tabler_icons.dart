import 'numaya_icon_data.g.dart';

/// Tabler Icons (https://tabler.io/icons), the app's icon family since the Tabler MVP pass.
///
/// - Source: the official SVGs from npm `@tabler/icons` 3.50.0 (github.com/tabler/tabler-icons,
///   MIT; notice in `assets/icons/tabler/LICENSE`), copied unmodified into
///   `assets/icons/tabler/{outline,filled}/` by `tool/sync_tabler_icons.py`. Nothing is fetched at
///   runtime.
/// - Outline glyphs keep Tabler's 2px stroke on a 24 grid (about 1.67px at the 20pt icon size,
///   close to the thin outline weight of Ente's product icons).
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
  NumayaIcons.public: (outline: 'world', filled: null),
  // nearby
  NumayaIcons.nearby: (outline: 'navigation', filled: 'navigation'),
  // tag / details
  NumayaIcons.tag: (outline: 'tag', filled: 'tag'),
  // draft
  NumayaIcons.draft: (outline: 'file-text', filled: 'file-text'),
  // pending state
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
enum NumayaMobileIcons { video, play, stop, attach }

/// Mobile-only glyphs, drawn with Tabler like [kTablerIcons].
const Map<NumayaMobileIcons, TablerGlyph> kTablerMobileIcons = {
  // video attachment
  NumayaMobileIcons.video: (outline: 'video', filled: 'video'),
  // play
  NumayaMobileIcons.play: (outline: 'player-play', filled: 'player-play'),
  // stop recording
  NumayaMobileIcons.stop: (outline: 'player-stop', filled: 'player-stop'),
  // attach
  NumayaMobileIcons.attach: (outline: 'plus', filled: null),
};

/// The bundled asset for [glyph], filled when asked and available.
String tablerAsset(TablerGlyph glyph, {bool filled = false}) =>
    filled && glyph.filled != null
    ? 'assets/icons/tabler/filled/${glyph.filled}.svg'
    : 'assets/icons/tabler/outline/${glyph.outline}.svg';
