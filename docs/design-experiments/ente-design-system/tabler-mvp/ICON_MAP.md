# Tabler icon map

**Source:** npm `@tabler/icons` **3.50.0** (github.com/tabler/tabler-icons, MIT License, © Paweł Kuna).
- The official SVGs are copied **unmodified** into `apps/numaya_mobile/assets/icons/tabler/{outline,filled}/`, with the upstream `LICENSE`. That is 70 outline and 39 filled files.
- `tool/sync_tabler_icons.py <path-to-package>` copies exactly the files named in `lib/core/design_system/icons/tabler_icons.dart`. Run it with `--check` to verify the version, the files and that no stale files remain.
- Nothing is fetched at runtime. `lucide_icons_flutter` was removed from `pubspec.yaml`.

**Rendering:** `NumayaIcon(icon, filled: …)` renders a `TablerSvg`, which is `SvgPicture.asset` tinted with `BlendMode.srcIn`.
- Holes stay transparent and silhouettes are kept. The pair board was checked at 20pt and 48pt.
- Outline glyphs keep Tabler's 2px stroke on its 24 grid, about 1.67px at the 20pt size.
- Hit areas belong to the controls (`Pressable` and `NavIconButton`, 44–48pt), not to the glyph box.

**Which variant to use:**
- *Outline* is the default for neutral actions, list rows and inactive destinations. This matches Ente's Used Icons, Figma 11187:4760.
- *Filled* is used for:
  - the selected tab;
  - the leading glyph in alerts (`StatusBanner` and `InfoCard`), following Ente Banners 14590:125245;
  - toggles that are on, such as a saved heart (`NavIconButton(filled:)`).
- Filled is only used where Tabler ships the same glyph's solid artwork. A dash in the "Tabler filled" column means the role has no filled state, and the outline stays.

The table below is generated from `tabler_icons.dart`. "Lucide (V4)" is the glyph used on the V4 baseline `ea86a08`.

| Name | Role | Lucide (V4) | Tabler outline | Tabler filled |
|---|---|---|---|---|
| `chevronLeft` | back control (Ente arrow-left-02) | `arrowLeft` | `arrow-left` | – |
| `chevronRight` | row disclosure | `chevronRight` | `chevron-right` | – |
| `chevronDown` | expand / picker | `chevronDown` | `chevron-down` | – |
| `chevronUp` | collapse | `chevronUp` | `chevron-up` | – |
| `arrowRight` | go / actionable banner | `arrowRight` | `arrow-right` | – |
| `arrowUp` | chat send | `arrowUp` | `arrow-up` | – |
| `check` | done / selected | `check` | `check` | – |
| `plus` | add | `plus` | `plus` | – |
| `minus` | remove step | `minus` | `minus` | – |
| `close` | close / dismiss | `x` | `x` | – |
| `search` | search | `search` | `search` | – |
| `lock` | private / locked | `lock` | `lock` | `lock` |
| `heart` | like / Likes tab | `heart` | `heart` | `heart` |
| `star` | new / highlight | `star` | `star` | `star` |
| `delete` | delete character | `delete` | `backspace` | `backspace` |
| `message` | chat / Messages tab | `messageCircle` | `message-circle` | `message-circle` |
| `shield` | safety / unverified state | `shieldCheck` | `shield-check` | `shield-check` |
| `verified` | verified badge | `badgeCheck` | `rosette-discount-check` | `rosette-discount-check` |
| `flag` | report | `flag` | `flag` | `flag` |
| `block` | block (destructive) | `ban` | `ban` | – |
| `info` | information | `info` | `info-circle` | `info-circle` |
| `alert` | warning / error | `triangleAlert` | `alert-triangle` | `alert-triangle` |
| `wifiOff` | offline | `wifiOff` | `wifi-off` | – |
| `camera` | camera / photo | `camera` | `camera` | `camera` |
| `image` | image placeholder | `image` | `photo` | `photo` |
| `mic` | voice note | `mic` | `microphone` | `microphone` |
| `send` | send | `sendHorizontal` | `send` | – |
| `more` | more menu | `ellipsis` | `dots` | – |
| `filter` | filters | `slidersHorizontal` | `adjustments-horizontal` | `adjustments-horizontal` |
| `settings` | settings | `settings` | `settings` | `settings` |
| `user` | person / Profile tab | `user` | `user` | `user` |
| `userMinus` | unmatch | `userMinus` | `user-minus` | – |
| `trash` | delete (destructive) | `trash2` | `trash` | `trash` |
| `location` | location | `mapPin` | `map-pin` | `map-pin` |
| `bell` | notifications | `bell` | `bell` | `bell` |
| `eyeOff` | hidden | `eyeOff` | `eye-off` | – |
| `undo` | undo / rewind | `undo2` | `arrow-back-up` | – |
| `home` | Discover tab | `house` | `home` | `home` |
| `event` | Events tab (gated off) | `calendarHeart` | `calendar-heart` | – |
| `calendar` | date | `calendarDays` | `calendar` | `calendar` |
| `clock` | time | `clock` | `clock` | `clock` |
| `groups` | people / attendees | `users` | `users` | – |
| `share` | share | `share2` | `share` | – |
| `edit` | edit | `pencil` | `pencil` | `pencil` |
| `waitlist` | waitlist | `hourglass` | `hourglass` | `hourglass` |
| `eventBusy` | event full / cancelled | `calendarX` | `calendar-x` | – |
| `help` | help | `circleQuestionMark` | `help-circle` | `help-circle` |
| `premium` | Premium | `crown` | `crown` | `crown` |
| `link` | link | `link` | `link` | – |
| `music` | music interest | `music` | `music` | – |
| `maintenance` | maintenance | `wrench` | `tool` | – |
| `public` | public / visibility | `globe` | `world` | `world` |
| `nearby` | nearby | `navigation` | `navigation` | `navigation` |
| `tag` | tag / details | `tag` | `tag` | `tag` |
| `draft` | draft | `fileText` | `file-text` | `file-text` |
| `pending` | incomplete / pending state (dashed ring; no filled `progress` in Tabler, so alerts use clock) | `circleDashed` | `progress` | – |
| `refresh` | retry / refresh | `refreshCw` | `refresh` | – |
| `userAdd` | quick start / add | `userPlus` | `user-plus` | – |
| `explore` | explore / visibility | `compass` | `compass` | `compass` |
| `food` | food interest | `utensils` | `tools-kitchen-2` | – |
| `park` | outdoors interest | `trees` | `trees` | – |
| `run` | sport interest | `personStanding` | `run` | – |
| `palette` | design lab / art | `palette` | `palette` | `palette` |
| `games` | games interest | `dices` | `dice` | `dice` |
| `interests` | interests | `shapes` | `category` | `category` |
| `cards` | cards / layers | `layers` | `stack-2` | `stack-2` |
| `sparkle` | experiments / highlight | `sparkles` | `sparkles` | `sparkles` |
| `mobile.video` | video attachment | `video` | `video` | `video` |
| `mobile.play` | play | `play` | `player-play` | `player-play` |
| `mobile.stop` | stop recording | `square` | `player-stop` | `player-stop` |
| `mobile.attach` | attach | `plus` | `plus` | – |
