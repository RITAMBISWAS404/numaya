import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'numaya_icon_data.g.dart';

/// Ente design-system experiment: every [NumayaIcons] name drawn with one Lucide glyph
/// (lucide_icons_flutter 4.0.1, MIT; Lucide glyphs ISC). Lucide is a stroke-only set, so there is
/// no filled twin: a state that the Material set showed by filling the glyph (an active tab, a
/// saved heart) is carried by colour and by the control's own surface instead
/// (docs/design-experiments/ente-design-system/DECISIONS.md, ED-03).
///
/// The names stay the shared vocabulary; only this map changes the drawing.
const Map<NumayaIcons, IconData> kLucideIcons = {
  // Every chevronLeft is a back control; Ente headers draw it as an arrow (arrow-left-02).
  NumayaIcons.chevronLeft: LucideIcons.arrowLeft,
  NumayaIcons.chevronRight: LucideIcons.chevronRight,
  NumayaIcons.chevronDown: LucideIcons.chevronDown,
  NumayaIcons.chevronUp: LucideIcons.chevronUp,
  NumayaIcons.arrowRight: LucideIcons.arrowRight,
  NumayaIcons.arrowUp: LucideIcons.arrowUp,
  NumayaIcons.check: LucideIcons.check,
  NumayaIcons.plus: LucideIcons.plus,
  NumayaIcons.minus: LucideIcons.minus,
  NumayaIcons.close: LucideIcons.x,
  NumayaIcons.search: LucideIcons.search,
  NumayaIcons.lock: LucideIcons.lock,
  NumayaIcons.heart: LucideIcons.heart,
  NumayaIcons.star: LucideIcons.star,
  NumayaIcons.delete: LucideIcons.delete,
  NumayaIcons.message: LucideIcons.messageCircle,
  NumayaIcons.shield: LucideIcons.shieldCheck,
  NumayaIcons.verified: LucideIcons.badgeCheck,
  NumayaIcons.flag: LucideIcons.flag,
  NumayaIcons.block: LucideIcons.ban,
  NumayaIcons.info: LucideIcons.info,
  NumayaIcons.alert: LucideIcons.triangleAlert,
  NumayaIcons.wifiOff: LucideIcons.wifiOff,
  NumayaIcons.camera: LucideIcons.camera,
  NumayaIcons.image: LucideIcons.image,
  NumayaIcons.mic: LucideIcons.mic,
  NumayaIcons.send: LucideIcons.sendHorizontal,
  NumayaIcons.more: LucideIcons.ellipsis,
  NumayaIcons.filter: LucideIcons.slidersHorizontal,
  NumayaIcons.settings: LucideIcons.settings,
  NumayaIcons.user: LucideIcons.user,
  NumayaIcons.userMinus: LucideIcons.userMinus,
  NumayaIcons.trash: LucideIcons.trash2,
  NumayaIcons.location: LucideIcons.mapPin,
  NumayaIcons.bell: LucideIcons.bell,
  NumayaIcons.eyeOff: LucideIcons.eyeOff,
  NumayaIcons.undo: LucideIcons.undo2,
  NumayaIcons.home: LucideIcons.house,
  NumayaIcons.event: LucideIcons.calendarHeart,
  NumayaIcons.calendar: LucideIcons.calendarDays,
  NumayaIcons.clock: LucideIcons.clock,
  NumayaIcons.groups: LucideIcons.users,
  NumayaIcons.share: LucideIcons.share2,
  NumayaIcons.edit: LucideIcons.pencil,
  NumayaIcons.waitlist: LucideIcons.hourglass,
  NumayaIcons.eventBusy: LucideIcons.calendarX,
  NumayaIcons.help: LucideIcons.circleQuestionMark,
  NumayaIcons.premium: LucideIcons.crown,
  NumayaIcons.link: LucideIcons.link,
  NumayaIcons.music: LucideIcons.music,
  NumayaIcons.maintenance: LucideIcons.wrench,
  NumayaIcons.public: LucideIcons.globe,
  NumayaIcons.nearby: LucideIcons.navigation,
  NumayaIcons.tag: LucideIcons.tag,
  NumayaIcons.draft: LucideIcons.fileText,
  NumayaIcons.pending: LucideIcons.circleDashed,
  NumayaIcons.refresh: LucideIcons.refreshCw,
  NumayaIcons.userAdd: LucideIcons.userPlus,
  NumayaIcons.explore: LucideIcons.compass,
  NumayaIcons.food: LucideIcons.utensils,
  NumayaIcons.park: LucideIcons.trees,
  NumayaIcons.run: LucideIcons.personStanding,
  NumayaIcons.palette: LucideIcons.palette,
  NumayaIcons.games: LucideIcons.dices,
  NumayaIcons.interests: LucideIcons.shapes,
  NumayaIcons.cards: LucideIcons.layers,
  NumayaIcons.sparkle: LucideIcons.sparkles,
};

/// Glyphs the mobile app needs beyond the shared web set.
enum NumayaMobileIcons { video, play, stop, attach }

/// Mobile-only glyphs, drawn with Lucide like [kLucideIcons].
const Map<NumayaMobileIcons, IconData> kLucideMobileIcons = {
  NumayaMobileIcons.video: LucideIcons.video,
  NumayaMobileIcons.play: LucideIcons.play,
  NumayaMobileIcons.stop: LucideIcons.square,
  NumayaMobileIcons.attach: LucideIcons.plus,
};
