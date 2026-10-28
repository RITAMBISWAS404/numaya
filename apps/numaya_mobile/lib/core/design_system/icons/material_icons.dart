import 'package:flutter/material.dart';

import 'numaya_icon_data.g.dart';

/// Every [NumayaIcons] name drawn with Flutter's standard Material Icons (rounded style, the
/// closest match to V16's Material Symbols Rounded), as (filled, outline). The outline drawing is
/// used where an unfilled icon carries a state (an inactive tab, an unsaved heart).
///
/// The names stay the shared vocabulary with the web design system; only the Flutter rendering
/// changes (docs/mobile/UI_REFINEMENT_DECISIONS.md, RD-04). `star_shine` has no Material Icons
/// equivalent: curated picks use `auto_awesome`.
const Map<NumayaIcons, (IconData, IconData)> kMaterialIcons = {
  NumayaIcons.chevronLeft: (
    Icons.chevron_left_rounded,
    Icons.chevron_left_rounded,
  ),
  NumayaIcons.chevronRight: (
    Icons.chevron_right_rounded,
    Icons.chevron_right_rounded,
  ),
  NumayaIcons.chevronDown: (
    Icons.keyboard_arrow_down_rounded,
    Icons.keyboard_arrow_down_rounded,
  ),
  NumayaIcons.chevronUp: (
    Icons.keyboard_arrow_up_rounded,
    Icons.keyboard_arrow_up_rounded,
  ),
  NumayaIcons.arrowRight: (
    Icons.arrow_forward_rounded,
    Icons.arrow_forward_rounded,
  ),
  NumayaIcons.arrowUp: (Icons.arrow_upward_rounded, Icons.arrow_upward_rounded),
  NumayaIcons.check: (Icons.check_rounded, Icons.check_rounded),
  NumayaIcons.plus: (Icons.add_rounded, Icons.add_rounded),
  NumayaIcons.minus: (Icons.remove_rounded, Icons.remove_rounded),
  NumayaIcons.close: (Icons.close_rounded, Icons.close_rounded),
  NumayaIcons.search: (Icons.search_rounded, Icons.search_rounded),
  NumayaIcons.lock: (Icons.lock_rounded, Icons.lock_outline_rounded),
  NumayaIcons.heart: (Icons.favorite_rounded, Icons.favorite_border_rounded),
  NumayaIcons.star: (Icons.star_rounded, Icons.star_border_rounded),
  NumayaIcons.delete: (Icons.backspace_rounded, Icons.backspace_outlined),
  NumayaIcons.message: (
    Icons.chat_bubble_rounded,
    Icons.chat_bubble_outline_rounded,
  ),
  NumayaIcons.shield: (
    Icons.verified_user_rounded,
    Icons.verified_user_outlined,
  ),
  NumayaIcons.verified: (Icons.verified_rounded, Icons.verified_outlined),
  NumayaIcons.flag: (Icons.flag_rounded, Icons.flag_outlined),
  NumayaIcons.block: (Icons.block_rounded, Icons.block_rounded),
  NumayaIcons.info: (Icons.info_rounded, Icons.info_outline_rounded),
  NumayaIcons.alert: (Icons.warning_rounded, Icons.warning_amber_rounded),
  NumayaIcons.wifiOff: (Icons.wifi_off_rounded, Icons.wifi_off_rounded),
  NumayaIcons.camera: (Icons.photo_camera_rounded, Icons.photo_camera_outlined),
  NumayaIcons.image: (Icons.image_rounded, Icons.image_outlined),
  NumayaIcons.mic: (Icons.mic_rounded, Icons.mic_none_rounded),
  NumayaIcons.send: (Icons.arrow_upward_rounded, Icons.arrow_upward_rounded),
  NumayaIcons.more: (Icons.more_horiz_rounded, Icons.more_horiz_rounded),
  NumayaIcons.filter: (Icons.tune_rounded, Icons.tune_rounded),
  NumayaIcons.settings: (Icons.settings_rounded, Icons.settings_outlined),
  NumayaIcons.user: (Icons.person_rounded, Icons.person_outline_rounded),
  NumayaIcons.userMinus: (
    Icons.person_remove_rounded,
    Icons.person_remove_outlined,
  ),
  NumayaIcons.trash: (Icons.delete_rounded, Icons.delete_outline_rounded),
  NumayaIcons.location: (Icons.location_on_rounded, Icons.location_on_outlined),
  NumayaIcons.bell: (
    Icons.notifications_rounded,
    Icons.notifications_none_rounded,
  ),
  NumayaIcons.eyeOff: (
    Icons.visibility_off_rounded,
    Icons.visibility_off_outlined,
  ),
  NumayaIcons.undo: (Icons.undo_rounded, Icons.undo_rounded),
  NumayaIcons.home: (Icons.home_rounded, Icons.home_outlined),
  NumayaIcons.event: (Icons.event_rounded, Icons.event_outlined),
  NumayaIcons.calendar: (
    Icons.calendar_month_rounded,
    Icons.calendar_month_outlined,
  ),
  NumayaIcons.clock: (Icons.schedule_rounded, Icons.schedule_outlined),
  NumayaIcons.groups: (Icons.groups_rounded, Icons.groups_outlined),
  NumayaIcons.share: (Icons.share_rounded, Icons.share_outlined),
  NumayaIcons.edit: (Icons.edit_rounded, Icons.edit_outlined),
  NumayaIcons.waitlist: (
    Icons.hourglass_top_rounded,
    Icons.hourglass_top_rounded,
  ),
  NumayaIcons.eventBusy: (Icons.event_busy_rounded, Icons.event_busy_outlined),
  NumayaIcons.help: (Icons.help_rounded, Icons.help_outline_rounded),
  NumayaIcons.premium: (
    Icons.workspace_premium_rounded,
    Icons.workspace_premium_outlined,
  ),
  NumayaIcons.link: (Icons.link_rounded, Icons.link_rounded),
  NumayaIcons.music: (Icons.music_note_rounded, Icons.music_note_outlined),
  NumayaIcons.maintenance: (
    Icons.construction_rounded,
    Icons.construction_rounded,
  ),
  NumayaIcons.public: (Icons.public_rounded, Icons.public_rounded),
  NumayaIcons.nearby: (Icons.near_me_rounded, Icons.near_me_outlined),
  NumayaIcons.tag: (Icons.sell_rounded, Icons.sell_outlined),
  NumayaIcons.draft: (Icons.description_rounded, Icons.description_outlined),
  NumayaIcons.pending: (Icons.pending_rounded, Icons.pending_outlined),
  NumayaIcons.refresh: (Icons.refresh_rounded, Icons.refresh_rounded),
  NumayaIcons.userAdd: (Icons.person_add_rounded, Icons.person_add_outlined),
  NumayaIcons.explore: (Icons.explore_rounded, Icons.explore_outlined),
  NumayaIcons.food: (Icons.restaurant_rounded, Icons.restaurant_rounded),
  NumayaIcons.park: (Icons.park_rounded, Icons.park_outlined),
  NumayaIcons.run: (Icons.directions_run_rounded, Icons.directions_run_rounded),
  NumayaIcons.palette: (Icons.palette_rounded, Icons.palette_outlined),
  NumayaIcons.games: (Icons.casino_rounded, Icons.casino_outlined),
  NumayaIcons.interests: (Icons.interests_rounded, Icons.interests_outlined),
  NumayaIcons.cards: (Icons.style_rounded, Icons.style_outlined),
  NumayaIcons.sparkle: (
    Icons.auto_awesome_rounded,
    Icons.auto_awesome_outlined,
  ),
};
